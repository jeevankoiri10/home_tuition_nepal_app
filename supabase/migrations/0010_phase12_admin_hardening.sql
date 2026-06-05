-- Home Tuition Nepal — Phase 12 schema (admin panel hardening).
-- Run after 0009_phase11_coin_topups.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- profiles — moderation columns + status helper.
-- ────────────────────────────────────────────────────────────────────────────
alter table profiles add column if not exists suspended_until timestamptz;
alter table profiles add column if not exists banned_at       timestamptz;
alter table profiles add column if not exists suspension_reason text;

create or replace function _is_blocked(p_user uuid)
returns boolean
language sql
stable
as $$
  select coalesce(
    (select banned_at is not null
         or (suspended_until is not null and suspended_until > now())
       from profiles where id = p_user),
    false
  );
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- audit_events — append-only forensic feed. Every admin action that mutates
-- user-visible state writes one of these rows.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists audit_events (
  id          uuid primary key default uuid_generate_v4(),
  type        text not null,                  -- 'TutorVerified', 'UserSuspended', 'PlatformSettingChanged', ...
  actor_id    uuid references auth.users(id), -- the admin who did it
  target_type text,                            -- 'profile' | 'vacancy' | 'topup' | ...
  target_id   uuid,
  payload     jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index if not exists audit_events_target_idx on audit_events(target_type, target_id, occurred_at desc);
create index if not exists audit_events_type_idx on audit_events(type, occurred_at desc);
create index if not exists audit_events_actor_idx on audit_events(actor_id, occurred_at desc);

alter table audit_events enable row level security;

drop policy if exists audit_events_admin_select on audit_events;
create policy audit_events_admin_select on audit_events for select
  using (exists (select 1 from admin_users where id = auth.uid()));

-- Direct writes are forbidden — admin RPCs are the only path.
create or replace function _block_direct_audit_writes() returns trigger
language plpgsql as $$
begin
  if current_setting('app.allow_audit_write', true) is distinct from 'yes' then
    raise exception 'audit_events is append-only via admin RPCs';
  end if;
  return new;
end;
$$;
drop trigger if exists trg_audit_events_block on audit_events;
create trigger trg_audit_events_block
  before insert or update or delete on audit_events
  for each row execute function _block_direct_audit_writes();

create or replace function _audit(p_type text, p_target_type text, p_target_id uuid, p_payload jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  perform set_config('app.allow_audit_write', 'yes', true);
  insert into audit_events(type, actor_id, target_type, target_id, payload)
  values (p_type, auth.uid(), p_target_type, p_target_id, coalesce(p_payload, '{}'::jsonb));
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- moderation_log — flagged content + admin decisions.
-- The phone-ban triggers on jobs/vacancies/messages/reviews already raise
-- exceptions — this table records cases the admin reviews manually
-- (false-positive reports, abuse flags from users, etc.).
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists moderation_log (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references profiles(id) on delete cascade,
  reporter_id uuid references profiles(id),     -- null = automatic flag
  field       text,                              -- 'job.description', 'chat.body', ...
  reason      text not null,                     -- 'phone_in_text', 'abuse', 'spam', 'fake_profile'
  excerpt     text,
  action      text check (action in ('open','warn','suspend','ban','dismissed')) default 'open',
  notes       text,
  created_at  timestamptz not null default now(),
  resolved_at timestamptz
);

-- Admin-panel-compatible columns. The Next.js admin reads `kind`/`status` and
-- updates `status`; the mobile app writes `reason`/`action`. Added as a nullable
-- superset so both surfaces share one table. See admin_setup.sql.
alter table moderation_log add column if not exists kind        text;
alter table moderation_log add column if not exists status      text default 'open';
alter table moderation_log add column if not exists source_type text;
alter table moderation_log add column if not exists source_id   uuid;

create index if not exists moderation_log_open_idx on moderation_log(action) where action = 'open';
create index if not exists moderation_log_user_idx on moderation_log(user_id, created_at desc);

alter table moderation_log enable row level security;

drop policy if exists moderation_log_admin_select on moderation_log;
create policy moderation_log_admin_select on moderation_log for select
  using (exists (select 1 from admin_users where id = auth.uid()));

drop policy if exists moderation_log_user_report on moderation_log;
create policy moderation_log_user_report on moderation_log for insert
  with check (auth.uid() = reporter_id and action = 'open');

-- ────────────────────────────────────────────────────────────────────────────
-- verifications — separate from the verified flag on tutors so we keep the
-- full history (re-submissions, rejections). One row per submission.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists verifications (
  id                  uuid primary key default uuid_generate_v4(),
  tutor_id            uuid not null references profiles(id) on delete cascade,
  citizenship_front   text,    -- supabase storage paths (private bucket)
  citizenship_back    text,
  selfie              text,
  status              text not null check (status in ('submitted','approved','rejected')) default 'submitted',
  reviewed_by         uuid references admin_users(id),
  reviewed_at         timestamptz,
  rejection_reason    text,
  created_at          timestamptz not null default now()
);

create index if not exists verifications_status_idx on verifications(status, created_at);
create index if not exists verifications_tutor_idx on verifications(tutor_id, created_at desc);

alter table verifications enable row level security;

drop policy if exists verifications_select on verifications;
create policy verifications_select on verifications for select
  using (auth.uid() = tutor_id
         or exists (select 1 from admin_users where id = auth.uid()));

drop policy if exists verifications_insert_self on verifications;
create policy verifications_insert_self on verifications for insert
  with check (auth.uid() = tutor_id and status = 'submitted');

-- ────────────────────────────────────────────────────────────────────────────
-- Honour suspension / ban in the existing money-moving RPCs. We wrap them
-- by replacing their bodies with the guard + delegating to a renamed helper.
-- ────────────────────────────────────────────────────────────────────────────

-- Tutor application gate
create or replace function tutor_apply_to_vacancy(
  p_vacancy_id   uuid,
  p_cover_note   text,
  p_expected_rate numeric,
  p_cv_path      text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  cost   int;
  app_id uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;
  if not exists (select 1 from tutors where id = caller) then
    raise exception 'not_a_tutor';
  end if;
  if not exists (select 1 from vacancies where id = p_vacancy_id and status = 'open') then
    raise exception 'vacancy_not_open';
  end if;
  if exists (select 1 from vacancy_applications where vacancy_id = p_vacancy_id and tutor_id = caller) then
    raise exception 'already_applied';
  end if;

  cost := get_platform_setting_int('apply_coin_cost', 1);
  perform _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id, 'Applied to vacancy'
  );
  insert into vacancy_applications(vacancy_id, tutor_id, cover_note, expected_rate, cv_storage_path, coins_spent)
  values (p_vacancy_id, caller, p_cover_note, p_expected_rate, p_cv_path, cost)
  returning id into app_id;
  return app_id;
end;
$$;

-- Student unlock gate
create or replace function unlock_contact(p_tutor_id uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  caller       uuid := auth.uid();
  already      uuid;
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;
  if caller = p_tutor_id then raise exception 'cannot_unlock_self'; end if;

  select id into already from wallet_ledger
   where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id limit 1;
  if already is not null then
    return (select coin_balance from profiles where id = caller);
  end if;

  cost := get_platform_setting_int('unlock_coin_cost', 5);
  new_balance := _ledger_apply(
    caller, -cost, 'unlock', 'tutor', p_tutor_id, 'Unlocked contact for tutor'
  );
  return new_balance;
end;
$$;

-- Chat send gate
create or replace function send_chat_message(p_thread_id uuid, p_body text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  msg_id uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;
  if not exists (
    select 1 from chat_threads
     where id = p_thread_id and auth.uid() in (student_id, tutor_id)
  ) then raise exception 'thread_not_found_or_forbidden'; end if;
  if length(coalesce(trim(p_body), '')) = 0 then raise exception 'empty_message'; end if;
  if _has_phone_or_contact(p_body) then raise exception 'phone_in_message'; end if;

  insert into chat_messages(thread_id, sender_id, body)
  values (p_thread_id, caller, p_body)
  returning id into msg_id;
  update chat_threads set last_message_at = now() where id = p_thread_id;
  return msg_id;
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- Admin-only RPCs
-- ────────────────────────────────────────────────────────────────────────────

create or replace function admin_suspend_user(
  p_user uuid, p_until timestamptz, p_reason text
) returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  update profiles
     set suspended_until = p_until,
         suspension_reason = p_reason,
         banned_at = null
   where id = p_user;
  perform _audit('UserSuspended', 'profile', p_user,
    jsonb_build_object('until', p_until, 'reason', p_reason));
  insert into notifications(user_id, kind, title, body)
  values (p_user, 'system', 'Account suspended',
          coalesce(p_reason, 'Your account has been temporarily suspended.'));
end;
$$;
grant execute on function admin_suspend_user(uuid, timestamptz, text) to authenticated;

create or replace function admin_ban_user(p_user uuid, p_reason text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  update profiles set banned_at = now(), suspension_reason = p_reason where id = p_user;
  perform _audit('UserBanned', 'profile', p_user, jsonb_build_object('reason', p_reason));
end;
$$;
grant execute on function admin_ban_user(uuid, text) to authenticated;

create or replace function admin_unban_user(p_user uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  update profiles
     set banned_at = null,
         suspended_until = null,
         suspension_reason = null
   where id = p_user;
  perform _audit('UserUnbanned', 'profile', p_user, '{}'::jsonb);
end;
$$;
grant execute on function admin_unban_user(uuid) to authenticated;

create or replace function admin_review_verification(
  p_verification_id uuid, p_approve boolean, p_reason text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v record;
  bonus int;
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  select * into v from verifications where id = p_verification_id;
  if v is null then raise exception 'verification_not_found'; end if;
  if v.status <> 'submitted' then raise exception 'already_reviewed'; end if;

  update verifications
     set status = case when p_approve then 'approved' else 'rejected' end,
         reviewed_by = auth.uid(),
         reviewed_at = now(),
         rejection_reason = case when p_approve then null else p_reason end
   where id = p_verification_id;

  if p_approve then
    update tutors set verified = true where id = v.tutor_id;
    perform recompute_tutor_rating(v.tutor_id);
    bonus := get_platform_setting_int('id_verification_bonus', 50);
    if bonus > 0 then
      perform _ledger_apply(v.tutor_id, bonus, 'reward', 'verification', v.id,
                            'ID verification approved');
    end if;
    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    values (v.tutor_id, 'identity_verification_approved',
            'Identity Verification Approved', 'Your verified badge is now active.',
            'verification', v.id);
    perform _audit('TutorVerified', 'profile', v.tutor_id, '{}'::jsonb);
  else
    update tutors set verified = false where id = v.tutor_id;
    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    values (v.tutor_id, 'identity_verification_rejected',
            'Verification needs attention',
            coalesce(p_reason, 'Please re-submit your documents.'),
            'verification', v.id);
    perform _audit('TutorVerificationRejected', 'profile', v.tutor_id,
                   jsonb_build_object('reason', p_reason));
  end if;
end;
$$;
grant execute on function admin_review_verification(uuid, boolean, text) to authenticated;

create or replace function admin_set_setting(p_key text, p_value text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  old_value text;
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  select value into old_value from platform_settings where key = p_key;
  insert into platform_settings(key, value, updated_by, updated_at)
  values (p_key, p_value, auth.uid(), now())
  on conflict (key) do update
    set value = excluded.value,
        updated_by = excluded.updated_by,
        updated_at = excluded.updated_at;
  perform _audit('PlatformSettingChanged', 'setting', null,
                 jsonb_build_object('key', p_key, 'old', old_value, 'new', p_value));
end;
$$;
grant execute on function admin_set_setting(text, text) to authenticated;

create or replace function admin_resolve_moderation(
  p_log_id uuid, p_action text, p_notes text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  m record;
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  if p_action not in ('warn','suspend','ban','dismissed') then
    raise exception 'invalid_action';
  end if;
  select * into m from moderation_log where id = p_log_id;
  if m is null then raise exception 'log_not_found'; end if;

  update moderation_log
     set action = p_action,
         notes = p_notes,
         resolved_at = now()
   where id = p_log_id;
  perform _audit('ModerationResolved', 'moderation', p_log_id,
                 jsonb_build_object('action', p_action, 'user', m.user_id));
end;
$$;
grant execute on function admin_resolve_moderation(uuid, text, text) to authenticated;

create or replace function user_report_content(
  p_target_user uuid, p_field text, p_reason text, p_excerpt text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  rid uuid;
begin
  if auth.uid() is null then raise exception 'not_authenticated'; end if;
  if auth.uid() = p_target_user then raise exception 'cannot_report_self'; end if;
  insert into moderation_log(user_id, reporter_id, field, reason, excerpt)
  values (p_target_user, auth.uid(), p_field, p_reason, p_excerpt)
  returning id into rid;
  return rid;
end;
$$;
grant execute on function user_report_content(uuid, text, text, text) to authenticated;
