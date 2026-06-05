-- Home Tuition Nepal — Composite match score (matching algorithm P2).
-- Run after 0036_subject_niche_taxonomy.sql.
--
-- See docs/matching-algorithm-design.md §3. One STABLE SQL function returns a
-- [0,1] fit score for a (request, tutor) pair, built only from columns we already
-- store + the P1 taxonomy. It is pure scoring — HARD GATES (gender, mode,
-- published) live in the WHERE clause of the calling RPC (P3/P4), never here.
--
-- Null-tolerant by design: a component that cannot be computed (e.g. distance for
-- an online request, budget when neither side priced) is SKIPPED and its weight
-- is renormalized away, so missing data never silently penalizes a candidate.
--
-- Functions are STABLE (they read tables + now()), which is sufficient for use in
-- ORDER BY / WHERE. The design sketch's "immutable" was aspirational.

-- ════════════════════════════════════════════════════════════════════════════
-- Tunable weights. Admins edit the single `match_weights` jsonb row; the scorer
-- merges it over these defaults so a missing key never breaks scoring.
-- ════════════════════════════════════════════════════════════════════════════
insert into platform_settings (key, value) values
  ('match_weights', '{
     "subject": 0.22, "niche": 0.13, "level": 0.12, "distance": 0.18,
     "mode": 0.05, "budget": 0.10, "quality": 0.10, "availability": 0.05,
     "freshness": 0.05, "newcomer_boost": 0.05, "freshness_days": 14,
     "niche_floor": 0.15
   }')
on conflict (key) do nothing;

create or replace function get_match_weights()
returns jsonb
language sql
stable
set search_path = public
as $$
  select '{
     "subject": 0.22, "niche": 0.13, "level": 0.12, "distance": 0.18,
     "mode": 0.05, "budget": 0.10, "quality": 0.10, "availability": 0.05,
     "freshness": 0.05, "newcomer_boost": 0.05, "freshness_days": 14,
     "niche_floor": 0.15
   }'::jsonb || coalesce(
     (select value::jsonb from platform_settings where key = 'match_weights'), '{}'::jsonb);
$$;
grant execute on function get_match_weights() to authenticated, anon;

-- ════════════════════════════════════════════════════════════════════════════
-- Helper: Jaccard overlap of two int arrays → [0,1]. Empty/empty → 0.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _jaccard(a int[], b int[])
returns numeric
language sql
immutable
as $$
  with ua as (select distinct unnest(coalesce(a,'{}')) as x),
       ub as (select distinct unnest(coalesce(b,'{}')) as x),
       i  as (select count(*) c from (select x from ua intersect select x from ub) z),
       u  as (select count(*) c from (select x from ua union     select x from ub) z)
  select case when (select c from u) = 0 then 0
              else (select c from i)::numeric / (select c from u) end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- Helper: subject affinity — Jaccard, with partial credit for a parent/child
-- relation (a physics tutor for a "science" request scores 0.5, not 0).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _subject_affinity(req int[], tut int[])
returns numeric
language plpgsql
stable
set search_path = public
as $$
declare
  direct numeric := _jaccard(req, tut);
  related boolean;
begin
  if direct > 0 then
    return direct;
  end if;
  if req is null or tut is null or array_length(req,1) is null or array_length(tut,1) is null then
    return 0;
  end if;
  -- any request subject that is the parent or child of any tutor subject?
  select exists (
    select 1 from subjects sr, subjects st
     where sr.id = any(req) and st.id = any(tut)
       and (sr.parent_id = st.id or st.parent_id = sr.id)
  ) into related;
  return case when related then 0.5 else 0 end;
end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- Helper: budget compatibility. Compares the request budget to the tutor's
-- cheapest offering (monthly-normalized). Tutor at/under budget → 1; above →
-- linear decay; missing budget or no priced offering → NULL (component skipped).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _match_budget(req_max numeric, p_tutor uuid)
returns numeric
language plpgsql
stable
set search_path = public
as $$
declare
  tutor_min numeric;
begin
  if req_max is null or req_max <= 0 then
    return null;
  end if;
  -- cheapest monthly-equivalent ask across the tutor's offerings
  select min(case when price_period = 'hour'    then price_min_npr * 30
                  when price_period = 'day'     then price_min_npr * 26
                  when price_period = 'session' then price_min_npr * 12
                  else price_min_npr end)
    into tutor_min
    from tutor_offerings where tutor_id = p_tutor and price_min_npr > 0;

  if tutor_min is null then
    return null;
  end if;
  if tutor_min <= req_max then
    return 1;
  end if;
  -- up to 50% over budget still scores; beyond that → 0
  return greatest(0, 1 - (tutor_min - req_max) / (req_max * 0.5));
end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- Helper: availability coverage proxy — fraction of the 21 (3×7) bands the tutor
-- marks free. A real time-band match awaits structured request schedules
-- (design §8.1 open question); until then "more available" ranks higher.
-- NULL when the tutor has no availability row → component skipped.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _match_avail(p_tutor uuid)
returns numeric
language plpgsql
stable
set search_path = public
as $$
declare
  v_slots jsonb;
  v_true  int;
