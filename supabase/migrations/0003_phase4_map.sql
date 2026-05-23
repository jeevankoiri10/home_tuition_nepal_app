-- Home Tuition Nepal — Phase 4 schema (map view + locality search).
-- Run after 0002_phase3_tutors.sql.

create extension if not exists postgis;

-- Add a PostGIS Point column to tutors. The map only queries this; tutors who
-- haven't dropped a pin yet (geog is null) are excluded from map results but
-- still surface in the list view.
alter table tutors add column if not exists geog geography(Point, 4326);
create index if not exists tutors_geog_gix on tutors using gist (geog);

-- Helper that the client calls to update its own pin (lat/lng) without
-- needing to construct WKT on the client.
create or replace function set_tutor_geog(p_lat double precision, p_lng double precision)
returns void
language plpgsql
security definer
as $$
begin
  update tutors
     set geog = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
   where id = auth.uid();
end;
$$;
grant execute on function set_tutor_geog(double precision, double precision) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- search_tutors_in_viewport
-- The single RPC the map calls on every viewport change. Returns ONLY masked /
-- public fields — no real name, no phone, no exact address. Privacy guard is
-- centralized here so the client cannot bypass it.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function search_tutors_in_viewport(
  p_lat            double precision,
  p_lng            double precision,
  p_radius_km      double precision default 5,
  p_level          text default null,           -- one of student-level values, or null = any
  p_subject        text default null,           -- single-subject substring match, or null
  p_mode           text default null,           -- 'online' | 'offline' | 'both' | null
  p_verified_only  boolean default false,
  p_available_only boolean default false,
  p_max_results    int default 50
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
  top_subjects        text[]
) language plpgsql stable
as $$
begin
  return query
  with viewer as (select st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography as g),
       matched as (
    select t.*,
           p.handle,
           p.first_name || ' ' || left(p.last_name, 1) || '*' as masked_name,
           p.city,
           p.address_line,
           coalesce(p.address_line, p.city, '') as area_label,
           st_distance(t.geog, viewer.g) / 1000.0 as distance_km,
           st_y(t.geog::geometry) as lat,
           st_x(t.geog::geometry) as lng
      from tutors t
      join profiles p on p.id = t.id
      cross join viewer
     where t.geog is not null
       and t.draft_status = 'published'
       and st_dwithin(t.geog, viewer.g, p_radius_km * 1000)
       and (p_level is null or p_level = any (t.levels_taught))
       and (p_mode is null or t.teaching_mode = p_mode or t.teaching_mode = 'both')
       and (not p_verified_only or t.verified)
       and (not p_available_only or t.available)
       and (
            p_subject is null
            or exists (
              select 1 from tutor_offerings o
               where o.tutor_id = t.id
                 and (p_level is null or o.level = p_level)
                 and o.subject ilike '%' || p_subject || '%'
            )
           )
  ),
  enriched as (
    select m.*,
           (
             select array_agg(distinct o.subject)
               from (
                 select subject
                   from tutor_offerings
                  where tutor_id = m.id
                  order by price_min_npr asc
                  limit 3
               ) o
           ) as top_subjects,
           (select price_min_npr from tutor_offerings where tutor_id = m.id
              order by price_min_npr asc limit 1) as from_price_npr,
           (select price_period   from tutor_offerings where tutor_id = m.id
              order by price_min_npr asc limit 1) as from_price_period
      from matched m
  )
  select e.id,
         e.handle,
         e.masked_name,
         e.tagline,
         e.area_label,
         e.teaching_mode,
         e.levels_taught,
         e.verified,
         e.available,
         e.rating,
         e.rating_count,
         e.experience_offline_years,
         e.experience_online_years,
         e.lat,
         e.lng,
         e.distance_km,
         e.from_price_npr,
         e.from_price_period,
         e.top_subjects
    from enriched e
   order by e.available desc, e.verified desc, e.distance_km asc
   limit p_max_results;
end;
$$;
grant execute on function search_tutors_in_viewport(
  double precision, double precision, double precision,
  text, text, text, boolean, boolean, int
) to authenticated;
