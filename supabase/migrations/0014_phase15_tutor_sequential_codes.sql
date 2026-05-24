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
