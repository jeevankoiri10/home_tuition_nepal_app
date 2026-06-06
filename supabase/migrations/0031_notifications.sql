-- Home Tuition Nepal — Phase 16: notifications system.
-- Run after 0030_presence_last_seen.sql.
--
-- Builds on the existing in-app `notifications` table (0001) and the
-- `notify_matching_tutors()` / `tutor_apply_to_vacancy()` insert sites by:
--   1. a notification-type registry the admin can enable/disable per kind,
--      gating every server-side insert (and read back by the app to hide
--      disabled kinds in the feed);
--   2. notifying the linked student when a tutor applies to their vacancy;
--   3. matching tutors to new jobs/vacancies on AREA *and* SUBJECT, not just
--      proximity;
--   4. admin broadcasts that fan out to All / Students / Tutors on recurring
--      daily morning/day/evening slots (Asia/Kathmandu) via pg_cron, plus a
--      manual "send now" path;
--   5. per-user language + quiet-hours columns the FCM dispatcher reads.

-- ───────────────────────────────────────────────────────────────────────────
-- A5. Per-user language + quiet hours (push). `push_token` already exists (0013).
-- ───────────────────────────────────────────────────────────────────────────
alter table profiles add column if not exists language          text default 'en';
alter table profiles add column if not exists quiet_hours_start time;
alter table profiles add column if not exists quiet_hours_end   time;

insert into platform_settings (key, value)
values ('notif_hourly_cap', '20')
on conflict (key) do nothing;

-- ───────────────────────────────────────────────────────────────────────────
-- A1. Notification-type registry. One row per `notifications.kind`. The admin
-- toggles `enabled`; every insert site gates on notif_kind_enabled(kind), and
-- the app reads this table to hide disabled kinds from the feed.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists notification_settings (
  kind        text primary key,
  label       text not null,
  audience    text not null check (audience in ('student','tutor','all')),
  enabled     boolean not null default true,
  updated_by  uuid references admin_users(id),
  updated_at  timestamptz not null default now()
);

insert into notification_settings (kind, label, audience) values
  ('new_job_posted',                 'New job posted (matched tutors)', 'tutor'),
  ('tutor_applied',                  'Tutor applied to your job',       'student'),
  ('application_shortlisted',        'Application shortlisted',         'tutor'),
  ('application_hired',              'You were hired',                  'tutor'),
  ('contact_revealed',              'Contact revealed / matched',      'all'),
  ('identity_verification_approved', 'Identity verification approved',  'tutor'),
  ('identity_verification_rejected', 'Identity verification rejected',  'tutor'),
  ('coin_credited',                  'Coins credited',                 'all'),
  ('coin_debited',                   'Coins debited',                  'all'),
  ('new_review',                     'New review',                     'all'),
  ('announcement',                   'Admin announcement / broadcast',  'all'),
  ('system',                         'System message',                 'all')
on conflict (kind) do nothing;

drop trigger if exists trg_notification_settings_updated_at on notification_settings;
create trigger trg_notification_settings_updated_at
  before update on notification_settings
  for each row execute function set_updated_at();

alter table notification_settings enable row level security;

-- Any signed-in user may read the toggles (the app hides disabled kinds).
drop policy if exists notification_settings_select_all on notification_settings;
create policy notification_settings_select_all
  on notification_settings for select
  using (auth.uid() is not null);

-- Only admins change them.
drop policy if exists notification_settings_admin_write on notification_settings;
create policy notification_settings_admin_write
  on notification_settings for all
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- Gate helper: a kind defaults to enabled when no row exists.
create or replace function notif_kind_enabled(p_kind text) returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select enabled from notification_settings where kind = p_kind), true);
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- A3. Tutor matching on AREA *and* SUBJECT. Replaces the location-only stub
-- from 0005. Keeps the geo-radius check and adds a subject join against
-- tutor_offerings. When the post specifies no subject, falls back to geo only.
-- The triggers (trg_jobs_notify / trg_vacancies_notify) from 0005 are unchanged
-- and keep calling this function.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function notify_matching_tutors() returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  body             text;
  ref              text;
  v_subject_single text;    -- jobs.subject (single)
  v_subjects       text[];  -- vacancies.subjects (array)
  v_match_subject  boolean; -- whether to require a subject match
