-- ─────────────────────────────────────────────────────────────────────────────
-- 0028 — First-run onboarding: contact (phone + WhatsApp), location, and a gate
--
-- Why: new accounts now arrive via "Continue with Google as a student / tutor"
-- (stubbed today via anonymous sign-in). Those identities have no phone, no
-- WhatsApp and no location, so the app walks them through an onboarding flow
-- before granting access to home. This migration adds the columns that flow
-- writes, a one-time role setter for externally-authenticated new users, and the
-- RPCs the student/tutor onboarding screens call to persist + finish.
--
-- Run after 0027_usage_tracking.sql.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.profiles add column if not exists whatsapp text;
alter table public.profiles add column if not exists lat double precision;
alter table public.profiles add column if not exists lng double precision;
alter table public.profiles
  add column if not exists onboarding_complete boolean not null default false;
-- Zero-indexed step the onboarding wizard resumes on (mirrors tutors.wizard_step).
alter table public.profiles
  add column if not exists onboarding_step integer not null default 0;

-- Backfill: every account that already exists has been using the app, so it must
-- NOT be forced back through onboarding. Only rows created after this migration
-- (new Google/anonymous/email signups) keep the `false` default and get gated.
update public.profiles set onboarding_complete = true;

-- set_my_role: assign the chosen role once for a freshly created externally-
-- authenticated user (Google / anonymous). The handle_new_user() trigger (0026)
-- defaults new rows to 'student'; this lets the client promote to 'tutor' on the
-- first sign-in. Only applies while not yet onboarded so a role can never change
-- after setup. Also marks the identity email-verified — there is no email
-- confirmation step for Google/anonymous sign-in.
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

-- complete_student_onboarding: persist the student's contact + location and open
-- the gate. Called from the final step of the student onboarding flow.
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
         onboarding_complete = true,
         onboarding_step = 0,
         updated_at = now()
   where id = caller;
end;
$$;

grant execute on function complete_student_onboarding(text, text, double precision, double precision)
  to authenticated;

-- set_tutor_contact: persist phone + WhatsApp during the tutor wizard's contact
-- step (location, CV and the rest are saved by the existing tutor repo / RPCs).
create or replace function set_tutor_contact(p_phone text, p_whatsapp text)
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
         updated_at = now()
   where id = caller;
end;
$$;

grant execute on function set_tutor_contact(text, text) to authenticated;

-- complete_tutor_onboarding: open the gate once the tutor finishes the wizard.
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
     set onboarding_complete = true,
         updated_at = now()
   where id = caller;
end;
$$;

grant execute on function complete_tutor_onboarding() to authenticated;
