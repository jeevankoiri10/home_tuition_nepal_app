-- ════════════════════════════════════════════════════════════════════
-- Home Tuition Nepal — full database setup
-- ════════════════════════════════════════════════════════════════════
-- Run this in the Supabase SQL editor against a fresh project to
-- create every table, RPC, RLS policy, trigger, sequence and view
-- the Flutter client expects. Concatenation of the numbered
-- migration files in supabase/migrations/ (in order).
--
-- Storage buckets must be created manually in the dashboard before
-- the policies inside this script take effect:
--   * tutor-cvs       (public read)
--   * topup-receipts  (public read)
-- ════════════════════════════════════════════════════════════════════



-- ════════════════════════════════════════════════════════════════════
-- 0001_phase2_profiles.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 2 schema.
-- Run against your Supabase project (psql or the SQL editor).
-- Subsequent phases add tutors, vacancies, jobs, wallet_ledger, etc.

-- Required Postgres extensions.
create extension if not exists "uuid-ossp";

-- ───────────────────────────────────────────────────────────────────────────
-- profiles
-- 1:1 with auth.users. Real name + phone + email are private columns,
-- protected by RLS and revealed only via security-definer RPCs after a
-- successful contact unlock or admin assignment (see plan.md §5.5).
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists profiles (
  id                            uuid primary key references auth.users(id) on delete cascade,
  handle                        text unique not null,
  first_name                    text not null,
  last_name                     text not null,
  email                         text,
  phone                         text,                            -- E.164, e.g. +9779812345678
  phone_verified                boolean not null default false,
  role                          text not null check (role in ('student','tutor')),
  tos_accepted_at               timestamptz not null,
  code_of_conduct_accepted_at   timestamptz,                     -- tutors only
  coin_balance                  integer not null default 0,
  created_at                    timestamptz not null default now(),
  updated_at                    timestamptz not null default now()
);

create index if not exists profiles_role_idx on profiles(role);

-- Role is permanent — block updates that would change it.
create or replace function block_role_change() returns trigger
language plpgsql as $$
begin
  if new.role is distinct from old.role then
    raise exception 'profiles.role is immutable after first set';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_profiles_block_role_change on profiles;
create trigger trg_profiles_block_role_change
  before update on profiles
  for each row execute function block_role_change();

-- Tutors must accept the Code of Conduct.
create or replace function require_coc_for_tutors() returns trigger
language plpgsql as $$
begin
  if new.role = 'tutor' and new.code_of_conduct_accepted_at is null then
    raise exception 'Tutors must accept the Code of Conduct';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_profiles_require_coc on profiles;
create trigger trg_profiles_require_coc
  before insert or update on profiles
  for each row execute function require_coc_for_tutors();

-- Touch updated_at automatically.
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on profiles;
create trigger trg_profiles_updated_at
  before update on profiles
  for each row execute function set_updated_at();

-- ───────────────────────────────────────────────────────────────────────────
-- RLS for profiles
-- An authenticated user can read their own row and write their own row,
-- except role / coin_balance which are server-managed.
-- ───────────────────────────────────────────────────────────────────────────
alter table profiles enable row level security;

drop policy if exists profiles_select_self on profiles;
create policy profiles_select_self
  on profiles for select
  using (auth.uid() = id);

drop policy if exists profiles_insert_self on profiles;
create policy profiles_insert_self
  on profiles for insert
  with check (auth.uid() = id);

drop policy if exists profiles_update_self on profiles;
create policy profiles_update_self
  on profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Counterparties never read private columns directly; do it via security-definer
-- RPCs in later phases. This keeps real_name / email / phone leak-proof.

-- ───────────────────────────────────────────────────────────────────────────
-- admin_users
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists admin_users (
  id          uuid primary key references auth.users(id) on delete cascade,
  role        text not null check (role in ('superadmin','operator','moderator')),
  created_at  timestamptz not null default now()
);

alter table admin_users enable row level security;

-- ───────────────────────────────────────────────────────────────────────────
-- platform_settings — admin-editable runtime config.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists platform_settings (
  key         text primary key,
  value       text,
  updated_by  uuid references admin_users(id),
  updated_at  timestamptz not null default now()
);

insert into platform_settings (key, value) values
  ('admin_whatsapp',         'https://wa.me/9779807590455'),
  ('signup_coin_grant',      '1000'),
  ('apply_coin_cost',        '1'),
  ('unlock_coin_cost',       '5'),
  ('featured_listing_cost',  '50'),
  ('pinned_bid_cost',        '20'),
  ('promoted_job_cost',      '20')
on conflict (key) do nothing;

alter table platform_settings enable row level security;

drop policy if exists platform_settings_select_public on platform_settings;
create policy platform_settings_select_public
  on platform_settings for select
  using (true);

-- ───────────────────────────────────────────────────────────────────────────
-- notifications — populated by triggers in later phases; readable by owner.
-- ───────────────────────────────────────────────────────────────────────────
create table if not exists notifications (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references profiles(id) on delete cascade,
  kind        text not null,
  title       text not null,
  body        text,
  ref_type    text,
  ref_id      uuid,
  read_at     timestamptz,
  created_at  timestamptz not null default now()
);

create index if not exists notifications_user_id_idx on notifications(user_id, created_at desc);

alter table notifications enable row level security;

drop policy if exists notifications_select_self on notifications;
create policy notifications_select_self
  on notifications for select
  using (auth.uid() = user_id);

drop policy if exists notifications_update_self on notifications;
create policy notifications_update_self
  on notifications for update
  using (auth.uid() = user_id);


-- ════════════════════════════════════════════════════════════════════
-- 0002_phase3_tutors.sql
-- ════════════════════════════════════════════════════════════════════

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


-- ════════════════════════════════════════════════════════════════════
-- 0003_phase4_map.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 4 schema (map view + locality search).
-- Run after 0002_phase3_tutors.sql.

create extension if not exists postgis;

-- Add a PostGIS Point column to tutors. The map only queries this; tutors who
-- haven't dropped a pin yet (geog is null) are excluded from map results but
-- still surface in the list view.
alter table tutors add column if not exists geog geography(Point, 4326);
create index if not exists tutors_geog_gix on tutors using gist (geog);

-- Helper that the client calls to update its own pin (lat/lng) without
-- needing to construct WKT on the client.
create or replace function set_tutor_geog(p_lat double precision, p_lng double precision)
returns void
language plpgsql
security definer
as $$
begin
  update tutors
     set geog = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
   where id = auth.uid();
