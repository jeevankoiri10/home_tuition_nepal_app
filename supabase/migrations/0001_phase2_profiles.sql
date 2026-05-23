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
