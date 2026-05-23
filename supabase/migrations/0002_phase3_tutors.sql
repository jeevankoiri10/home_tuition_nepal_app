-- Home Tuition Nepal — Phase 3 schema (tutor profile builder).
-- Run after 0001_phase2_profiles.sql.

-- ───────────────────────────────────────────────────────────────────────────
-- tutors — 1:1 with profiles where role='tutor'.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists tutors (
  id                       uuid primary key references profiles(id) on delete cascade,
  teaching_mode            text not null check (teaching_mode in ('online','offline','both')) default 'offline',
  levels_taught            text[] not null default '{}',
  languages_known          text[] not null default '{}',
  native_language          text,
  about_me                 text,
  about_sessions           text,
  qualifications           text,
  tagline                  text,
  meta_keywords            text[] not null default '{}',
  country                  text default 'Nepal',
  zone                     text,
  city                     text,
  address_line             text,
  service_radius_km        numeric default 5,
  available                boolean not null default false,
  verified                 boolean not null default false,
  draft_status             text not null check (draft_status in ('draft','published')) default 'draft',
  profile_completion       smallint not null default 0,
  experience_offline_years numeric not null default 0,
  experience_online_years  numeric not null default 0,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

drop trigger if exists trg_tutors_updated_at on tutors;
create trigger trg_tutors_updated_at
  before update on tutors
  for each row execute function set_updated_at();

-- ───────────────────────────────────────────────────────────────────────────
-- tutor_offerings — authoritative (level, subject, price) per tutor.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists tutor_offerings (
  id            uuid primary key default uuid_generate_v4(),
  tutor_id      uuid not null references profiles(id) on delete cascade,
  level         text not null check (level in ('below_class_9','see','plus_2','a_level')),
  subject       text not null,
  price_min_npr numeric not null check (price_min_npr >= 0),
  price_max_npr numeric check (price_max_npr is null or price_max_npr >= price_min_npr),
  price_period  text not null check (price_period in ('hour','day','month','session')) default 'month',
  unique (tutor_id, level, subject)
);

create index if not exists tutor_offerings_tutor_idx on tutor_offerings(tutor_id);

-- ───────────────────────────────────────────────────────────────────────────
-- tutor_availability — single row per tutor; 3 time-bands × 7 days as JSONB.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists tutor_availability (
  tutor_id   uuid primary key references profiles(id) on delete cascade,
  slots      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- ───────────────────────────────────────────────────────────────────────────
-- tutor_education / tutor_experience / tutor_certificates — all optional.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists tutor_education (
  id             uuid primary key default uuid_generate_v4(),
  tutor_id       uuid not null references profiles(id) on delete cascade,
  degree         text,
  institution    text,
  field_of_study text,
  start_year     smallint,
  end_year       smallint,
  description    text,
  sort_order     smallint not null default 0
);

create table if not exists tutor_experience (
  id           uuid primary key default uuid_generate_v4(),
  tutor_id     uuid not null references profiles(id) on delete cascade,
  role_title   text,
  organization text,
  start_year   smallint,
  end_year     smallint,
  description  text,
  sort_order   smallint not null default 0
);

create table if not exists tutor_certificates (
  id           uuid primary key default uuid_generate_v4(),
  tutor_id     uuid not null references profiles(id) on delete cascade,
  title        text,
  issuer       text,
  year_awarded smallint,
  file_path    text,
  sort_order   smallint not null default 0
);

-- ───────────────────────────────────────────────────────────────────────────
-- Profile-completion computation.
-- A simple weighted sum that mirrors the client-side helper, so server is the
-- source of truth. The score is recomputed on every tutor write and reflected
-- back into tutors.profile_completion.
-- ───────────────────────────────────────────────────────────────────────────
create or replace function compute_tutor_completion(t_id uuid)
returns smallint
language sql
as $$
  with t as (select * from tutors where id = t_id),
       o_count as (select count(*) c from tutor_offerings where tutor_id = t_id),
       avail as (select slots from tutor_availability where tutor_id = t_id)
  select greatest(0, least(100,
    (case when (select teaching_mode from t) is not null then 10 else 0 end) +
    (case when array_length((select levels_taught from t), 1) > 0 then 15 else 0 end) +
    (case when (select c from o_count) > 0 then 20 else 0 end) +
    (case when (select c from o_count) >= 3 then 5  else 0 end) +
    (case when coalesce(length((select about_me from t)),0)       >= 100 then 10 else 0 end) +
    (case when coalesce(length((select about_sessions from t)),0) >= 50  then 10 else 0 end) +
    (case when coalesce(length((select qualifications from t)),0) >= 30  then 10 else 0 end) +
    (case when (select slots from avail) is not null
              and jsonb_typeof((select slots from avail)) = 'object'
              and (select count(*) from jsonb_each((select slots from avail))) > 0
              then 15 else 0 end) +
    (case when array_length((select languages_known from t), 1) > 0 then 5 else 0 end)
  ))::smallint;
$$;

create or replace function refresh_tutor_completion() returns trigger
language plpgsql as $$
declare
  tid uuid;
begin
  tid := coalesce(new.tutor_id, new.id);
  update tutors set profile_completion = compute_tutor_completion(tid) where id = tid;
  return new;
end;
$$;

drop trigger if exists trg_tutors_refresh_completion on tutors;
create trigger trg_tutors_refresh_completion
  after insert or update on tutors
  for each row execute function refresh_tutor_completion();

drop trigger if exists trg_tutor_offerings_refresh on tutor_offerings;
create trigger trg_tutor_offerings_refresh
  after insert or update or delete on tutor_offerings
  for each row execute function refresh_tutor_completion();

drop trigger if exists trg_tutor_availability_refresh on tutor_availability;
create trigger trg_tutor_availability_refresh
  after insert or update or delete on tutor_availability
  for each row execute function refresh_tutor_completion();

-- ───────────────────────────────────────────────────────────────────────────
-- RLS — owner-only for now. Public-facing reads will go through a security-definer
-- RPC in Phase 4 that strips private columns and returns masked names.
-- ───────────────────────────────────────────────────────────────────────────
alter table tutors enable row level security;
alter table tutor_offerings enable row level security;
alter table tutor_availability enable row level security;
alter table tutor_education enable row level security;
alter table tutor_experience enable row level security;
alter table tutor_certificates enable row level security;

do $$
declare t text;
begin
  foreach t in array array['tutors','tutor_availability'] loop
    execute format('drop policy if exists %I_owner on %I', t || '_owner', t);
    execute format('create policy %I_owner on %I for all using (auth.uid() = %s) with check (auth.uid() = %s)',
      t || '_owner', t,
      case when t = 'tutors' then 'id' else 'tutor_id' end,
      case when t = 'tutors' then 'id' else 'tutor_id' end);
  end loop;
  foreach t in array array['tutor_offerings','tutor_education','tutor_experience','tutor_certificates'] loop
    execute format('drop policy if exists %I_owner on %I', t || '_owner', t);
    execute format('create policy %I_owner on %I for all using (auth.uid() = tutor_id) with check (auth.uid() = tutor_id)',
      t || '_owner', t);
  end loop;
end$$;