end;
$$;
grant execute on function set_tutor_geog(double precision, double precision) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- search_tutors_in_viewport
-- The single RPC the map calls on every viewport change. Returns ONLY masked /
-- public fields — no real name, no phone, no exact address. Privacy guard is
-- centralized here so the client cannot bypass it.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function search_tutors_in_viewport(
  p_lat            double precision,
  p_lng            double precision,
  p_radius_km      double precision default 5,
  p_level          text default null,           -- one of student-level values, or null = any
  p_subject        text default null,           -- single-subject substring match, or null
  p_mode           text default null,           -- 'online' | 'offline' | 'both' | null
  p_verified_only  boolean default false,
  p_available_only boolean default false,
  p_max_results    int default 50
)
returns table (
  tutor_id            uuid,
  handle              text,
  masked_name         text,
  tagline             text,
  area_label          text,
  teaching_mode       text,
  levels_taught       text[],
  verified            boolean,
  available           boolean,
  rating              numeric,
  rating_count        integer,
  experience_offline  numeric,
  experience_online   numeric,
  lat                 double precision,
  lng                 double precision,
  distance_km         double precision,
  from_price_npr      numeric,
  from_price_period   text,
  top_subjects        text[]
) language plpgsql stable
as $$
begin
  return query
  with viewer as (select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g),
       matched as (
    select t.*,
           p.handle,
           p.first_name || ' ' || left(p.last_name, 1) || '*' as masked_name,
           p.city,
           p.address_line,
           coalesce(p.address_line, p.city, '') as area_label,
           st_distance(t.geog, viewer.g) / 1000.0 as distance_km,
           st_y(t.geog::geometry) as lat,
           st_x(t.geog::geometry) as lng
      from tutors t
      join profiles p on p.id = t.id
      cross join viewer
     where t.geog is not null
       and t.draft_status = 'published'
       and st_dwithin(t.geog, viewer.g, p_radius_km * 1000)
       and (p_level is null or p_level = any (t.levels_taught))
       and (p_mode is null or t.teaching_mode = p_mode or t.teaching_mode = 'both')
       and (not p_verified_only or t.verified)
       and (not p_available_only or t.available)
       and (
            p_subject is null
            or exists (
              select 1 from tutor_offerings o
               where o.tutor_id = t.id
                 and (p_level is null or o.level = p_level)
                 and o.subject ilike '%' || p_subject || '%'
            )
           )
  ),
  enriched as (
    select m.*,
           (
             select array_agg(distinct o.subject)
               from (
                 select subject
                   from tutor_offerings
                  where tutor_id = m.id
                  order by price_min_npr asc
                  limit 3
               ) o
           ) as top_subjects,
           (select price_min_npr from tutor_offerings where tutor_id = m.id
              order by price_min_npr asc limit 1) as from_price_npr,
           (select price_period   from tutor_offerings where tutor_id = m.id
              order by price_min_npr asc limit 1) as from_price_period
      from matched m
  )
  select e.id,
         e.handle,
         e.masked_name,
         e.tagline,
         e.area_label,
         e.teaching_mode,
         e.levels_taught,
         e.verified,
         e.available,
         e.rating,
         e.rating_count,
         e.experience_offline_years,
         e.experience_online_years,
         e.lat,
         e.lng,
         e.distance_km,
         e.from_price_npr,
         e.from_price_period,
         e.top_subjects
    from enriched e
   order by e.available desc, e.verified desc, e.distance_km asc
   limit p_max_results;
end;
$$;
grant execute on function search_tutors_in_viewport(
  double precision, double precision, double precision,
  text, text, text, boolean, boolean, int
) to authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0004_phase5_wallet.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 5 schema (coin system & wallet).
-- Run after 0003_phase4_map.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- wallet_ledger — append-only. Authoritative source of every credit / debit.
-- profiles.coin_balance is a mirror updated by trigger; never trust the client.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists wallet_ledger (
  id             uuid primary key default uuid_generate_v4(),
  user_id        uuid not null references profiles(id) on delete cascade,
  delta          integer not null,
  reason         text not null check (reason in (
    'signup', 'apply', 'unlock', 'boost', 'topup',
    'reward', 'refund', 'admin'
  )),
  ref_type       text,                          -- 'job' | 'vacancy' | 'tutor' | null
  ref_id         uuid,
  balance_after  integer not null,
  description    text,                          -- short human-readable line for the wallet UI
  created_at     timestamptz not null default now()
);

create index if not exists wallet_ledger_user_idx on wallet_ledger(user_id, created_at desc);

alter table wallet_ledger enable row level security;

drop policy if exists wallet_ledger_select_self on wallet_ledger;
create policy wallet_ledger_select_self
  on wallet_ledger for select
  using (auth.uid() = user_id);

-- No insert/update/delete from the client — only via SECURITY DEFINER RPCs below.

-- Block any direct write attempts even if a policy is added by mistake.
create or replace function block_direct_ledger_writes() returns trigger
language plpgsql as $$
begin
  if current_setting('app.allow_ledger_write', true) is distinct from 'yes' then
    raise exception 'wallet_ledger is append-only via security-definer RPCs';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_wallet_ledger_block on wallet_ledger;
create trigger trg_wallet_ledger_block
  before insert or update or delete on wallet_ledger
  for each row execute function block_direct_ledger_writes();

-- ────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ────────────────────────────────────────────────────────────────────────────
create or replace function get_platform_setting_int(p_key text, p_default int default 0)
returns int
language sql
stable
as $$
  select coalesce(
    (select value::int from platform_settings where key = p_key),
    p_default
  );
$$;
grant execute on function get_platform_setting_int(text, int) to authenticated;

-- The single internal mutator. All RPCs go through this.
create or replace function _ledger_apply(
  p_user uuid,
  p_delta int,
  p_reason text,
  p_ref_type text,
  p_ref_id uuid,
  p_description text
) returns int
language plpgsql
security definer
as $$
declare
  new_balance int;
begin
  perform set_config('app.allow_ledger_write', 'yes', true);

  update profiles
     set coin_balance = coin_balance + p_delta
   where id = p_user
   returning coin_balance into new_balance;

  if new_balance is null then
    raise exception 'user not found';
  end if;

  if new_balance < 0 then
    raise exception 'insufficient_coins';
  end if;

  insert into wallet_ledger(user_id, delta, reason, ref_type, ref_id, balance_after, description)
  values (p_user, p_delta, p_reason, p_ref_type, p_ref_id, new_balance, p_description);

  return new_balance;
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- Signup grant — credit the configured `signup_coin_grant` on a brand-new
-- profile. Trigger fires AFTER INSERT on profiles.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function grant_signup_coins() returns trigger
language plpgsql
security definer
as $$
declare
  amount int;
begin
  amount := get_platform_setting_int('signup_coin_grant', 1000);
  if amount <= 0 then return new; end if;
  perform _ledger_apply(
    new.id, amount, 'signup', null, null, 'Welcome bonus on signup'
  );
  return new;
