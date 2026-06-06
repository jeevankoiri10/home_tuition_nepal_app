-- Home Tuition Nepal — Cold-start & thin-market liquidity (matching algorithm P6).
-- Run after 0040_tutor_job_feed.sql.
--
-- See docs/matching-algorithm-design.md §7. The newcomer boost and exploration
-- slots already shipped (in match_score / 0037 and notify_matching_tutors / 0038).
-- This migration adds the two remaining cold-start levers:
--
--   1. THIN-AREA AUTO-RELAX — when an open post collects too few applicants in its
--      first window, progressively widen its reach (radius ×N → online anywhere →
--      drop geo) and re-notify the newly-reachable best-fit tutors, instead of
--      letting the post go silent. This serves the thin sub-markets outside the
--      Kathmandu Valley / Pokhara where a "perfect fit nearby" rarely exists.
--
--   2. SUPPLY-GAP REPORT — an admin read-out of where demand outstrips supply, by
--      niche and area, so the business knows where to recruit tutors.
--
-- SAFE ROLLOUT: the auto-relax scan is gated behind `relax_enabled` (default OFF)
-- and is a no-op until an admin flips it. Re-notification reuses the scored gate
-- from 0038 and is deduped against already-notified tutors, so no tutor is ever
-- notified twice for the same post.

-- ════════════════════════════════════════════════════════════════════════════
-- 1. Knobs + per-post relax state.
-- ════════════════════════════════════════════════════════════════════════════
insert into platform_settings (key, value) values
  ('relax_enabled',         'false'),  -- master flag for the auto-relax scan
  ('relax_after_hours',     '24'),     -- a post becomes eligible to relax this long after post / last relax
  ('relax_min_applicants',  '3'),      -- relax only while a post has fewer than this many applicants
  ('relax_max_level',       '3'),      -- 1=widen radius · 2=+online anywhere · 3=drop geo
  ('relax_radius_mult',     '2'),      -- in-person reach multiplier at relax level ≥1
  ('relax_min_score',       '25')      -- percent; relaxed re-notifications use a lower fit floor
on conflict (key) do nothing;

-- relax_level: how many times this post has been widened (0 = never).
-- last_relaxed_at: paces relaxation to one step per `relax_after_hours` window.
alter table vacancies add column if not exists relax_level    smallint    not null default 0;
alter table vacancies add column if not exists last_relaxed_at timestamptz;
alter table jobs      add column if not exists relax_level    smallint    not null default 0;
alter table jobs      add column if not exists last_relaxed_at timestamptz;

-- ════════════════════════════════════════════════════════════════════════════
-- 2. _renotify_relaxed — re-notify the best-fit tutors for ONE post at a given
-- relax level, with progressively widened geo. Returns the number notified.
--
-- Reuses the exact scored gate from notify_matching_tutors (0038): published +
-- gender + mode + subject-affinity, then top-K above a (lower) fit floor. The
-- only thing that widens is geography, by level:
--   level 1 → in-person reach × relax_radius_mult
--   level 2 → above, OR any online-capable tutor regardless of distance
--   level 3 → drop the geo gate entirely (subject/gender/mode still apply)
-- Deduped against existing notifications for the post, so re-notifying only ever
-- reaches tutors the earlier, narrower pass could not.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _renotify_relaxed(p_ref text, p_id uuid, p_level int)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  r_subject_ids int[];
  r_niche_ids   int[];
  r_grade       text;
  r_geog        geography;
  r_mode        text;
  r_budget_max  numeric;
  r_gender      text;
  body          text;
  ok            boolean := false;

  top_k     int     := get_platform_setting_int('match_notify_top_k', 20);
  min_score numeric := get_platform_setting_int('relax_min_score', 25) / 100.0;
  rad_mult  numeric := get_platform_setting_int('relax_radius_mult', 2);
  w         jsonb   := get_match_weights();
  n_inserted int := 0;
