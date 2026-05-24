-- Home Tuition Nepal — Phase 17 schema.
-- Expose tutor geog as plain lat/lng columns the Flutter client can read
-- without writing PostGIS expressions, and provide a small RPC the wizard
-- uses to update the caller's location.
--
-- Run after 0014_phase15_tutor_sequential_codes.sql.

-- Generated columns so plain `select lat, lng from tutors` works. PostGIS
-- already stores the canonical point in `geog`; these just project it back
-- into ordinary numeric columns the Dart repo can deserialize.
alter table tutors
  add column if not exists lat double precision
    generated always as (st_y(geog::geometry)) stored;
alter table tutors
  add column if not exists lng double precision
    generated always as (st_x(geog::geometry)) stored;

-- RPC the onboarding wizard calls when a tutor drops the map pin. Updates
-- the caller's own tutor row only — RLS prevents touching anyone else.
create or replace function set_tutor_location(p_lat double precision, p_lng double precision)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then
    raise exception 'auth_required';
  end if;
  update tutors
     set geog = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
   where id = caller;
end;
$$;

grant execute on function set_tutor_location(double precision, double precision) to authenticated;