end;
$$;

drop trigger if exists trg_profiles_signup_grant on profiles;
create trigger trg_profiles_signup_grant
  after insert on profiles
  for each row execute function grant_signup_coins();

-- ────────────────────────────────────────────────────────────────────────────
-- Client-callable RPCs
-- ────────────────────────────────────────────────────────────────────────────
create or replace function unlock_contact(p_tutor_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  already      uuid;
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_tutor_id then raise exception 'cannot_unlock_self'; end if;

  -- One-time per (student, tutor) — if already unlocked, no debit.
  select id into already
    from wallet_ledger
   where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id
   limit 1;
  if already is not null then
    return (select coin_balance from profiles where id = caller);
  end if;

  cost := get_platform_setting_int('unlock_coin_cost', 5);
  new_balance := _ledger_apply(
    caller, -cost, 'unlock', 'tutor', p_tutor_id,
    'Unlocked contact for tutor'
  );
  return new_balance;
end;
$$;
grant execute on function unlock_contact(uuid) to authenticated;

create or replace function apply_to_vacancy(p_vacancy_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  cost := get_platform_setting_int('apply_coin_cost', 1);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id,
    'Applied to vacancy'
  );
  return new_balance;
end;
$$;
grant execute on function apply_to_vacancy(uuid) to authenticated;

create or replace function spend_coins_and_bid(p_job_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  cost := get_platform_setting_int('apply_coin_cost', 1);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'job', p_job_id,
    'Bid on job'
  );
  return new_balance;
end;
$$;
grant execute on function spend_coins_and_bid(uuid) to authenticated;

-- Admin-only manual adjustments.
create or replace function admin_credit(p_user uuid, p_delta int, p_reason_note text)
returns int
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
begin
  if not exists (select 1 from admin_users where id = caller) then
    raise exception 'not_admin';
  end if;
  return _ledger_apply(p_user, p_delta, 'admin', null, null, p_reason_note);
end;
$$;
grant execute on function admin_credit(uuid, int, text) to authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0005_phase6_jobs_vacancies.sql
-- ════════════════════════════════════════════════════════════════════

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


-- ════════════════════════════════════════════════════════════════════
-- 0006_phase7_vacancy_applications.sql
-- ════════════════════════════════════════════════════════════════════

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


-- ════════════════════════════════════════════════════════════════════
-- 0007_phase9_chat.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 9 schema (in-app chat).
-- Run after 0006_phase7_vacancy_applications.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- chat_threads — 1 row per (student, tutor) pair that has met the gate
-- (either the student unlocked the tutor's contact, OR an admin assigned
-- the tutor to one of the student's vacancies).
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists chat_threads (
  id              uuid primary key default uuid_generate_v4(),
  student_id      uuid not null references profiles(id) on delete cascade,
  tutor_id        uuid not null references profiles(id) on delete cascade,
  opened_via      text not null check (opened_via in ('contact_unlock','admin_assignment')),
  vacancy_id      uuid references vacancies(id) on delete set null,
  job_id          uuid references jobs(id)      on delete set null,
  last_message_at timestamptz,
  created_at      timestamptz not null default now(),
  unique (student_id, tutor_id)
);

create index if not exists chat_threads_student_idx on chat_threads(student_id, last_message_at desc nulls last);
create index if not exists chat_threads_tutor_idx   on chat_threads(tutor_id,   last_message_at desc nulls last);

alter table chat_threads enable row level security;

drop policy if exists chat_threads_select on chat_threads;
create policy chat_threads_select
  on chat_threads for select
  using (auth.uid() in (student_id, tutor_id));

-- ────────────────────────────────────────────────────────────────────────────
-- chat_messages — append-only by either party in the thread.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists chat_messages (
  id         uuid primary key default uuid_generate_v4(),
  thread_id  uuid not null references chat_threads(id) on delete cascade,
  sender_id  uuid not null references profiles(id),
  body       text not null check (length(body) > 0 and length(body) <= 2000),
  sent_at    timestamptz not null default now(),
  read_at    timestamptz
);

create index if not exists chat_messages_thread_idx on chat_messages(thread_id, sent_at);

alter table chat_messages enable row level security;

drop policy if exists chat_messages_select on chat_messages;
create policy chat_messages_select
  on chat_messages for select
  using (
    exists (
      select 1 from chat_threads t
       where t.id = chat_messages.thread_id
         and auth.uid() in (t.student_id, t.tutor_id)
    )
  );

-- ────────────────────────────────────────────────────────────────────────────
-- Server-side phone-ban regex — backstop the client validator.
-- Matches the heuristics in lib/core/utils/phone_ban_regex.dart:
--   • 7+ digits (allowing spaces/dashes/dots in between)
--   • email addresses
--   • wa.me / t.me / viber.me links
-- ────────────────────────────────────────────────────────────────────────────
create or replace function _has_phone_or_contact(p_text text)
returns boolean
language plpgsql
immutable
as $$
declare
  digit_count int;
begin
  if p_text ~* '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' then return true; end if;
  if p_text ~* '(wa\.me/|t\.me/|viber\.me/|whatsapp\.com|telegram\.me|m\.me/)' then return true; end if;
  -- Count digits to skip short class numbers (e.g. "Class 11").
  digit_count := length(regexp_replace(p_text, '\D', '', 'g'));
  if digit_count >= 7 and p_text ~ '(\+?\d[\d\s\-.]{6,}\d)' then return true; end if;
  return false;
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- open_or_get_thread — only opens a thread when the gate has been met.
-- Gate (either is sufficient):
--   (a) caller is a student who already unlocked p_tutor_id (a wallet_ledger
--       row with reason='unlock' and ref_id=p_tutor_id);
--   (b) caller is a tutor or student linked via an admin_assignment
--       (vacancies.filled_by_tutor + linked_student) for the same pair.
-- Returns the thread id (creates it if missing).
-- ────────────────────────────────────────────────────────────────────────────
create or replace function open_or_get_thread(p_counterparty uuid)
returns uuid
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  caller_role  text;
  cpty_role    text;
  student_id   uuid;
  tutor_id     uuid;
  unlocked     boolean;
  assigned     boolean;
  thread_id    uuid;
  opened_via   text;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_counterparty then raise exception 'cannot_chat_with_self'; end if;

  select role into caller_role  from profiles where id = caller;
  select role into cpty_role    from profiles where id = p_counterparty;

  if caller_role is null or cpty_role is null then
    raise exception 'profile_not_found';
  end if;
  if caller_role = cpty_role then
    raise exception 'invalid_pair';
  end if;

  if caller_role = 'student' then
    student_id := caller;
    tutor_id   := p_counterparty;
  else
    student_id := p_counterparty;
    tutor_id   := caller;
  end if;

  unlocked := exists (
    select 1 from wallet_ledger
     where user_id = student_id and reason = 'unlock' and ref_id = tutor_id
  );
  assigned := exists (
    select 1 from vacancies
     where linked_student = student_id and filled_by_tutor = tutor_id
  );

  if not unlocked and not assigned then
    raise exception 'gate_not_met';
  end if;

  opened_via := case when assigned then 'admin_assignment' else 'contact_unlock' end;

  insert into chat_threads(student_id, tutor_id, opened_via)
  values (student_id, tutor_id, opened_via)
  on conflict (student_id, tutor_id) do update set student_id = excluded.student_id
  returning id into thread_id;

  return thread_id;
end;
$$;
grant execute on function open_or_get_thread(uuid) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- send_chat_message — phone-ban backstop + last_message_at touch.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function send_chat_message(p_thread_id uuid, p_body text)
returns uuid
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
  msg_id uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (
    select 1 from chat_threads
     where id = p_thread_id and auth.uid() in (student_id, tutor_id)
  ) then raise exception 'thread_not_found_or_forbidden'; end if;

  if length(coalesce(trim(p_body), '')) = 0 then
    raise exception 'empty_message';
  end if;
  if _has_phone_or_contact(p_body) then
    raise exception 'phone_in_message';
  end if;

  insert into chat_messages(thread_id, sender_id, body)
  values (p_thread_id, caller, p_body)
  returning id into msg_id;

  update chat_threads set last_message_at = now() where id = p_thread_id;
  return msg_id;
end;
$$;
grant execute on function send_chat_message(uuid, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- mark_messages_read — the counterparty's incoming messages get a timestamp.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function mark_messages_read(p_thread_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  update chat_messages
     set read_at = now()
   where thread_id = p_thread_id
     and sender_id <> caller
     and read_at is null;
end;
$$;
grant execute on function mark_messages_read(uuid) to authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0008_phase10_reviews_boosts.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 10 schema (reviews, ratings, boosts).
-- Run after 0007_phase9_chat.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- reviews — one row per (student, tutor) pair. Edits replace the row.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists reviews (
  id          uuid primary key default uuid_generate_v4(),
  tutor_id    uuid not null references profiles(id) on delete cascade,
  student_id  uuid not null references profiles(id) on delete cascade,
  job_id      uuid references jobs(id)      on delete set null,
  vacancy_id  uuid references vacancies(id) on delete set null,
  stars       smallint not null check (stars between 1 and 5),
  text        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (tutor_id, student_id)
);

create index if not exists reviews_tutor_idx on reviews(tutor_id, created_at desc);
create index if not exists reviews_student_idx on reviews(student_id, created_at desc);

drop trigger if exists trg_reviews_updated_at on reviews;
create trigger trg_reviews_updated_at
  before update on reviews
  for each row execute function set_updated_at();

alter table reviews enable row level security;

-- Anyone authenticated can read reviews; only the author can write their row.
drop policy if exists reviews_select_all on reviews;
create policy reviews_select_all on reviews for select using (true);

drop policy if exists reviews_insert_self on reviews;
create policy reviews_insert_self on reviews for insert with check (auth.uid() = student_id);

drop policy if exists reviews_update_self on reviews;
create policy reviews_update_self on reviews for update
  using (auth.uid() = student_id) with check (auth.uid() = student_id);

drop policy if exists reviews_delete_self on reviews;
create policy reviews_delete_self on reviews for delete using (auth.uid() = student_id);

-- ────────────────────────────────────────────────────────────────────────────
-- submit_review — must already have a relationship gate (unlock or assignment).
-- Recomputes tutors.rating + rating_count + ranking_score on every write.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function submit_review(
  p_tutor_id uuid,
  p_stars    smallint,
  p_text     text
) returns uuid
language plpgsql
security definer
as $$
declare
  caller     uuid := auth.uid();
  unlocked   boolean;
  assigned   boolean;
  review_id  uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_tutor_id then raise exception 'cannot_review_self'; end if;
  if p_stars < 1 or p_stars > 5 then raise exception 'invalid_stars'; end if;
  if _has_phone_or_contact(coalesce(p_text, '')) then
    raise exception 'phone_in_review';
  end if;

  unlocked := exists (
    select 1 from wallet_ledger
     where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id
  );
  assigned := exists (
    select 1 from vacancies
     where linked_student = caller and filled_by_tutor = p_tutor_id
  );
  if not unlocked and not assigned then
    raise exception 'gate_not_met';
  end if;

  insert into reviews(tutor_id, student_id, stars, text)
  values (p_tutor_id, caller, p_stars, p_text)
  on conflict (tutor_id, student_id) do update
    set stars = excluded.stars,
        text  = excluded.text,
        updated_at = now()
  returning id into review_id;

  perform recompute_tutor_rating(p_tutor_id);
  return review_id;
end;
$$;
grant execute on function submit_review(uuid, smallint, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- recompute_tutor_rating — single tutor's rating + rating_count + ranking_score.
-- ranking_score = weighted blend of rating, review count, completion %, verified
-- flag, premium membership, and a recency bonus from updated_at.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function recompute_tutor_rating(p_tutor_id uuid)
returns void
language plpgsql
as $$
declare
  avg_stars numeric;
  n_reviews int;
  t         record;
  score     numeric;
begin
  select coalesce(avg(stars)::numeric(3,2), 0)::numeric,
         count(*)::int
    into avg_stars, n_reviews
    from reviews where tutor_id = p_tutor_id;

  update tutors set rating = avg_stars, rating_count = n_reviews
   where id = p_tutor_id;

  select * into t from tutors where id = p_tutor_id;
  if t is null then return; end if;

  score := 0;
  score := score + coalesce(t.rating, 0) * 15;                     -- 0..75
  score := score + least(coalesce(t.rating_count, 0), 20) * 1.0;   -- 0..20
  score := score + coalesce(t.profile_completion, 0) * 0.2;        -- 0..20
  if t.verified then score := score + 10; end if;
  if t.premium_until is not null and t.premium_until > now() then score := score + 8; end if;
  if t.featured_until is not null and t.featured_until > now() then score := score + 5; end if;
  -- recency bonus (decays over a year)
  score := score + greatest(0, 5 - extract(epoch from (now() - t.updated_at)) / (86400 * 73.0));

  update tutors set ranking_score = score where id = p_tutor_id;
end;
$$;

-- Nightly batch — call from a cron / Edge Function trigger.
create or replace function recompute_all_tutor_rankings()
returns void
language plpgsql
as $$
declare r record;
begin
  for r in select id from tutors loop
    perform recompute_tutor_rating(r.id);
  end loop;
end;
$$;
grant execute on function recompute_all_tutor_rankings() to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- Boost RPCs — debit coins atomically and set the expiry timestamp.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function boost_tutor_featured(p_hours int default 24)
returns int
language plpgsql
security definer
as $$
declare
  caller      uuid := auth.uid();
  cost        int;
  new_balance int;
  new_until   timestamptz;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from tutors where id = caller) then
    raise exception 'not_a_tutor';
  end if;
  cost := get_platform_setting_int('featured_listing_cost', 50);
  new_balance := _ledger_apply(caller, -cost, 'boost', 'tutor', caller, 'Featured listing');
  new_until := greatest(
    coalesce((select featured_until from tutors where id = caller), now()),
    now()
  ) + make_interval(hours => p_hours);
  update tutors set featured_until = new_until where id = caller;
  perform recompute_tutor_rating(caller);
  return new_balance;
end;
$$;
grant execute on function boost_tutor_featured(int) to authenticated;

create or replace function promote_job(p_job_id uuid, p_hours int default 24)
returns int
language plpgsql
security definer
as $$
declare
  caller      uuid := auth.uid();
  cost        int;
  new_balance int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from jobs where id = p_job_id and student_id = caller) then
    raise exception 'not_owner';
  end if;
  cost := get_platform_setting_int('promoted_job_cost', 20);
  new_balance := _ledger_apply(caller, -cost, 'boost', 'job', p_job_id, 'Promoted job');
  update jobs set promoted_until = greatest(coalesce(promoted_until, now()), now()) +
                                    make_interval(hours => p_hours)
    where id = p_job_id;
  return new_balance;
end;
$$;
grant execute on function promote_job(uuid, int) to authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0009_phase11_coin_topups.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 11 schema (coin top-ups).
-- Run after 0008_phase10_reviews_boosts.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- coin_packs — admin-curated catalog of (amount, price) pairs offered to users.
-- Bonus = extra coins on top of `coin_amount` for marketing tiers.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists coin_packs (
  id            uuid primary key default uuid_generate_v4(),
  code          text unique not null,           -- 'PACK-100', 'PACK-500', ...
  label         text not null,                  -- 'Starter pack'
  coin_amount   integer not null check (coin_amount > 0),
  bonus_coins   integer not null default 0 check (bonus_coins >= 0),
  price_npr     numeric not null check (price_npr > 0),
  active        boolean not null default true,
  sort_order    smallint not null default 0,
  created_at    timestamptz not null default now()
);

alter table coin_packs enable row level security;
drop policy if exists coin_packs_select_active on coin_packs;
create policy coin_packs_select_active on coin_packs for select using (active);

-- Seed a starter catalog. Admins can re-tune via the admin panel.
insert into coin_packs (code, label, coin_amount, bonus_coins, price_npr, sort_order)
values
  ('PACK-100',  'Starter',     100,   0,   99, 1),
  ('PACK-500',  'Popular',     500,  50,  449, 2),
  ('PACK-2000', 'Pro',        2000, 300, 1699, 3),
  ('PACK-5000', 'Power user', 5000, 900, 3999, 4)
on conflict (code) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- coin_top_ups — one row per attempted top-up. Lifecycle:
--   pending → succeeded   (webhook verified, coins credited)
--           → failed      (webhook rejected, no credit)
--           → cancelled   (user backed out)
-- The wallet credit is the same `_ledger_apply` path used everywhere else.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists coin_top_ups (
  id                 uuid primary key default uuid_generate_v4(),
  user_id            uuid not null references profiles(id) on delete cascade,
  pack_id            uuid references coin_packs(id),
  provider           text not null check (provider in ('esewa','khalti','ime_pay')),
  provider_ref       text,                                 -- provider's txn id
  coin_amount        integer not null,                     -- includes bonus
  price_npr          numeric not null,
  status             text not null check (status in ('pending','succeeded','failed','cancelled')) default 'pending',
  ledger_entry_id    uuid references wallet_ledger(id),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  webhook_payload    jsonb
);

create index if not exists coin_top_ups_user_idx on coin_top_ups(user_id, created_at desc);
create index if not exists coin_top_ups_provider_ref_idx on coin_top_ups(provider, provider_ref);

drop trigger if exists trg_coin_top_ups_updated_at on coin_top_ups;
create trigger trg_coin_top_ups_updated_at
  before update on coin_top_ups
  for each row execute function set_updated_at();

alter table coin_top_ups enable row level security;

drop policy if exists coin_top_ups_select_self on coin_top_ups;
create policy coin_top_ups_select_self on coin_top_ups for select
  using (auth.uid() = user_id or exists (select 1 from admin_users where id = auth.uid()));

drop policy if exists coin_top_ups_insert_self on coin_top_ups;
create policy coin_top_ups_insert_self on coin_top_ups for insert
  with check (auth.uid() = user_id and status = 'pending');

-- Only admins / webhook RPC may flip status — clients can't promote
-- pending → succeeded on their own. Updates go through `finalize_top_up`.
drop policy if exists coin_top_ups_admin_update on coin_top_ups;
create policy coin_top_ups_admin_update on coin_top_ups for update
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- ────────────────────────────────────────────────────────────────────────────
-- start_top_up — client-callable. Creates a pending row and returns the id
-- the client can pass to the provider SDK as `merchantTransactionId`.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function start_top_up(
  p_pack_id  uuid,
  p_provider text
) returns uuid
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
  pack   record;
  id     uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if p_provider not in ('esewa','khalti','ime_pay') then raise exception 'invalid_provider'; end if;

  select * into pack from coin_packs where id = p_pack_id and active;
  if pack is null then raise exception 'pack_not_found'; end if;

  insert into coin_top_ups(user_id, pack_id, provider, coin_amount, price_npr)
  values (caller, p_pack_id, p_provider,
          pack.coin_amount + pack.bonus_coins, pack.price_npr)
  returning coin_top_ups.id into id;
  return id;
end;
$$;
grant execute on function start_top_up(uuid, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- finalize_top_up — called by the Edge Function ONCE the provider's webhook
-- signature has been verified. Idempotent: succeeded rows are not double-
-- credited. The credit goes through _ledger_apply so the wallet UI updates.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function finalize_top_up(
  p_top_up_id    uuid,
  p_provider_ref text,
  p_payload      jsonb,
  p_ok           boolean
) returns void
language plpgsql
security definer
as $$
declare
  t   record;
  new_ledger uuid;
  balance int;
begin
  select * into t from coin_top_ups where id = p_top_up_id for update;
  if t is null then raise exception 'top_up_not_found'; end if;

  -- Idempotent
  if t.status = 'succeeded' then return; end if;
  if t.status in ('failed','cancelled') and not p_ok then return; end if;

  update coin_top_ups
     set provider_ref = coalesce(p_provider_ref, t.provider_ref),
         webhook_payload = p_payload,
         status = case when p_ok then 'succeeded' else 'failed' end
   where id = p_top_up_id;

  if p_ok then
    balance := _ledger_apply(
      t.user_id, t.coin_amount, 'topup', 'topup', p_top_up_id,
      'Coin pack via ' || t.provider
    );
    -- Capture the just-inserted ledger row's id (latest by ts for user).
    select id into new_ledger from wallet_ledger
      where user_id = t.user_id and reason = 'topup'
      order by created_at desc limit 1;
    update coin_top_ups set ledger_entry_id = new_ledger where id = p_top_up_id;

    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    values (t.user_id, 'coin_credited', 'Coins credited',
            '+' || t.coin_amount || ' coins from ' || t.provider, 'topup', p_top_up_id);
  else
    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    values (t.user_id, 'system', 'Top-up failed',
            'Your ' || t.provider || ' payment did not go through.', 'topup', p_top_up_id);
  end if;
end;
$$;
-- finalize_top_up is invoked by the webhook Edge Function (running with the
-- service_role key) — clients don't have execute. Admins call it directly
-- from the admin panel to manually mark a stuck payment.
grant execute on function finalize_top_up(uuid, text, jsonb, boolean) to service_role;

-- ────────────────────────────────────────────────────────────────────────────
-- cancel_top_up — user backs out of the provider flow.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function cancel_top_up(p_top_up_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  t record;
begin
  select * into t from coin_top_ups where id = p_top_up_id;
  if t is null or t.user_id <> auth.uid() then raise exception 'forbidden'; end if;
  if t.status <> 'pending' then return; end if;
  update coin_top_ups set status = 'cancelled' where id = p_top_up_id;
end;
$$;
grant execute on function cancel_top_up(uuid) to authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0010_phase12_admin_hardening.sql
-- ════════════════════════════════════════════════════════════════════

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


-- ════════════════════════════════════════════════════════════════════
-- 0011_phase13_public_directory.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 13 schema (public-readable directory for the SEO site).
-- Run after 0010_phase12_admin_hardening.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- Public codes used in deep links. Phase 7 already added vacancy codes
-- (HTN-NNNNN); this migration adds T-XXXXXX (tutors) and J-XXXXXX (jobs).
-- The codes are short, URL-safe, immutable, and assigned automatically.
-- ────────────────────────────────────────────────────────────────────────────
alter table profiles add column if not exists public_code text unique;
alter table jobs     add column if not exists public_code text unique;

create or replace function _generate_short_code(p_prefix text)
returns text language plpgsql as $$
declare
  alphabet text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  out_code text;
  i int;
begin
  out_code := p_prefix || '-';
  for i in 1..6 loop
    out_code := out_code || substr(alphabet, (random() * 31)::int + 1, 1);
  end loop;
  return out_code;
end;
$$;

create or replace function _assign_profile_code() returns trigger
language plpgsql as $$
begin
  if new.public_code is null then
    loop
      new.public_code := _generate_short_code(case when new.role = 'tutor' then 'T' else 'S' end);
      exit when not exists (select 1 from profiles where public_code = new.public_code);
    end loop;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_profiles_assign_code on profiles;
create trigger trg_profiles_assign_code
  before insert on profiles
  for each row execute function _assign_profile_code();

create or replace function _assign_job_code() returns trigger
language plpgsql as $$
begin
  if new.public_code is null then
    loop
      new.public_code := _generate_short_code('J');
      exit when not exists (select 1 from jobs where public_code = new.public_code);
    end loop;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_jobs_assign_code on jobs;
create trigger trg_jobs_assign_code
  before insert on jobs
  for each row execute function _assign_job_code();

-- Back-fill existing rows.
update profiles set public_code = _generate_short_code(case when role = 'tutor' then 'T' else 'S' end)
 where public_code is null;
update jobs set public_code = _generate_short_code('J') where public_code is null;

-- ────────────────────────────────────────────────────────────────────────────
-- Anon-readable public view. Returns ONLY masked fields — never real names,
-- phones, exact addresses, or document URLs. Safe to expose to the public
-- site's Supabase anon key.
-- ────────────────────────────────────────────────────────────────────────────
create or replace view public_tutors_directory
with (security_invoker = true) as
select
  p.public_code,
  p.handle,
  p.first_name || ' ' || left(p.last_name, 1) || '*' as masked_name,
  t.tagline,
  coalesce(p.address_line, p.city, '')                as area_label,
  p.city,
  p.zone,
  t.teaching_mode,
  t.levels_taught,
  t.languages_known,
  t.verified,
  t.rating,
  t.rating_count,
  t.experience_offline_years,
  t.experience_online_years,
  t.ranking_score,
  (select array_agg(distinct subject) from tutor_offerings
     where tutor_id = t.id order by 1 limit 5)         as top_subjects,
  (select min(price_min_npr) from tutor_offerings
     where tutor_id = t.id)                            as from_price_npr,
  (select price_period from tutor_offerings
     where tutor_id = t.id order by price_min_npr asc limit 1) as from_price_period
from tutors t
join profiles p on p.id = t.id
where t.draft_status = 'published';

grant select on public_tutors_directory to anon, authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- Anon RPCs used by the marketing site. Each returns only what the existing
-- public view exposes — never PII.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function public_get_tutor(p_code text)
returns setof public_tutors_directory
language sql
stable
as $$
  select * from public_tutors_directory where public_code = p_code limit 1;
$$;
grant execute on function public_get_tutor(text) to anon, authenticated;

create or replace function public_search_tutors(
  p_subject text default null,
  p_area    text default null,
  p_level   text default null,
  p_mode    text default null,
  p_limit   int  default 30
) returns setof public_tutors_directory
language sql
stable
as $$
  select * from public_tutors_directory
   where (p_subject is null or top_subjects @> array[p_subject])
     and (p_area    is null or area_label ilike '%' || p_area || '%')
     and (p_level   is null or p_level = any (levels_taught))
     and (p_mode    is null or teaching_mode = p_mode or teaching_mode = 'both')
   order by ranking_score desc nulls last, rating desc nulls last
   limit p_limit;
$$;
grant execute on function public_search_tutors(text, text, text, text, int) to anon, authenticated;

-- Public stats for the homepage hero. Refreshed on every call (cheap).
create or replace function public_homepage_stats()
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'tutors_active', (select count(*) from tutors where draft_status = 'published'),
    'tutors_verified', (select count(*) from tutors where verified),
    'vacancies_open', (select count(*) from vacancies where status = 'open'),
    'vacancies_filled_30d', (select count(*) from vacancies
                              where status = 'filled' and updated_at > now() - interval '30 days'),
    'subjects_covered', (select count(distinct subject) from tutor_offerings),
    'languages_covered', (select count(distinct l) from
                            (select unnest(languages_known) as l from tutors) s),
    'areas_covered', (select count(distinct coalesce(city, address_line)) from profiles where role = 'tutor')
  );
$$;
grant execute on function public_homepage_stats() to anon, authenticated;

-- Vacancy lookup (HTN-NNNNN) by code.
create or replace function public_get_vacancy(p_code text)
returns table (
  code           text,
  title          text,
  area_label     text,
  num_students   int,
  grade          text,
  subjects       text[],
  duration_text  text,
  salary_min_npr numeric,
  salary_max_npr numeric,
  salary_period  text,
  gender_pref    text,
  mode           text,
  status         text,
  created_at     timestamptz
)
language sql
stable
as $$
  select code, title, area_label, num_students, grade, subjects,
         duration_text, salary_min_npr, salary_max_npr, salary_period,
         gender_pref, mode, status, created_at
    from vacancies
   where code = p_code
     and status in ('open', 'applications_closed', 'filled')
   limit 1;
$$;
grant execute on function public_get_vacancy(text) to anon, authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0012_phase14_email_verification.sql
-- ════════════════════════════════════════════════════════════════════

-- Phase 14 hardening: switch the verification gate from phone OTP to email
-- confirmation. `auth.users.email_confirmed_at` is now the source of truth;
-- `profiles.email_verified` mirrors it for app reads. The legacy
-- `phone_verified` column is kept for historical rows so existing dashboards
-- and exports do not break, but new sign-ups no longer rely on it.

alter table profiles
  add column if not exists email_verified boolean not null default false;

-- Backfill from auth.users so previously confirmed accounts stay verified.
update profiles p
   set email_verified = true
  from auth.users u
 where u.id = p.id
   and u.email_confirmed_at is not null
   and p.email_verified = false;


-- ════════════════════════════════════════════════════════════════════
-- 0013_phase8_push_token.sql
-- ════════════════════════════════════════════════════════════════════

-- Phase 8 push notifications: each authenticated device persists its FCM
-- (or OneSignal) token on the profile row so the future `push_dispatcher`
-- Edge Function can look up where to send remote notifications.
--
-- Token is optional — users who never grant Permission.notification (or are
-- on web) keep it null. Tokens are not user-private at the privacy-policy
-- level but live behind the same RLS as the rest of profiles.* and are
-- never exposed to other authenticated users.

alter table profiles
  add column if not exists push_token text;

create index if not exists profiles_push_token_idx
  on profiles (push_token)
  where push_token is not null;


-- ════════════════════════════════════════════════════════════════════
-- 0014_phase15_tutor_sequential_codes.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — switch tutor public codes from random `T-XXXXXX` to
-- sequential `TUTOR-NNNNNNNN` starting at 90000000. Student codes are kept
-- on the random `S-XXXXXX` scheme.
--
-- Run after 0013_phase8_push_token.sql.

-- Sequence that drives the numeric suffix. Start value matches the spec
-- (first tutor = TUTOR-90000000, second = TUTOR-90000001, …).
create sequence if not exists tutors_code_seq start with 90000000;

-- Replace the assignment trigger function so tutor rows pull from the
-- sequence while student rows keep the existing random scheme.
create or replace function _assign_profile_code() returns trigger
language plpgsql as $$
begin
  if new.public_code is null then
    if new.role = 'tutor' then
      new.public_code := 'TUTOR-' || lpad(nextval('tutors_code_seq')::text, 8, '0');
    else
      loop
        new.public_code := _generate_short_code('S');
        exit when not exists (select 1 from profiles where public_code = new.public_code);
      end loop;
    end if;
  end if;
  return new;
end;
$$;

-- Backfill any tutor whose public_code is missing or still uses the legacy
-- `T-XXXXXX` random format. Idempotent: tutors that already carry a
-- `TUTOR-` code keep their assigned number.
update profiles
   set public_code = 'TUTOR-' || lpad(nextval('tutors_code_seq')::text, 8, '0')
 where role = 'tutor'
   and (public_code is null or public_code !~ '^TUTOR-\d{8}$');


-- ════════════════════════════════════════════════════════════════════
-- 0015_tutor_location_rpc.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 17 schema.
-- Expose tutor geog as plain lat/lng columns the Flutter client can read
-- without writing PostGIS expressions, and provide a small RPC the wizard
-- uses to update the caller's location.
--
-- Run after 0014_phase15_tutor_sequential_codes.sql.

-- Generated columns so plain `select lat, lng from tutors` works. PostGIS
-- already stores the canonical point in `geog`; these just project it back
-- into ordinary numeric columns the Dart repo can deserialize.
alter table tutors
  add column if not exists lat double precision
    generated always as (st_y(geog::geometry)) stored;
alter table tutors
  add column if not exists lng double precision
    generated always as (st_x(geog::geometry)) stored;

-- RPC the onboarding wizard calls when a tutor drops the map pin. Updates
-- the caller's own tutor row only — RLS prevents touching anyone else.
create or replace function set_tutor_location(p_lat double precision, p_lng double precision)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then
    raise exception 'auth_required';
  end if;
  update tutors
     set geog = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
   where id = caller;
end;
$$;

grant execute on function set_tutor_location(double precision, double precision) to authenticated;


-- ════════════════════════════════════════════════════════════════════
-- 0016_tutor_cv_and_wizard_resume.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 19 schema.
-- Stores the uploaded CV URL and persists the wizard step a tutor closed
-- the app on, so reopening the app drops them back at the same place.
--
-- Run after 0015_tutor_location_rpc.sql.
--
-- BUCKET PROVISIONING: the storage bucket itself must be created via the
-- Supabase dashboard (Storage → New bucket → "tutor-cvs", public read). The
-- RLS policies below assume the bucket already exists.

alter table tutors add column if not exists cv_url      text;
alter table tutors add column if not exists wizard_step integer not null default 0;

-- Allow the owning tutor to upload / overwrite / delete objects under their
-- own UUID folder, and anyone signed in to read (the marketing site uses the
-- anon key so we keep that read open too via the bucket's public flag).
do $$
begin
  if exists (select 1 from storage.buckets where id = 'tutor-cvs') then
    -- Authenticated owner can insert into their own folder.
    drop policy if exists tutor_cvs_owner_insert on storage.objects;
    create policy tutor_cvs_owner_insert
      on storage.objects for insert to authenticated
      with check (
        bucket_id = 'tutor-cvs'
        and (storage.foldername(name))[1] = auth.uid()::text
      );

    -- Owner can update (used for upsert).
    drop policy if exists tutor_cvs_owner_update on storage.objects;
    create policy tutor_cvs_owner_update
      on storage.objects for update to authenticated
      using (
        bucket_id = 'tutor-cvs'
        and (storage.foldername(name))[1] = auth.uid()::text
      );

    -- Owner can delete their own CV.
    drop policy if exists tutor_cvs_owner_delete on storage.objects;
    create policy tutor_cvs_owner_delete
      on storage.objects for delete to authenticated
      using (
        bucket_id = 'tutor-cvs'
        and (storage.foldername(name))[1] = auth.uid()::text
      );

    -- Public read (students need to download the CV via the URL stored on
    -- the tutor row). Mirrors the bucket's public flag.
    drop policy if exists tutor_cvs_public_read on storage.objects;
    create policy tutor_cvs_public_read
      on storage.objects for select
      using (bucket_id = 'tutor-cvs');
  end if;
end$$;


-- ════════════════════════════════════════════════════════════════════
-- 0017_topup_receipt_upload.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — Phase 20 schema.
-- Tracks the post-payment receipt the user uploads after sending money via
-- eSewa. An admin reviews `coin_top_ups` rows where `receipt_url is not null
-- and status = 'pending'` and credits the wallet through the existing
-- `finalize_top_up` RPC.
--
-- Run after 0016_tutor_cv_and_wizard_resume.sql.
--
-- BUCKET PROVISIONING: create the `topup-receipts` bucket in the Supabase
-- dashboard (public read; owner-only write). Policies below assume it exists.

alter table coin_top_ups add column if not exists receipt_url text;

do $$
begin
  if exists (select 1 from storage.buckets where id = 'topup-receipts') then
    -- Owner can upload to their own top-up folder. Object name layout:
    --   {topup_id}/receipt.{ext}
    -- The first folder segment is the top-up id; we check it belongs to the
    -- caller via the coin_top_ups join.
    drop policy if exists topup_receipts_owner_insert on storage.objects;
    create policy topup_receipts_owner_insert
      on storage.objects for insert to authenticated
      with check (
        bucket_id = 'topup-receipts'
        and exists (
          select 1 from coin_top_ups
           where coin_top_ups.id::text = (storage.foldername(name))[1]
             and coin_top_ups.user_id = auth.uid()
        )
      );

    drop policy if exists topup_receipts_owner_update on storage.objects;
    create policy topup_receipts_owner_update
      on storage.objects for update to authenticated
      using (
        bucket_id = 'topup-receipts'
        and exists (
          select 1 from coin_top_ups
           where coin_top_ups.id::text = (storage.foldername(name))[1]
             and coin_top_ups.user_id = auth.uid()
        )
      );

    drop policy if exists topup_receipts_public_read on storage.objects;
    create policy topup_receipts_public_read
      on storage.objects for select
      using (bucket_id = 'topup-receipts');
  end if;
end$$;


-- ════════════════════════════════════════════════════════════════════
-- 0018_contracts.sql
-- ════════════════════════════════════════════════════════════════════

-- Home Tuition Nepal — contracts (Upwork-style engagements started from chat).
--
-- A contract is proposed by one party in a chat thread, accepted by the
-- other, runs while 'active', and on 'completed' unlocks the review flow.
-- Run after 0017_topup_receipt_upload.sql.

create table if not exists contracts (
  id            uuid primary key default gen_random_uuid(),
  thread_id     uuid references chat_threads(id) on delete set null,
  student_id    uuid not null references profiles(id) on delete cascade,
  tutor_id      uuid not null references profiles(id) on delete cascade,
  proposed_by   uuid not null references profiles(id) on delete cascade,
  subject       text not null,
  rate_npr      numeric,
  rate_period   text not null default 'month' check (rate_period in ('month','week','session','hour')),
  schedule_text text,
  status        text not null default 'proposed'
                  check (status in ('proposed','active','completed','declined','cancelled')),
  created_at    timestamptz not null default now(),
  started_at    timestamptz,
  ended_at      timestamptz
);

create index if not exists contracts_thread_idx  on contracts (thread_id, created_at desc);
create index if not exists contracts_student_idx on contracts (student_id, created_at desc);
create index if not exists contracts_tutor_idx   on contracts (tutor_id, created_at desc);

alter table contracts enable row level security;

-- Either party on the contract can read it.
drop policy if exists contracts_select_party on contracts;
create policy contracts_select_party
  on contracts for select
  using (auth.uid() = student_id or auth.uid() = tutor_id);

-- Either party can create a proposal, but only as themselves (proposed_by).
drop policy if exists contracts_insert_party on contracts;
create policy contracts_insert_party
  on contracts for insert
  with check (
    auth.uid() = proposed_by
    and (auth.uid() = student_id or auth.uid() = tutor_id)
  );

-- Status transitions go through the RPCs below (security definer), so we keep
-- direct UPDATE locked down to the two parties as a backstop.
drop policy if exists contracts_update_party on contracts;
create policy contracts_update_party
  on contracts for update
  using (auth.uid() = student_id or auth.uid() = tutor_id)
  with check (auth.uid() = student_id or auth.uid() = tutor_id);

-- ─── Lifecycle RPCs ──────────────────────────────────────────────────
-- accept: only the counterparty (not the proposer) may accept a proposal.
create or replace function accept_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.student_id and auth.uid() <> c.tutor_id then
    raise exception 'not_a_party';
  end if;
  if auth.uid() = c.proposed_by then raise exception 'proposer_cannot_accept'; end if;
  if c.status <> 'proposed' then raise exception 'not_proposed'; end if;
  update contracts set status = 'active', started_at = now() where id = p_contract_id;
end;
$$;
grant execute on function accept_contract(uuid) to authenticated;

-- decline: the counterparty rejects a proposal.
create or replace function decline_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.student_id and auth.uid() <> c.tutor_id then
    raise exception 'not_a_party';
  end if;
  if c.status <> 'proposed' then raise exception 'not_proposed'; end if;
  update contracts set status = 'declined', ended_at = now() where id = p_contract_id;
end;
$$;
grant execute on function decline_contract(uuid) to authenticated;

-- end: either party ends an active contract → 'completed' (unlocks reviews).
create or replace function end_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.student_id and auth.uid() <> c.tutor_id then
    raise exception 'not_a_party';
  end if;
  if c.status <> 'active' then raise exception 'not_active'; end if;
  update contracts set status = 'completed', ended_at = now() where id = p_contract_id;
end;
$$;
grant execute on function end_contract(uuid) to authenticated;

-- cancel: the proposer withdraws a still-'proposed' contract.
create or replace function cancel_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.proposed_by then raise exception 'not_proposer'; end if;
  if c.status <> 'proposed' then raise exception 'not_proposed'; end if;
  update contracts set status = 'cancelled', ended_at = now() where id = p_contract_id;
end;
$$;
grant execute on function cancel_contract(uuid) to authenticated;
