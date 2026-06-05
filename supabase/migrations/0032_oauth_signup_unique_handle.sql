-- 0032 — Fix Google / OAuth sign-up failing with "Database error saving new user".
--
-- OAuth sign-ups reach handle_new_user() with no app metadata, so the handle
-- fell back to the CONSTANT literal 'User'. The first such account claimed
-- 'User'; every subsequent OAuth sign-up then violated the UNIQUE constraint on
-- profiles.handle. GoTrue surfaces that as the opaque "Database error saving new
-- user", the redirect comes back as ?error=server_error, no session is created,
-- and the app hangs awaiting a sign-in that can never complete.
--
-- Fix: when a sign-up brings no handle (the OAuth case), generate a UNIQUE one
-- server-side in the same "Student #XXXX" / "Tutor #XXXX" shape the
-- email/password client already uses. Email/password sign-ups keep passing their
-- own handle, so their behaviour is unchanged. While here, also seed first/last
-- name from the Google profile (full_name / name) when present so OAuth accounts
-- aren't blank.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  v_role    text := coalesce(new.raw_user_meta_data->>'role', 'student');
  v_handle  text := nullif(new.raw_user_meta_data->>'handle', '');
  v_prefix  text := case when v_role = 'tutor' then 'Tutor' else 'Student' end;
  v_full    text := coalesce(new.raw_user_meta_data->>'full_name',
                             new.raw_user_meta_data->>'name', '');
  v_first   text := coalesce(nullif(new.raw_user_meta_data->>'first_name', ''),
                             nullif(split_part(v_full, ' ', 1), ''), '');
  v_last    text := coalesce(nullif(new.raw_user_meta_data->>'last_name', ''),
                             nullif(trim(substr(v_full,
                               length(split_part(v_full, ' ', 1)) + 2)), ''), '');
  v_attempt int := 0;
begin
  -- No client-supplied handle (OAuth) → generate a unique one. The candidate
  -- grows by a character every few attempts so it always converges even under
  -- pathological collisions, rather than looping forever.
  if v_handle is null then
    loop
      v_handle := v_prefix || ' #' ||
        upper(substr(md5(new.id::text || ':' || v_attempt::text), 1,
                     4 + (v_attempt / 5)));
      exit when not exists (select 1 from public.profiles where handle = v_handle);
      v_attempt := v_attempt + 1;
    end loop;
  end if;

  insert into public.profiles (
    id, first_name, last_name, email, phone, email_verified, role, handle,
    tos_accepted_at, code_of_conduct_accepted_at, coin_balance
  ) values (
    new.id,
    v_first,
    v_last,
    new.email,
    coalesce(new.raw_user_meta_data->>'phone', ''),
    new.email_confirmed_at is not null,
    v_role,
    v_handle,
    now(),
    case when v_role = 'tutor' then now() else null end,
    1000
  )
  on conflict (id) do nothing;
  return new;
end;
$function$;
