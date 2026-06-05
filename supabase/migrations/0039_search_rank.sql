-- Home Tuition Nepal — Fit-ranked map search + widening ladder (matching P4).
-- Run after 0038_notify_topk.sql.
--
-- See docs/matching-algorithm-design.md §5 (surface 2) and §7 (graceful widening).
-- When the student specifies a NEED (subject / level / niche / budget) the map
-- ranks tutors by match_score instead of raw distance, and never returns an empty
-- list in thin areas: candidates are tagged with a widening TIER (0 = perfect fit
-- nearby … 4 = adjacent subject / online-anywhere) and ordered tier-then-score, so
-- the closest perfect matches come first and weaker fallbacks fill the tail.
--
-- When NO need is specified (plain browsing) behaviour is unchanged: nearest
-- published tutors in radius, available/verified first. The masked-field privacy
-- contract (no real name / phone / exact address) is preserved verbatim.
--
-- Backward compatible: the three new params default to null (existing 9-arg calls
-- still resolve) and the two new output columns are appended at the end.

drop function if exists search_tutors_in_viewport(
  double precision, double precision, double precision,
  text, text, text, boolean, boolean, int);

create or replace function search_tutors_in_viewport(
  p_lat            double precision,
  p_lng            double precision,
  p_radius_km      double precision default 5,
  p_level          text default null,
  p_subject        text default null,            -- free-text; resolved to a subject id
  p_mode           text default null,            -- tutor teaching_mode filter: online|offline|both
  p_verified_only  boolean default false,
  p_available_only boolean default false,
  p_max_results    int default 50,
  p_subject_ids    int[] default null,            -- optional explicit canonical subjects
  p_niche_ids      int[] default null,            -- optional niche tags (exam board / prep track)
  p_budget_max     numeric default null           -- student's monthly budget ceiling
)
returns table (
  tutor_id            uuid,
  handle              text,
  masked_name         text,
  tagline             text,
  area_label          text,
  teaching_mode       text,
  levels_taught       text[],
  verified            boolean,
  available           boolean,
  rating              numeric,
  rating_count        integer,
  experience_offline  numeric,
  experience_online   numeric,
  lat                 double precision,
  lng                 double precision,
  distance_km         double precision,
  from_price_npr      numeric,
  from_price_period   text,
  top_subjects        text[],
  match_score         numeric,
  match_tier          smallint
) language plpgsql stable
set search_path = public
as $$
declare
  -- canonical subject ids: explicit param wins, else resolve the free-text one
  r_subject_ids int[] := coalesce(
    p_subject_ids,
    case when p_subject is not null
         then array_remove(array[resolve_subject_id(p_subject)], null)
         else null end);
  -- a "need" turns on fit-ranking + widening; otherwise we just browse by distance
  has_need boolean := p_subject is not null or p_subject_ids is not null
                   or p_niche_ids is not null or p_level is not null
                   or p_budget_max is not null;
  -- map the tutor-mode filter to a request mode for the scorer
  r_mode text := case p_mode when 'online' then 'online'
                             when 'offline' then 'in-person'
                             else 'either' end;
  w jsonb := get_match_weights();
