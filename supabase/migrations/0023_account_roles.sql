-- Home Tuition Nepal — multi-role accounts (dual-role login).
--
-- `profiles` stays 1:1 with auth.users (one canonical role), but a single
-- person may be allowed to act as BOTH a tutor and a student. account_roles
-- records every role an auth user may enter the app as. The login flow reads
-- it via availableRoles(): one row → auto-route, two rows → role chooser.
--
-- Additive and non-destructive: a trigger seeds the profile's own role on
-- insert, and existing profiles are back-filled, so today every user has
-- exactly one row (no behaviour change). Granting a second role later is just
-- an extra insert (an admin action / future "add the other role" flow).
--
-- Run after 0022_tutor_completion_v2.sql.

create table if not exists account_roles (
  user_id    uuid not null references profiles(id) on delete cascade,
  role       text not null check (role in ('student','tutor')),
  created_at timestamptz not null default now(),
  primary key (user_id, role)
);

create index if not exists account_roles_user_idx on account_roles(user_id);

alter table account_roles enable row level security;

-- A user can see their own roles.
drop policy if exists account_roles_select_self on account_roles;
create policy account_roles_select_self
  on account_roles for select
  using (auth.uid() = user_id);

-- Inserts/updates are server-managed (trigger + admin RPCs); no client writes.

-- Seed the profile's own role into account_roles whenever a profile is created.
create or replace function seed_account_role() returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into account_roles(user_id, role)
  values (new.id, new.role)
  on conflict (user_id, role) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_profiles_seed_account_role on profiles;
create trigger trg_profiles_seed_account_role
  after insert on profiles
  for each row execute function seed_account_role();

-- Back-fill existing profiles.
insert into account_roles(user_id, role)
select id, role from profiles
on conflict (user_id, role) do nothing;

-- Admin-only: grant a user an additional role (so one email can be both a
-- tutor and a student). Idempotent.
create or replace function admin_grant_account_role(p_user_id uuid, p_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  if p_role not in ('student','tutor') then raise exception 'invalid_role'; end if;
  insert into account_roles(user_id, role)
  values (p_user_id, p_role)
  on conflict (user_id, role) do nothing;
end;
$$;
grant execute on function admin_grant_account_role(uuid, text) to authenticated;
