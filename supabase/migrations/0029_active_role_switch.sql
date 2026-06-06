-- ─────────────────────────────────────────────────────────────────────────────
-- 0029 — One account, both roles: active-role switching
--
-- Why: a single person may want to both learn and teach. `profiles.role` stays
-- the immutable PRIMARY role (chosen at first sign-up), and `account_roles`
-- (0023) already records every role an account may act as. This migration adds
-- a mutable `active_role` (which dashboard the user is currently in) plus
-- per-role onboarding flags, and a self-serve RPC to switch — so a student can
-- become a tutor (and vice-versa) from Settings. Switching into a role that has
-- not been onboarded drops the user into that role's onboarding (enforced by
-- the router guard reading these flags).
--
-- Run after 0028_onboarding_contact_location.sql.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.profiles add column if not exists active_role text;
alter table public.profiles
  add column if not exists tutor_onboarded boolean not null default false;
alter table public.profiles
  add column if not exists student_onboarded boolean not null default false;

-- Backfill: the per-role flag inherits the existing single onboarding_complete
-- state for the user's primary role; the other role stays un-onboarded. Active
-- role starts as the primary role. (active_role is left nullable; the client
-- falls back to `role` when it is null, so new trigger-created rows are fine.)
update public.profiles set tutor_onboarded = onboarding_complete where role = 'tutor';
update public.profiles set student_onboarded = onboarding_complete where role = 'student';
update public.profiles set active_role = role where active_role is null;

-- set_my_role (redefines 0028): also pin the active role to the chosen role at
-- first sign-up.
create or replace function set_my_role(p_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'auth_required'; end if;
  if p_role not in ('student', 'tutor') then
    raise exception 'invalid_role: %', p_role;
  end if;
  update profiles
     set role = p_role,
         active_role = p_role,
         email_verified = true,
         code_of_conduct_accepted_at = case
           when p_role = 'tutor' then coalesce(code_of_conduct_accepted_at, now())
           else code_of_conduct_accepted_at end,
         updated_at = now()
   where id = caller
     and onboarding_complete = false;
end;
$$;

grant execute on function set_my_role(text) to authenticated;

-- complete_student_onboarding (redefines 0028): flip the student per-role flag.
create or replace function complete_student_onboarding(
  p_phone text,
  p_whatsapp text,
  p_lat double precision,
  p_lng double precision
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'auth_required'; end if;
  update profiles
     set phone = p_phone,
         whatsapp = p_whatsapp,
         lat = p_lat,
         lng = p_lng,
         student_onboarded = true,
         onboarding_complete = true,
         onboarding_step = 0,
         updated_at = now()
   where id = caller;
end;
$$;

grant execute on function complete_student_onboarding(text, text, double precision, double precision)
  to authenticated;

-- complete_tutor_onboarding (redefines 0028): flip the tutor per-role flag.
create or replace function complete_tutor_onboarding()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'auth_required'; end if;
  update profiles
     set tutor_onboarded = true,
         onboarding_complete = true,
         updated_at = now()
   where id = caller;
end;
$$;

grant execute on function complete_tutor_onboarding() to authenticated;

-- switch_active_role: self-serve. Grants the caller the target role (so the
-- account can act as both) and switches the active dashboard to it. The router
-- guard then routes to that role's home, or its onboarding if not yet done.
create or replace function switch_active_role(p_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'auth_required'; end if;
  if p_role not in ('student', 'tutor') then
    raise exception 'invalid_role: %', p_role;
  end if;
  insert into account_roles(user_id, role)
  values (caller, p_role)
  on conflict (user_id, role) do nothing;
  update profiles
     set active_role = p_role,
         updated_at = now()
   where id = caller;
end;
$$;

grant execute on function switch_active_role(text) to authenticated;
