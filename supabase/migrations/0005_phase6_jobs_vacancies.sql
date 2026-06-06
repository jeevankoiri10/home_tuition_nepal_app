-- Home Tuition Nepal — Phase 6 schema (student request flows).
-- Run after 0004_phase5_wallet.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- jobs — Upwork-style student-posted jobs. The student can post directly;
-- tutors bid (Phase 7).
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists jobs (
  id                    uuid primary key default uuid_generate_v4(),
  student_id            uuid not null references profiles(id) on delete cascade,
  job_type              text not null check (job_type in ('home_tuition','online_tuition','assignment_help')) default 'home_tuition',
  title                 text not null,
  description           text,
  subject               text,
  grade_level           text,
  area_label            text,
  geog                  geography(Point, 4326),
  schedule              text,
  engagement_type       text check (engagement_type in ('full_time','part_time','one_off')),
  due_date              date,
  budget_min_npr        numeric,
  budget_max_npr        numeric,
  budget_period         text check (budget_period in ('hour','day','month','session','fixed')) default 'month',
  mode                  text not null check (mode in ('in-person','online','either')) default 'in-person',
  gender_pref           text not null check (gender_pref in ('any','male','female')) default 'any',
  communicate_languages text[] not null default '{}',
  can_travel            boolean default true,
  status                text not null check (status in ('open','shortlisting','hired','closed','expired')) default 'open',
  promoted_until        timestamptz,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create index if not exists jobs_student_idx on jobs(student_id, created_at desc);
create index if not exists jobs_status_idx on jobs(status);
create index if not exists jobs_geog_gix on jobs using gist (geog);

drop trigger if exists trg_jobs_updated_at on jobs;
create trigger trg_jobs_updated_at
  before update on jobs
  for each row execute function set_updated_at();

alter table jobs enable row level security;

drop policy if exists jobs_select_open on jobs;
create policy jobs_select_open
  on jobs for select
  using (status = 'open' or auth.uid() = student_id);

drop policy if exists jobs_insert_self on jobs;
create policy jobs_insert_self
  on jobs for insert
  with check (auth.uid() = student_id);

drop policy if exists jobs_update_self on jobs;
create policy jobs_update_self
  on jobs for update
  using (auth.uid() = student_id)
  with check (auth.uid() = student_id);

drop policy if exists jobs_delete_self on jobs;
create policy jobs_delete_self
  on jobs for delete
  using (auth.uid() = student_id);

-- ────────────────────────────────────────────────────────────────────────────
-- vacancies — admin-curated tuition postings. Students can SUBMIT a request
-- (it lands in 'pending_admin_review'); admins later publish to 'open'.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists vacancies (
  id                uuid primary key default uuid_generate_v4(),
  code              text unique,
  title             text not null,
  posted_by_admin   uuid references admin_users(id),
  linked_student    uuid references profiles(id) on delete set null,
  area_label        text not null,
  geog              geography(Point, 4326),
  num_students      integer not null default 1,
  grade             text,
  subjects          text[] not null default '{}',
  duration_text     text,
  start_time        time,
  end_time          time,
  frequency         text check (frequency in ('per_month','per_week','one_off')) default 'per_month',
  salary_min_npr    numeric,
  salary_max_npr    numeric,
  salary_period     text check (salary_period in ('month','hour','session')) default 'month',
  gender_pref       text check (gender_pref in ('any','male','female')) default 'any',
  mode              text check (mode in ('in-person','online','either')) default 'in-person',
  notes             text,
  status            text not null check (status in ('pending_admin_review','open','applications_closed','filled','cancelled')) default 'pending_admin_review',
  filled_by_tutor   uuid references profiles(id),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists vacancies_status_idx on vacancies(status);
create index if not exists vacancies_linked_student_idx on vacancies(linked_student);
create index if not exists vacancies_geog_gix on vacancies using gist (geog);

drop trigger if exists trg_vacancies_updated_at on vacancies;
create trigger trg_vacancies_updated_at
  before update on vacancies
  for each row execute function set_updated_at();

-- Sequence for HTN-NNNNN codes; assigned on publish (not on draft insert).
create sequence if not exists vacancies_code_seq;

create or replace function assign_vacancy_code() returns trigger
language plpgsql as $$
begin
  if new.status = 'open' and new.code is null then
    new.code := 'HTN-' || lpad(nextval('vacancies_code_seq')::text, 5, '0');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_vacancies_assign_code on vacancies;
create trigger trg_vacancies_assign_code
  before insert or update of status on vacancies
  for each row execute function assign_vacancy_code();

alter table vacancies enable row level security;

-- Anyone authenticated can read published vacancies; the student who linked it
-- can also see their pending draft.
drop policy if exists vacancies_select_visible on vacancies;
create policy vacancies_select_visible
  on vacancies for select
  using (
    status in ('open', 'applications_closed', 'filled')
    or auth.uid() = linked_student
    or exists (select 1 from admin_users where id = auth.uid())
  );

-- Students insert a draft vacancy as themselves. Admins insert too.
drop policy if exists vacancies_insert on vacancies;
create policy vacancies_insert
  on vacancies for insert
  with check (
    (auth.uid() = linked_student and status = 'pending_admin_review')
    or exists (select 1 from admin_users where id = auth.uid())
  );

-- Only admins can update / delete (the publish flow is admin-mediated).
drop policy if exists vacancies_admin_write on vacancies;
create policy vacancies_admin_write
  on vacancies for update
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- ────────────────────────────────────────────────────────────────────────────
-- notify_matching_tutors — Phase 6 stub. Fans out a placeholder notification
-- when a job opens or a vacancy is published. Real push (FCM/OneSignal)
-- lands in Phase 8 — for now just inserts into `notifications`.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function notify_matching_tutors() returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  body text;
  ref  text;
begin
  if tg_table_name = 'jobs' and new.status = 'open' then
    body := coalesce(new.title, 'New job posted') || ' in ' || coalesce(new.area_label, '—');
    ref  := 'job';
  elsif tg_table_name = 'vacancies' and new.status = 'open' then
    body := coalesce(new.title, 'New vacancy') || ' — ' || coalesce(new.area_label, '—');
    ref  := 'vacancy';
  else
    return new;
  end if;

  insert into notifications(user_id, kind, title, body, ref_type, ref_id)
  select t.id, 'new_job_posted', 'New job posted', body, ref, new.id
    from tutors t
    join profiles p on p.id = t.id
   where t.draft_status = 'published'
     and (
       new.geog is null
       or t.geog is null
       or st_dwithin(t.geog, new.geog, coalesce(t.service_radius_km, 5) * 1000)
     );
  return new;
end;
$$;

drop trigger if exists trg_jobs_notify on jobs;
create trigger trg_jobs_notify
  after insert or update of status on jobs
  for each row execute function notify_matching_tutors();

drop trigger if exists trg_vacancies_notify on vacancies;
create trigger trg_vacancies_notify
  after insert or update of status on vacancies
  for each row execute function notify_matching_tutors();
