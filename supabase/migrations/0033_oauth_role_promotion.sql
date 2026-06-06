-- 0033 — Let an OAuth sign-up choose "tutor".
--
-- Google sign-ups are created as role='student' (Google supplies no role), and
-- the app then calls set_my_role(chosen_role). When the user picked "tutor"
-- this UPDATEd profiles.role student->tutor, but block_role_change() rejected
-- ANY role change unconditionally ("profiles.role is immutable after first
-- set"). The RPC therefore threw, the app caught it as signin_failed, and tutor
-- sign-up via Google was impossible.
--
-- Two coordinated fixes:
--   1. block_role_change() now allows a change only when a transaction-local
--      flag is set — and only the trusted set_my_role() RPC sets it (same
--      pattern as app.allow_ledger_write on the wallet ledger). Direct client
--      UPDATEs still cannot change role, so the immutability guarantee for
--      ordinary users is unchanged.
--   2. set_my_role() also reconciles account_roles to the chosen role, because
--      seed_account_role() seeded the insert-time default ('student'). Without
--      this a Google tutor would read role='tutor' but account_roles=['student'],
--      so the multi-role login chooser / availableRoles() would disagree with
--      their real role. Only brand-new (pre-onboarding) accounts are touched.

create or replace function public.block_role_change()
returns trigger
language plpgsql
as $function$
begin
  if new.role is distinct from old.role
     and current_setting('app.allow_role_set', true) is distinct from 'yes' then
    raise exception 'profiles.role is immutable after first set';
  end if;
  return new;
end;
$function$;

create or replace function public.set_my_role(p_role text)
returns void
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  caller    uuid := auth.uid();
  v_updated int;
begin
  if caller is null then raise exception 'auth_required'; end if;
  if p_role not in ('student', 'tutor') then
    raise exception 'invalid_role: %', p_role;
  end if;

  -- Authorise the single role change this RPC performs. Transaction-local, so it
  -- never leaks past this call; block_role_change() honours it.
  perform set_config('app.allow_role_set', 'yes', true);

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

  get diagnostics v_updated = row_count;

  -- Only a brand-new account was (re)assigned its role; align account_roles to
  -- match. A returning user (0 rows updated) is left untouched.
  if v_updated > 0 then
    insert into account_roles(user_id, role)
    values (caller, p_role)
    on conflict (user_id, role) do nothing;
    delete from account_roles where user_id = caller and role <> p_role;
  end if;
end;
$function$;