begin
  -- ──────────────────────────────────────────────────────────────────────────
  -- BROWSE (no need stated): unchanged nearest-in-radius behaviour.
  -- ──────────────────────────────────────────────────────────────────────────
  if not has_need then
    return query
    with viewer as (select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g)
    select t.id, p.handle,
           p.first_name || ' ' || left(p.last_name, 1) || '*',
           t.tagline, coalesce(t.address_line, t.city, ''),
           t.teaching_mode, t.levels_taught, t.verified, t.available,
           t.rating, t.rating_count, t.experience_offline_years, t.experience_online_years,
           st_y(t.geog::geometry), st_x(t.geog::geometry),
           st_distance(t.geog, viewer.g) / 1000.0,
           (select price_min_npr from tutor_offerings where tutor_id = t.id order by price_min_npr limit 1),
           (select price_period  from tutor_offerings where tutor_id = t.id order by price_min_npr limit 1),
           (select array_agg(distinct s.subject) from
              (select subject from tutor_offerings where tutor_id = t.id order by price_min_npr limit 3) s),
           null::numeric, null::smallint
      from tutors t join profiles p on p.id = t.id cross join viewer
     where t.geog is not null and t.draft_status = 'published'
       and st_dwithin(t.geog, viewer.g, p_radius_km * 1000)
       and (p_mode is null or t.teaching_mode = p_mode or t.teaching_mode = 'both')
       and (not p_verified_only or t.verified)
       and (not p_available_only or t.available)
     order by t.available desc, t.verified desc, st_distance(t.geog, viewer.g) asc
     limit p_max_results;
    return;
  end if;

  -- ──────────────────────────────────────────────────────────────────────────
  -- NEED stated: fit-rank with the widening ladder.
  -- ──────────────────────────────────────────────────────────────────────────
  return query
  with viewer as (select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g),
  pool as (
    select t, p.handle,
           p.first_name || ' ' || left(p.last_name, 1) || '*' as masked_name,
           coalesce(t.address_line, t.city, '') as area_label,
           st_distance(t.geog, viewer.g) / 1000.0 as dist_km,
           st_y(t.geog::geometry) as lat, st_x(t.geog::geometry) as lng,
           _subject_affinity(r_subject_ids, t.subject_ids) as subj_aff,
           coalesce(_jaccard(p_niche_ids, t.niche_tag_ids), 0) as niche_j,
           match_score(r_subject_ids, p_niche_ids, p_level, viewer.g, r_mode, p_budget_max, t, w) as score
      from tutors t join profiles p on p.id = t.id cross join viewer
     where t.geog is not null and t.draft_status = 'published'
       and (not p_verified_only or t.verified)
       and (not p_available_only or t.available)
       -- mode hard-incompatibility only (soft otherwise)
       and not (r_mode = 'online'    and t.teaching_mode = 'offline')
       and not (r_mode = 'in-person' and t.teaching_mode = 'online')
       -- bound the scan: within 2× radius, OR an online tutor reachable anywhere
       and ( st_dwithin(t.geog, viewer.g, p_radius_km * 2000)
             or t.teaching_mode in ('online','both') )
       -- subject-bounded when a subject was named (affinity OR legacy substring)
       and ( r_subject_ids is null
             or _subject_affinity(r_subject_ids, t.subject_ids) > 0
             or exists (select 1 from tutor_offerings o
                         where o.tutor_id = t.id and o.subject ilike '%' || coalesce(p_subject,'') || '%'
                           and p_subject is not null) )
  ),
  tiered as (
    select pool.*,
           case
             when dist_km <= p_radius_km     and subj_aff >= 1 and (p_niche_ids is null or niche_j > 0) then 0
             when dist_km <= p_radius_km     and subj_aff >  0 then 1
             when dist_km <= p_radius_km * 2 and subj_aff >  0 then 2
             when (t).teaching_mode in ('online','both') and subj_aff > 0 then 3
             else 4   -- adjacent subject (parent/child) or niche-only fallback
           end::smallint as tier
      from pool
  )
  select (t).id, handle, masked_name, (t).tagline, area_label,
         (t).teaching_mode, (t).levels_taught, (t).verified, (t).available,
         (t).rating, (t).rating_count, (t).experience_offline_years, (t).experience_online_years,
         lat, lng, dist_km,
         (select price_min_npr from tutor_offerings where tutor_id = (t).id order by price_min_npr limit 1),
         (select price_period  from tutor_offerings where tutor_id = (t).id order by price_min_npr limit 1),
         (select array_agg(distinct s.subject) from
            (select subject from tutor_offerings where tutor_id = (t).id order by price_min_npr limit 3) s),
         round(score, 4), tier
    from tiered
   order by tier asc, score desc, dist_km asc
   limit p_max_results;
end;
$$;
grant execute on function search_tutors_in_viewport(
  double precision, double precision, double precision,
  text, text, text, boolean, boolean, int, int[], int[], numeric
) to authenticated;