begin
  if not notif_kind_enabled('new_job_posted') then
    return new;
  end if;

  if tg_table_name = 'jobs' and new.status = 'open' then
    body := coalesce(new.title, 'New job posted') || ' in ' || coalesce(new.area_label, '—');
    ref  := 'job';
    v_subject_single := new.subject;
    v_match_subject  := new.subject is not null;
  elsif tg_table_name = 'vacancies' and new.status = 'open' then
    body := coalesce(new.title, 'New vacancy') || ' — ' || coalesce(new.area_label, '—');
    ref  := 'vacancy';
    v_subjects      := new.subjects;
    v_match_subject := coalesce(array_length(new.subjects, 1), 0) > 0;
  else
    return new;
  end if;

  insert into notifications(user_id, kind, title, body, ref_type, ref_id)
  select t.id, 'new_job_posted', 'New job posted', body, ref, new.id
    from tutors t
    join profiles p on p.id = t.id
   where t.draft_status = 'published'
     -- AREA: within the tutor's service radius (or unknown geo → don't exclude).
     and (
       new.geog is null
       or t.geog is null
       or st_dwithin(t.geog, new.geog, coalesce(t.service_radius_km, 5) * 1000)
     )
     -- SUBJECT: the tutor offers the posted subject (case-insensitive). Only
     -- enforced when the post names a subject.
     and (
       not v_match_subject
       or exists (
         select 1
           from tutor_offerings o
          where o.tutor_id = t.id
            and (
              (tg_table_name = 'jobs'
                 and lower(o.subject) = lower(v_subject_single))
              or (tg_table_name = 'vacancies'
                 and exists (select 1 from unnest(v_subjects) s
                              where lower(s) = lower(o.subject)))
            )
       )
     );
  return new;
end;
$$;

-- ───────────────────────────────────────────────────────────────────────────
-- A2. Notify the linked student when a tutor applies. Re-defines
-- tutor_apply_to_vacancy() from 0006 — identical coin/insert logic, plus a
-- `tutor_applied` notification for vacancies.linked_student.
-- ───────────────────────────────────────────────────────────────────────────
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

  -- Atomically debit coins via the existing helper, then insert the row.
  perform _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id, 'Applied to vacancy'
  );

  insert into vacancy_applications(vacancy_id, tutor_id, cover_note, expected_rate, cv_storage_path, coins_spent)
  values (p_vacancy_id, caller, p_cover_note, p_expected_rate, p_cv_path, cost)
  returning id into app_id;

  -- Notify the student who owns the linked job post that a tutor applied.
  if notif_kind_enabled('tutor_applied') then
    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    select v.linked_student, 'tutor_applied', 'New application',
           'A tutor applied to ' || coalesce(v.code, v.title) || '. Tap to review.',
           'vacancy', v.id
      from vacancies v
     where v.id = p_vacancy_id
       and v.linked_student is not null;
  end if;

  return app_id;
end;
$$;
grant execute on function tutor_apply_to_vacancy(uuid, text, numeric, text) to authenticated;

