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
  coalesce(t.address_line, t.city, '')                as area_label,
  t.city,
  t.zone,
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
    'areas_covered', (select count(distinct coalesce(city, address_line)) from tutors)
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
