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
