-- Home Tuition Nepal — Top-K scored notifications (matching algorithm P3).
-- Run after 0037_match_score.sql.
--
-- See docs/matching-algorithm-design.md §5.1. Rewrites notify_matching_tutors()
-- so a new job/vacancy notifies only the BEST-fit tutors (top-K above a score
-- threshold) plus a couple of exploration slots for unproven-but-fitting tutors —
-- instead of blasting every tutor in radius. The match_score and tier are stored
-- on each notification row for the tutor's feed and for outcome analysis (P7).
--
-- SAFE ROLLOUT: gated behind `match_notify_enabled` (default OFF). While off, the
-- original 0031 broadcast behaviour is preserved verbatim, so this migration is a
-- no-op until an admin flips the flag — enabling a clean A/B.

-- ════════════════════════════════════════════════════════════════════════════
-- 1. Additive columns + knobs.
-- ════════════════════════════════════════════════════════════════════════════
alter table notifications add column if not exists match_score numeric;
alter table notifications add column if not exists match_tier  smallint;   -- 0=top-K, 1=exploration

-- Tutor gender enables the (null-tolerant) gender_pref hard gate. Existing rows
-- stay NULL → never excluded until the onboarding flow captures it (app-side TODO).
alter table tutors add column if not exists gender text check (gender in ('male','female','other'));

insert into platform_settings (key, value) values
  ('match_notify_enabled',       'false'),  -- master flag for the scored path (A/B)
  ('match_notify_top_k',         '20'),     -- max strong matches notified per post
  ('match_notify_min_score',     '35'),     -- percent; tutors below this aren't notified…
  ('match_notify_explore_slots', '2')       -- …except this many unproven high-fit tutors
on conflict (key) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 2. Rewritten trigger function.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function notify_matching_tutors() returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  body             text;
  ref              text;
  v_subject_single text;     -- jobs.subject (single, legacy substring path)
  v_subjects       text[];   -- vacancies.subjects (array, legacy substring path)
  v_match_subject  boolean;  -- whether the post names a subject

  -- request fields for the scorer
  r_subject_ids int[];
  r_niche_ids   int[];
  r_grade       text;
  r_geog        geography;
  r_mode        text;
  r_budget_max  numeric;
  r_gender      text;

  -- knobs
  use_score  boolean := lower(coalesce(
                 (select value from platform_settings where key = 'match_notify_enabled'),
                 'false')) in ('true','t','1','yes','on');
  top_k      int     := get_platform_setting_int('match_notify_top_k', 20);
  min_score  numeric := get_platform_setting_int('match_notify_min_score', 35) / 100.0;
  explore    int     := get_platform_setting_int('match_notify_explore_slots', 2);
  w          jsonb   := get_match_weights();
begin
  if not notif_kind_enabled('new_job_posted') then
    return new;
  end if;

  if tg_table_name = 'jobs' and new.status = 'open' then
    body := coalesce(new.title, 'New job posted') || ' in ' || coalesce(new.area_label, '—');
    ref  := 'job';
    v_subject_single := new.subject;
    v_match_subject  := new.subject is not null;
    r_subject_ids := case when new.subject_id is not null then array[new.subject_id] else '{}'::int[] end;
    r_niche_ids   := new.niche_tag_ids;
    r_grade       := new.grade_level;
    r_geog        := new.geog;
    r_mode        := new.mode;
    r_budget_max  := new.budget_max_npr;
    r_gender      := new.gender_pref;
  elsif tg_table_name = 'vacancies' and new.status = 'open' then
    body := coalesce(new.title, 'New vacancy') || ' — ' || coalesce(new.area_label, '—');
    ref  := 'vacancy';
    v_subjects      := new.subjects;
    v_match_subject := coalesce(array_length(new.subjects, 1), 0) > 0;
    r_subject_ids := new.subject_ids;
    r_niche_ids   := new.niche_tag_ids;
    r_grade       := new.grade;
    r_geog        := new.geog;
    r_mode        := new.mode;
    r_budget_max  := new.salary_max_npr;
    r_gender      := new.gender_pref;
  else
    return new;
  end if;

  -- ──────────────────────────────────────────────────────────────────────────
  -- LEGACY broadcast path (flag off) — identical to 0031, kept for A/B.
  -- ──────────────────────────────────────────────────────────────────────────
  if not use_score then
    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    select t.id, 'new_job_posted', 'New job posted', body, ref, new.id
      from tutors t
     where t.draft_status = 'published'
       and (new.geog is null or t.geog is null
            or st_dwithin(t.geog, new.geog, coalesce(t.service_radius_km, 5) * 1000))
       and (
         not v_match_subject
         or exists (
           select 1 from tutor_offerings o
            where o.tutor_id = t.id
              and ( (tg_table_name = 'jobs' and lower(o.subject) = lower(v_subject_single))
                 or (tg_table_name = 'vacancies'
                     and exists (select 1 from unnest(v_subjects) s where lower(s) = lower(o.subject))) )
         )
       );
    return new;
  end if;

  -- ──────────────────────────────────────────────────────────────────────────
  -- SCORED path (flag on): gate → score → top-K + threshold + exploration.
  -- ──────────────────────────────────────────────────────────────────────────
  with gated as (
    select t as tut,
           match_score(r_subject_ids, r_niche_ids, r_grade, r_geog, r_mode, r_budget_max, t, w) as score
      from tutors t
     where t.draft_status = 'published'
       -- AREA (null-tolerant)
       and (r_geog is null or t.geog is null
            or st_dwithin(t.geog, r_geog, coalesce(t.service_radius_km, 5) * 1000))
       -- GENDER pref (null-tolerant: exclude only when tutor gender is known & differs)
       and (r_gender is null or r_gender = 'any' or t.gender is null or t.gender = r_gender)
       -- MODE hard-incompatibility
       and not (r_mode = 'online'    and t.teaching_mode = 'offline')
       and not (r_mode = 'in-person' and t.teaching_mode = 'online')
       -- SUBJECT: some affinity required when the post names a subject. Tolerates
       -- not-yet-backfilled tutors via the legacy substring match.
       and (
         not v_match_subject
         or _subject_affinity(r_subject_ids, t.subject_ids) > 0
         or exists (
           select 1 from tutor_offerings o
            where o.tutor_id = t.id
              and ( (tg_table_name = 'jobs' and lower(o.subject) = lower(v_subject_single))
                 or (tg_table_name = 'vacancies'
                     and exists (select 1 from unnest(v_subjects) s where lower(s) = lower(o.subject))) )
         )
       )
  ),
  ranked as (
    select gated.*, row_number() over (order by score desc) as rn from gated
  ),
  top as (
    -- strong matches; plus a liquidity floor so a post never goes silent
    select tut, score, 0 as tier from ranked
     where rn <= top_k and (score >= min_score or rn <= 3)
  ),
  explore_pool as (
    -- unproven (<3 connects) high-fit tutors not already chosen — earn impressions
    select g.tut, g.score, 1 as tier
      from gated g
     where g.score >= min_score * 0.6
       and coalesce((g.tut).rating_count, 0) < 3
       and not exists (select 1 from top where (top.tut).id = (g.tut).id)
     order by g.score desc
     limit explore
  )
  insert into notifications(user_id, kind, title, body, ref_type, ref_id, match_score, match_tier)
  select (u.tut).id, 'new_job_posted', 'New job posted', body, ref, new.id, u.score, u.tier
    from (select * from top union all select * from explore_pool) u;

  return new;
end;
$$;