begin
  if not notif_kind_enabled('new_job_posted') then
    return 0;
  end if;

  if p_ref = 'vacancy' then
    select true, vc.subject_ids, vc.niche_tag_ids, vc.grade, vc.geog, vc.mode,
           vc.salary_max_npr, vc.gender_pref,
           coalesce(vc.title, 'Vacancy') || ' — ' || coalesce(vc.area_label, '—')
      into ok, r_subject_ids, r_niche_ids, r_grade, r_geog, r_mode, r_budget_max, r_gender, body
      from vacancies vc where vc.id = p_id and vc.status = 'open';
  elsif p_ref = 'job' then
    select true,
           case when jb.subject_id is not null then array[jb.subject_id] else '{}'::int[] end,
           jb.niche_tag_ids, jb.grade_level, jb.geog, jb.mode, jb.budget_max_npr, jb.gender_pref,
           coalesce(jb.title, 'Job') || ' in ' || coalesce(jb.area_label, '—')
      into ok, r_subject_ids, r_niche_ids, r_grade, r_geog, r_mode, r_budget_max, r_gender, body
      from jobs jb where jb.id = p_id and jb.status = 'open';
  end if;

  if not coalesce(ok, false) then
    return 0;   -- unknown ref or post no longer open
  end if;

  with gated as (
    select t as tut,
           match_score(r_subject_ids, r_niche_ids, r_grade, r_geog, r_mode, r_budget_max, t, w) as score
      from tutors t
     where t.draft_status = 'published'
       -- GENDER pref (null-tolerant)
       and (r_gender is null or r_gender = 'any' or t.gender is null or t.gender = r_gender)
       -- MODE hard-incompatibility
       and not (r_mode = 'online'    and t.teaching_mode = 'offline')
       and not (r_mode = 'in-person' and t.teaching_mode = 'online')
       -- SUBJECT affinity (skipped only when the post names no subject)
       and (coalesce(array_length(r_subject_ids, 1), 0) = 0
            or _subject_affinity(r_subject_ids, t.subject_ids) > 0)
       -- WIDENED GEO by relax level
       and (
            p_level >= 3                                                -- drop geo entirely
         or (p_level >= 2 and t.teaching_mode in ('online', 'both'))    -- online tutors anywhere
         or r_geog is null or t.geog is null
         or st_dwithin(t.geog, r_geog,
                       coalesce(t.service_radius_km, 5) * 1000 * greatest(rad_mult, 1))
       )
       -- DEDUP: never notify a tutor twice for the same post
       and not exists (
            select 1 from notifications n
             where n.user_id = t.id and n.ref_type = p_ref and n.ref_id = p_id)
  ),
  ranked as (
    select gated.*, row_number() over (order by score desc) as rn from gated
  )
  insert into notifications(user_id, kind, title, body, ref_type, ref_id, match_score, match_tier)
  select (tut).id, 'new_job_posted', 'Still open near you', body, p_ref, p_id, score, 2  -- tier 2 = relaxed reach
    from ranked
   where rn <= top_k and score >= min_score;

  get diagnostics n_inserted = row_count;
  return n_inserted;
end;
$$;
revoke all on function _renotify_relaxed(text, uuid, int) from public;
grant execute on function _renotify_relaxed(text, uuid, int) to service_role;

-- ════════════════════════════════════════════════════════════════════════════
-- 3. auto_relax_thin_posts — the scan. Finds open posts that are old enough and
-- still short of applicants, bumps their relax_level one step, and re-notifies.
-- Idempotent and self-pacing: last_relaxed_at gates each post to at most one step
-- per `relax_after_hours`, so a post widens gradually (radius@24h → online@48h →
-- anywhere@72h) until it fills or hits relax_max_level. Call from a scheduler
-- (pg_cron or an edge function) — see footer. Gated behind `relax_enabled`.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function auto_relax_thin_posts()
returns table(post_ref text, post_id uuid, new_level int, notified int)
language plpgsql
security definer
set search_path = public
as $$
declare
  enabled boolean := lower(coalesce(
             (select value from platform_settings where key = 'relax_enabled'),
             'false')) in ('true', 't', '1', 'yes', 'on');
  after_h int := get_platform_setting_int('relax_after_hours', 24);
  min_app int := get_platform_setting_int('relax_min_applicants', 3);
  max_lvl int := get_platform_setting_int('relax_max_level', 3);
  rec     record;
  cnt     int;
begin
  if not enabled then
    return;
  end if;

  -- VACANCIES — applicants tracked in vacancy_applications.
  for rec in
    select vc.id as vid, vc.relax_level as lvl
      from vacancies vc
     where vc.status = 'open'
       and vc.relax_level < max_lvl
       and coalesce(vc.last_relaxed_at, vc.created_at) < now() - (after_h || ' hours')::interval
       and (select count(*) from vacancy_applications a where a.vacancy_id = vc.id) < min_app
  loop
    cnt := _renotify_relaxed('vacancy', rec.vid, rec.lvl + 1);
    update vacancies set relax_level = rec.lvl + 1, last_relaxed_at = now() where id = rec.vid;
    post_ref := 'vacancy'; post_id := rec.vid; new_level := rec.lvl + 1; notified := cnt;
    return next;
  end loop;

  -- JOBS — applies are wallet debits (reason='apply', ref_type='job').
  for rec in
    select jb.id as vid, jb.relax_level as lvl
      from jobs jb
     where jb.status = 'open'
       and jb.relax_level < max_lvl
       and coalesce(jb.last_relaxed_at, jb.created_at) < now() - (after_h || ' hours')::interval
       and (select count(*) from wallet_ledger wl
             where wl.ref_type = 'job' and wl.ref_id = jb.id and wl.reason = 'apply') < min_app
  loop
    cnt := _renotify_relaxed('job', rec.vid, rec.lvl + 1);
    update jobs set relax_level = rec.lvl + 1, last_relaxed_at = now() where id = rec.vid;
    post_ref := 'job'; post_id := rec.vid; new_level := rec.lvl + 1; notified := cnt;
    return next;
  end loop;
