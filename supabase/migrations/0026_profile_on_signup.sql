-- 0026: Auto-provision a profiles row when a new auth user signs up, and keep
-- profiles.email_verified in sync with auth confirmation.
--
-- Why: SupabaseAuthRepository.register() previously inserted the profile from
-- the client immediately after signUp. When email confirmation is enabled,
-- signUp does NOT return a session, so that client insert runs unauthenticated
-- and is denied by the profiles_insert_self RLS policy (auth.uid() is null) —
-- leaving an auth user with no profile. A SECURITY DEFINER trigger creates the
-- profile reliably, regardless of whether a session exists yet.
--
-- The Flutter register() passes first_name/last_name/phone/role/handle as
-- signUp `data` (stored in auth.users.raw_user_meta_data), which this trigger
-- reads. Idempotent: `on conflict do nothing` so a client-side upsert and the
-- trigger can coexist without error.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role text := coalesce(new.raw_user_meta_data->>'role', 'student');
begin
  -- coin_balance is intentionally omitted: the column defaults to 0 and the
  -- trg_profiles_signup_grant trigger (migration 0004) credits the configured
  -- signup_coin_grant (1000) via the wallet ledger. Setting it here too would
  -- double the grant (→ 2000).
  insert into public.profiles (
    id, first_name, last_name, email, phone, email_verified, role, handle,
    tos_accepted_at, code_of_conduct_accepted_at
  ) values (
    new.id,
    coalesce(new.raw_user_meta_data->>'first_name', ''),
    coalesce(new.raw_user_meta_data->>'last_name', ''),
    new.email,
    coalesce(new.raw_user_meta_data->>'phone', ''),
    new.email_confirmed_at is not null,
    v_role,
    coalesce(nullif(new.raw_user_meta_data->>'handle', ''), 'User'),
    now(),
    case when v_role = 'tutor' then now() else null end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Mirror email confirmation back into profiles.email_verified.
create or replace function public.handle_user_confirmed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email_confirmed_at is not null and old.email_confirmed_at is null then
    update public.profiles
      set email_verified = true, updated_at = now()
      where id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists on_auth_user_confirmed on auth.users;
create trigger on_auth_user_confirmed
  after update of email_confirmed_at on auth.users
  for each row execute function public.handle_user_confirmed();