begin
  select slots into v_slots from tutor_availability where tutor_id = p_tutor;
  if v_slots is null or v_slots = '{}'::jsonb then
    return null;
  end if;
  select count(*) into v_true
    from jsonb_each(v_slots) day, jsonb_array_elements(day.value) band
   where band::text = 'true';
  return least(1, v_true::numeric / 21.0);
exception when others then
  return null;  -- tolerate any non-conforming slots shape
end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- Helper: freshness — 1 if seen now, linear decay to 0 over `days`. NULL if
-- the tutor has never been seen.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _freshness(ls timestamptz, days numeric)
returns numeric
language sql
stable
as $$
  select case
    when ls is null then null
    else greatest(0, 1 - extract(epoch from (now() - ls)) / (days * 86400.0))
  end;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- match_score — the composite. Pass the request fields + the tutor row + weights
-- (call get_match_weights() once per query and pass it in to avoid re-reading).
-- Returns [0,1]. Components that are NULL are skipped and their weight is
-- renormalized away; the newcomer boost is added on top, then clamped.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function match_score(
  req_subject_ids int[],
  req_niche_ids   int[],
  req_grade       text,
  req_geog        geography,
  req_mode        text,             -- 'in-person' | 'online' | 'either'
  req_budget_max  numeric,
  t               tutors,
  w               jsonb
) returns numeric
language plpgsql
stable
set search_path = public
as $$
declare
  num    numeric := 0;   -- Σ weight·component over present components
  den    numeric := 0;   -- Σ weight over present components
  c      numeric;
  wv     numeric;
  fdays  numeric := coalesce((w->>'freshness_days')::numeric, 14);
  nfloor numeric := coalesce((w->>'niche_floor')::numeric, 0.15);
  boost  numeric := 0;
  bmax   numeric := coalesce((w->>'newcomer_boost')::numeric, 0.05);
  age_d  numeric;
begin
  -- subject (affinity incl. parent/child)
  c := _subject_affinity(req_subject_ids, t.subject_ids);
  wv := (w->>'subject')::numeric; num := num + wv*c; den := den + wv;

  -- niche (Jaccard with a floor so untagged same-subject tutors aren't zeroed)
  c := greatest(_jaccard(req_niche_ids, t.niche_tag_ids), nfloor);
  wv := (w->>'niche')::numeric; num := num + wv*c; den := den + wv;

  -- level (grade ∈ tutor levels) — skipped if request has no grade
  if req_grade is not null and req_grade <> '' then
    c := case when req_grade = any(t.levels_taught) then 1 else 0 end;
    wv := (w->>'level')::numeric; num := num + wv*c; den := den + wv;
  end if;

  -- distance — only for in-person/either requests with both points known
  if req_mode <> 'online' and req_geog is not null and t.geog is not null then
    c := 1 - least(st_distance(req_geog, t.geog) / 1000.0
                   / nullif(coalesce(t.service_radius_km, 5), 0), 1);
    wv := (w->>'distance')::numeric; num := num + wv*greatest(c,0); den := den + wv;
  end if;

  -- mode (map request in-person/online/either ↔ tutor offline/online/both)
  c := case
         when req_mode = 'either' or t.teaching_mode = 'both' then 1
         when req_mode = 'online'    and t.teaching_mode = 'online'  then 1
         when req_mode = 'in-person' and t.teaching_mode = 'offline' then 1
         else 0 end;
  wv := (w->>'mode')::numeric; num := num + wv*c; den := den + wv;

  -- budget — skipped when neither side priced
  c := _match_budget(req_budget_max, t.id);
  if c is not null then
    wv := (w->>'budget')::numeric; num := num + wv*c; den := den + wv;
  end if;

  -- quality (normalized ranking_score; max ≈143 per design §5.1 of the codebase)
  c := least(coalesce(t.ranking_score, 0) / 143.0, 1);
  wv := (w->>'quality')::numeric; num := num + wv*c; den := den + wv;

  -- availability (coverage proxy) — skipped when no availability row
  c := _match_avail(t.id);
  if c is not null then
    wv := (w->>'availability')::numeric; num := num + wv*c; den := den + wv;
  end if;

  -- freshness — skipped when never seen
  c := _freshness(t.last_seen, fdays);
  if c is not null then
    wv := (w->>'freshness')::numeric; num := num + wv*c; den := den + wv;
  end if;

  -- newcomer boost: full for brand-new + <3 connects, decaying to 0 by whichever
  -- of (30 days, 3 reviewed connects) comes first. Counters rich-get-richer.
  if coalesce(t.rating_count, 0) < 3 then
    age_d := extract(epoch from (now() - t.created_at)) / 86400.0;
    if age_d < 30 then
      boost := bmax * (1 - greatest(age_d / 30.0, coalesce(t.rating_count,0) / 3.0));
    end if;
  end if;

  if den = 0 then
    return boost;  -- no scorable component (shouldn't happen — subject always present)
  end if;
  return least(1, num / den + boost);
end;
$$;
grant execute on function match_score(int[], int[], text, geography, text, numeric, tutors, jsonb) to authenticated, anon;
