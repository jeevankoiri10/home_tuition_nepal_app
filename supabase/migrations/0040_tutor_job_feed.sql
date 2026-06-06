-- Home Tuition Nepal — Personalized tutor job feed (matching algorithm P5).
-- Run after 0039_search_rank.sql.
--
-- See docs/matching-algorithm-design.md §5 (surface 3). Closes the discovery gap:
-- student-posted jobs and admin vacancies had no tutor-facing ranked list. This
-- RPC is the inverse of P4 — it ranks OPEN postings by match_score for the
-- CALLING tutor (auth.uid()), so each tutor sees the jobs that fit their niche
-- first. Already-applied postings sink to the bottom rather than disappearing.
--
-- Vacancy applications live in vacancy_applications; a job "bid" is a
-- wallet_ledger debit (reason='apply', ref_type='job') — both are checked.

create or replace function tutor_job_feed(
  p_max_results int default 60,
  p_radius_mult numeric default 3      -- in-person postings within service_radius × this
)
returns table (
  source          text,                 -- 'vacancy' | 'job'
  id              uuid,
  code            text,
  title           text,
  area_label      text,
  grade           text,
  subjects        text[],
  salary_min_npr  numeric,
  salary_max_npr  numeric,
  salary_period   text,
  gender_pref     text,
  mode            text,
  lat             double precision,
  lng             double precision,
  distance_km     double precision,
  match_score     numeric,
  match_tier      smallint,             -- 0 strong · 1 ok · 2 weak fallback
  already_applied boolean,
  created_at      timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  t tutors;
  w jsonb := get_match_weights();
begin
  select * into t from tutors where id = auth.uid();
  if t.id is null then
    return;   -- caller is not a tutor → empty feed
  end if;

  return query
  with v as (
    select 'vacancy'::text as source, vc.id, vc.code, vc.title, vc.area_label, vc.grade,
           vc.subjects, vc.salary_min_npr, vc.salary_max_npr, vc.salary_period,
           vc.gender_pref, vc.mode,
           st_y(vc.geog::geometry) as lat, st_x(vc.geog::geometry) as lng,
           case when vc.geog is null or t.geog is null then null
                else st_distance(vc.geog, t.geog) / 1000.0 end as distance_km,
           match_score(vc.subject_ids, vc.niche_tag_ids, vc.grade, vc.geog,
                       vc.mode, vc.salary_max_npr, t, w) as score,
           exists (select 1 from vacancy_applications a
                    where a.vacancy_id = vc.id and a.tutor_id = t.id) as applied,
           vc.created_at
      from vacancies vc
     where vc.status = 'open'
       and (vc.gender_pref is null or vc.gender_pref = 'any'
            or t.gender is null or t.gender = vc.gender_pref)
       and not (vc.mode = 'online'    and t.teaching_mode = 'offline')
       and not (vc.mode = 'in-person' and t.teaching_mode = 'online')
       and (vc.mode in ('online','either') or vc.geog is null or t.geog is null
            or st_dwithin(vc.geog, t.geog, coalesce(t.service_radius_km, 5) * 1000 * p_radius_mult))
  ),
  j as (
    select 'job'::text, jb.id, null::text, jb.title, jb.area_label, jb.grade_level,
           case when jb.subject is null then '{}'::text[] else array[jb.subject] end,
           jb.budget_min_npr, jb.budget_max_npr, jb.budget_period,
           jb.gender_pref, jb.mode,
           st_y(jb.geog::geometry), st_x(jb.geog::geometry),
           case when jb.geog is null or t.geog is null then null
                else st_distance(jb.geog, t.geog) / 1000.0 end,
           match_score(case when jb.subject_id is not null then array[jb.subject_id] else '{}'::int[] end,
                       jb.niche_tag_ids, jb.grade_level, jb.geog,
                       jb.mode, jb.budget_max_npr, t, w),
           exists (select 1 from wallet_ledger wl
                    where wl.user_id = t.id and wl.ref_type = 'job'
                      and wl.ref_id = jb.id and wl.reason = 'apply'),
           jb.created_at
      from jobs jb
     where jb.status = 'open'
       and (jb.gender_pref is null or jb.gender_pref = 'any'
            or t.gender is null or t.gender = jb.gender_pref)
       and not (jb.mode = 'online'    and t.teaching_mode = 'offline')
       and not (jb.mode = 'in-person' and t.teaching_mode = 'online')
       and (jb.mode in ('online','either') or jb.geog is null or t.geog is null
            or st_dwithin(jb.geog, t.geog, coalesce(t.service_radius_km, 5) * 1000 * p_radius_mult))
  ),
  feed as (select * from v union all select * from j)
  select feed.source, feed.id, feed.code, feed.title, feed.area_label, feed.grade,
         feed.subjects, feed.salary_min_npr, feed.salary_max_npr, feed.salary_period,
         feed.gender_pref, feed.mode, feed.lat, feed.lng, feed.distance_km,
         round(feed.score, 4) as match_score,
         (case when feed.score >= 0.6 then 0
               when feed.score >= 0.35 then 1
               else 2 end)::smallint as match_tier,
         feed.applied as already_applied,
         feed.created_at
    from feed
   order by feed.applied asc,        -- unapplied first
            match_tier asc, feed.score desc, feed.distance_km asc nulls last
   limit p_max_results;
end;
$$;
grant execute on function tutor_job_feed(int, numeric) to authenticated;
