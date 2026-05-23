-- Home Tuition Nepal — Phase 7 schema (vacancy applications + admin matching).
-- Run after 0005_phase6_jobs_vacancies.sql.

create table if not exists vacancy_applications (
  id              uuid primary key default uuid_generate_v4(),
  vacancy_id      uuid not null references vacancies(id) on delete cascade,
  tutor_id        uuid not null references profiles(id) on delete cascade,
  cover_note      text,
  expected_rate   numeric,
  cv_storage_path text,
  status          text not null check (status in ('pending','shortlisted','rejected','hired')) default 'pending',
  coins_spent     integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (vacancy_id, tutor_id)
);

create index if not exists vacancy_applications_vacancy_idx on vacancy_applications(vacancy_id, created_at desc);
create index if not exists vacancy_applications_tutor_idx on vacancy_applications(tutor_id, created_at desc);

drop trigger if exists trg_vacancy_applications_updated_at on vacancy_applications;
create trigger trg_vacancy_applications_updated_at
  before update on vacancy_applications
  for each row execute function set_updated_at();

alter table vacancy_applications enable row level security;

-- Tutor sees their own applications; admin sees all.
drop policy if exists vacancy_applications_select on vacancy_applications;
create policy vacancy_applications_select
  on vacancy_applications for select
  using (
    auth.uid() = tutor_id
    or exists (select 1 from admin_users where id = auth.uid())
  );

-- Tutors create their own application rows.
drop policy if exists vacancy_applications_insert_self on vacancy_applications;
create policy vacancy_applications_insert_self
  on vacancy_applications for insert
  with check (auth.uid() = tutor_id);

-- Only admins update status.
drop policy if exists vacancy_applications_admin_update on vacancy_applications;
create policy vacancy_applications_admin_update
  on vacancy_applications for update
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- ────────────────────────────────────────────────────────────────────────────
-- apply_to_vacancy is already defined in 0004_phase5_wallet.sql for the coin
-- debit; here we wrap it with an INSERT so the application row is recorded
-- inside the same transaction (debit + insert are atomic).
-- ────────────────────────────────────────────────────────────────────────────
create or replace function tutor_apply_to_vacancy(
  p_vacancy_id   uuid,
  p_cover_note   text,
  p_expected_rate numeric,
  p_cv_path      text default null
) returns uuid
language plpgsql
security definer
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

  return app_id;
end;
$$;
grant execute on function tutor_apply_to_vacancy(uuid, text, numeric, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- admin_assign_vacancy — admin marks the application hired, sets the
-- vacancy's filled_by_tutor, flips status to 'filled', and produces a
-- contact-revealed notification for both parties.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function admin_assign_vacancy(p_application_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  v_id         uuid;
  v_student    uuid;
  v_tutor      uuid;
  v_title      text;
  v_code       text;
begin
  if not exists (select 1 from admin_users where id = caller) then
    raise exception 'not_admin';
  end if;

  select a.vacancy_id, a.tutor_id, v.linked_student, v.title, v.code
    into v_id, v_tutor, v_student, v_title, v_code
    from vacancy_applications a
    join vacancies v on v.id = a.vacancy_id
   where a.id = p_application_id;

  if v_id is null then raise exception 'application_not_found'; end if;

  update vacancy_applications set status = 'hired'    where id  = p_application_id;
  update vacancy_applications set status = 'rejected' where vacancy_id = v_id and id <> p_application_id and status = 'pending';
  update vacancies set status = 'filled', filled_by_tutor = v_tutor where id = v_id;

  -- Notify both parties — phone numbers are revealed only inside the in-app
  -- Contact-revealed sheet wired in Phase 7 client code (lib/features/...).
  insert into notifications(user_id, kind, title, body, ref_type, ref_id)
  values
    (v_tutor,   'contact_revealed', 'You were matched',  'You''ve been selected for ' || coalesce(v_code, v_title) || '. Tap to view contact.', 'vacancy', v_id),
    (v_student, 'contact_revealed', 'Tutor assigned',    'Admin matched you with a tutor for ' || coalesce(v_code, v_title) || '. Tap to view contact.', 'vacancy', v_id);
end;
$$;
grant execute on function admin_assign_vacancy(uuid) to authenticated;