-- ───────────────────────────────────────────────────────────────────────────
-- A4. Admin broadcasts — recurring daily slots (Asia/Kathmandu), fanned out by
-- pg_cron, plus a manual send-now path.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists notification_broadcasts (
  id            uuid primary key default uuid_generate_v4(),
  title_en      text not null,
  body_en       text,
  title_ne      text not null,
  body_ne       text,
  audience      text not null check (audience in ('all','student','tutor')),
  slot          text not null check (slot in ('morning','day','evening')),
  send_at_local time not null,           -- local Kathmandu time, e.g. 08:00
  enabled       boolean not null default true,
  last_sent_on  date,                    -- once-per-day idempotency guard
  created_by    uuid references admin_users(id),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists notification_broadcasts_active_idx
  on notification_broadcasts (enabled, send_at_local);

drop trigger if exists trg_notification_broadcasts_updated_at on notification_broadcasts;
create trigger trg_notification_broadcasts_updated_at
  before update on notification_broadcasts
  for each row execute function set_updated_at();

alter table notification_broadcasts enable row level security;

-- Admin-only: normal users never read the broadcast definitions (they receive
-- the fanned-out `notifications` rows instead).
drop policy if exists notification_broadcasts_admin_all on notification_broadcasts;
create policy notification_broadcasts_admin_all
  on notification_broadcasts for all
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- Fan a single broadcast out to its audience, picking each user's language.
-- Returns the number of recipients. Skips banned users.
create or replace function _fan_out_broadcast(p_id uuid) returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  b           notification_broadcasts%rowtype;
  n_recipients int;
begin
  select * into b from notification_broadcasts where id = p_id;
  if b.id is null then return 0; end if;
  if not notif_kind_enabled('announcement') then return 0; end if;

  insert into notifications(user_id, kind, title, body, ref_type)
  select p.id, 'announcement',
         case when coalesce(p.language, 'en') = 'ne' then b.title_ne else b.title_en end,
         case when coalesce(p.language, 'en') = 'ne' then b.body_ne  else b.body_en  end,
         'notice'
    from profiles p
   where p.banned_at is null
     and (
       b.audience = 'all'
       or exists (select 1 from account_roles ar
                   where ar.user_id = p.id and ar.role = b.audience)
     );

  get diagnostics n_recipients = row_count;
  return n_recipients;
end;
$$;

-- Cron entry point: fan out every enabled broadcast whose local send time has
-- passed today and that hasn't been sent yet today. Returns broadcasts fired.
create or replace function dispatch_due_broadcasts() returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  b         record;
  today_ktm date := (now() at time zone 'Asia/Kathmandu')::date;
  now_ktm   time := (now() at time zone 'Asia/Kathmandu')::time;
  fired     int  := 0;
begin
  for b in
    select id from notification_broadcasts
     where enabled
       and (last_sent_on is null or last_sent_on < today_ktm)
       and send_at_local <= now_ktm
     order by send_at_local
  loop
    perform _fan_out_broadcast(b.id);
    update notification_broadcasts set last_sent_on = today_ktm where id = b.id;
    fired := fired + 1;
  end loop;
  return fired;
end;
$$;

-- Manual send (admin "Send now"). Ignores time/last-sent gating; still respects
-- the announcement type toggle. Returns the recipient count. Unlike the older
-- auth.uid()-gated admin RPCs, this is locked down by EXECUTE grant: only the
-- service role (used by the admin panel behind assertAdmin) may call it, so it
-- needs no internal auth.uid() check — which would fail under the service role
-- anyway (auth.uid() is null there).
create or replace function admin_send_broadcast_now(p_id uuid) returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  n := _fan_out_broadcast(p_id);
  update notification_broadcasts
     set last_sent_on = (now() at time zone 'Asia/Kathmandu')::date
   where id = p_id;
  return n;
end;
$$;

-- These functions fan notifications out to many users (bypassing RLS via
-- SECURITY DEFINER). Lock them down so ordinary app users can't trigger mass
-- inserts: only the service role (admin panel) and the table owner (pg_cron)
-- may execute them.
-- Supabase grants EXECUTE on new public functions directly to anon/
-- authenticated (via default privileges), so revoking from PUBLIC alone is not
-- enough — revoke from those roles explicitly too.
revoke execute on function _fan_out_broadcast(uuid)       from public, authenticated, anon;
revoke execute on function dispatch_due_broadcasts()      from public, authenticated, anon;
revoke execute on function admin_send_broadcast_now(uuid) from public, authenticated, anon;
grant  execute on function admin_send_broadcast_now(uuid) to service_role;
grant  execute on function dispatch_due_broadcasts()      to service_role;

-- Schedule the dispatcher every 15 minutes via pg_cron. Wrapped so the
-- migration still succeeds where pg_cron isn't available — in that case call
-- dispatch_due_broadcasts() from an external scheduler (e.g. a cron-triggered
-- Edge Function).
do $$
begin
  execute 'create extension if not exists pg_cron';
  begin
    perform cron.unschedule('htn_dispatch_broadcasts');
  exception when others then null;
  end;
  perform cron.schedule('htn_dispatch_broadcasts', '*/15 * * * *',
                        'select dispatch_due_broadcasts();');
exception when others then
  raise notice 'pg_cron not configured (%). Call dispatch_due_broadcasts() from an external scheduler.', sqlerrm;
end $$;