end;
$$;
revoke all on function auto_relax_thin_posts() from public;
grant execute on function auto_relax_thin_posts() to service_role;

-- ════════════════════════════════════════════════════════════════════════════
-- 4. supply_gap_report — admin read-out of demand vs. supply by niche (with the
-- hottest demand areas per niche). "Where should we recruit tutors?" Demand =
-- open postings in the last p_days that name the niche; supply = published tutors
-- carrying that niche (active = seen in the last 30 days). is_gap flags niches
-- with live demand but fewer than 3 active tutors (the §6.1 coverage threshold).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function supply_gap_report(p_days int default 30)
returns table(
  niche_tag_id   int,
  niche_slug     text,
  niche_name     text,
  category       text,
  demand_count   bigint,    -- open posts (last p_days) needing this niche
  supply_count   bigint,    -- published tutors tagged with this niche
  active_supply  bigint,    -- of those, seen in the last 30 days
  coverage_ratio numeric,   -- active_supply ÷ demand (null when no demand)
  is_gap         boolean,   -- demand > 0 and active_supply < 3
  top_areas      text[]     -- up to 3 areas with the most open demand
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'supply_gap_report: admin only';
  end if;

  return query
  with demand as (
    select unnest(vc.niche_tag_ids) as nid, vc.area_label
      from vacancies vc
     where vc.status = 'open' and vc.created_at >= now() - (p_days || ' days')::interval
    union all
    select unnest(jb.niche_tag_ids), jb.area_label
      from jobs jb
     where jb.status = 'open' and jb.created_at >= now() - (p_days || ' days')::interval
  ),
  dem_agg as (
    select nid, count(*) as demand_count from demand group by nid
  ),
  area_rank as (
    select nid, area_label, count(*) as c,
           row_number() over (partition by nid order by count(*) desc) as rn
      from demand where area_label is not null
     group by nid, area_label
  ),
  top_areas_agg as (
    select nid, array_agg(area_label order by c desc) as areas
      from area_rank where rn <= 3 group by nid
  ),
  supply as (
    select unnest(t.niche_tag_ids) as nid,
           count(*) as supply_count,
           count(*) filter (where t.last_seen >= now() - interval '30 days') as active_supply
      from tutors t where t.draft_status = 'published'
     group by 1
  )
  select nt.id, nt.slug, nt.display_name, nt.category,
         coalesce(d.demand_count, 0),
         coalesce(s.supply_count, 0),
         coalesce(s.active_supply, 0),
         round(coalesce(s.active_supply, 0)::numeric / nullif(d.demand_count, 0), 2),
         (coalesce(d.demand_count, 0) > 0 and coalesce(s.active_supply, 0) < 3),
         coalesce(ta.areas, '{}'::text[])
    from niche_tags nt
    left join dem_agg       d  on d.nid  = nt.id
    left join supply        s  on s.nid  = nt.id
    left join top_areas_agg ta on ta.nid = nt.id
   where coalesce(d.demand_count, 0) > 0 or coalesce(s.supply_count, 0) > 0
   order by (coalesce(d.demand_count, 0) > 0 and coalesce(s.active_supply, 0) < 3) desc,
            coalesce(d.demand_count, 0) desc;
end;
$$;
revoke all on function supply_gap_report(int) from public;
grant execute on function supply_gap_report(int) to authenticated;

-- ════════════════════════════════════════════════════════════════════════════
-- 5. Scheduling (optional). Run auto_relax_thin_posts() hourly. If pg_cron is
-- available on this Supabase project, uncomment:
--
--   select cron.schedule('htn-auto-relax', '17 * * * *',
--                        $$ select public.auto_relax_thin_posts(); $$);
--
-- Otherwise call it from a scheduled edge function with the service_role key.
-- ════════════════════════════════════════════════════════════════════════════
