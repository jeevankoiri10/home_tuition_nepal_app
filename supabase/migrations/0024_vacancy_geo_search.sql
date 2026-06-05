-- Home Tuition Nepal — vacancy geo-search for the tutor map view.
--
-- vacancies already store a PostGIS point in `geog` (0005) which admins set
-- via set_vacancy_location. This exposes geog as plain lat/lng columns the
-- Flutter client can read, and adds search_vacancies_in_viewport — the
-- vacancy analogue of search_tutors_in_viewport (0003) — so tutors can browse
-- open vacancies on a map.
--
-- Run after 0023_account_roles.sql.

-- Generated lat/lng so `select lat, lng from vacancies` works client-side.
-- (Also added defensively in the admin setup; `if not exists` makes both safe
-- regardless of apply order.)
alter table vacancies
  add column if not exists lat double precision generated always as (st_y(geog::geometry)) stored,
  add column if not exists lng double precision generated always as (st_x(geog::geometry)) stored;

create index if not exists vacancies_geog_search_gix on vacancies using gist (geog);

create or replace function search_vacancies_in_viewport(
  p_lat         double precision,
  p_lng         double precision,
  p_radius_km   double precision default 99999,
  p_subject     text default null,
  p_max_results int default 100
)
returns table (
  id            uuid,
  code          text,
  title         text,
  area_label    text,
  grade         text,
  subjects      text[],
  num_students  integer,
  duration_text text,
  salary_min_npr numeric,
  salary_max_npr numeric,
  salary_period text,
  gender_pref   text,
  mode          text,
  notes         text,
  lat           double precision,
  lng           double precision,
  distance_km   double precision,
  created_at    timestamptz
)
language sql
stable
as $$
  with viewer as (
    select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g
  )
  select
    v.id, v.code, v.title, v.area_label, v.grade, v.subjects, v.num_students,
    v.duration_text, v.salary_min_npr, v.salary_max_npr, v.salary_period,
    v.gender_pref, v.mode, v.notes,
    st_y(v.geog::geometry) as lat,
    st_x(v.geog::geometry) as lng,
    (st_distance(v.geog, viewer.g) / 1000.0) as distance_km,
    v.created_at
  from vacancies v
  cross join viewer
  where v.status = 'open'
    and v.geog is not null
    and st_dwithin(v.geog, viewer.g, p_radius_km * 1000)
    and (
      p_subject is null
      or exists (select 1 from unnest(v.subjects) s where s ilike '%' || p_subject || '%')
    )
  order by distance_km asc
  limit p_max_results;
$$;
grant execute on function search_vacancies_in_viewport(double precision, double precision, double precision, text, int) to authenticated;
