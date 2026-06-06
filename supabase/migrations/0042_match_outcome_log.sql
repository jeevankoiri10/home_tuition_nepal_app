-- Home Tuition Nepal — Match outcome log + funnel metrics (matching algorithm P7).
-- Run after 0041_cold_start.sql.
--
-- See docs/matching-algorithm-design.md §6 / §6.1. Captures the match_score (and
-- tier) at the moment a tutor APPLIES, so over time we accumulate labelled data:
-- which scores convert to applies, shortlists and hires. This is what earns the
-- right to hand-tune weights now (and a learned ranker later).
--
--   1. match_apply_log — one row per (post, tutor) apply, across BOTH surfaces
--      (vacancy applications and job bids), with the score/tier computed at apply
--      time. Vacancy applications also carry the score inline for the tutor's UI.
--   2. match_funnel_metrics(days) — an admin read-out of the §6.1 funnel:
--      match→apply rate by score bucket, fill rate, time-to-first-applicant,
--      time-to-fill.
--
-- All additive: new table + nullable columns + wider apply RPCs that keep their
-- existing behaviour and only append logging.

-- ════════════════════════════════════════════════════════════════════════════
-- 1. Inline score on vacancy applications (for the tutor's own "why matched").
-- ════════════════════════════════════════════════════════════════════════════
alter table vacancy_applications add column if not exists match_score numeric;
alter table vacancy_applications add column if not exists match_tier  smallint;

-- ════════════════════════════════════════════════════════════════════════════
-- 2. Unified apply log — the analytics source of truth across both surfaces.
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists match_apply_log (
  id          uuid primary key default uuid_generate_v4(),
  ref_type    text not null check (ref_type in ('vacancy', 'job')),
  ref_id      uuid not null,
  tutor_id    uuid not null references profiles(id) on delete cascade,
  match_score numeric,
  match_tier  smallint,
  coins_spent integer not null default 0,
  applied_at  timestamptz not null default now(),
  unique (ref_type, ref_id, tutor_id)
);
create index if not exists match_apply_log_ref_idx   on match_apply_log(ref_type, ref_id);
create index if not exists match_apply_log_score_idx on match_apply_log(applied_at, match_score);

alter table match_apply_log enable row level security;

-- Tutor reads their own log rows; admin reads all. Rows are written only by the
-- SECURITY DEFINER apply RPCs below (which bypass RLS) — no insert policy needed.
drop policy if exists match_apply_log_select on match_apply_log;
create policy match_apply_log_select
  on match_apply_log for select
  using (auth.uid() = tutor_id or exists (select 1 from admin_users where id = auth.uid()));

-- ════════════════════════════════════════════════════════════════════════════
-- 3. _compute_match_score — score one (post, tutor) pair using the live weights.
-- Returns NULL when the tutor or post can't be loaded, so logging never blocks an
-- apply. Mirrors the request→scorer field mapping used by tutor_job_feed (0040).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _compute_match_score(p_ref text, p_id uuid, p_tutor uuid)
returns numeric
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  t tutors;
  w jsonb := get_match_weights();
  s numeric;
begin
  select * into t from tutors where id = p_tutor;
  if t.id is null then
    return null;
  end if;

  if p_ref = 'vacancy' then
    select match_score(vc.subject_ids, vc.niche_tag_ids, vc.grade, vc.geog,
                       vc.mode, vc.salary_max_npr, t, w)
      into s from vacancies vc where vc.id = p_id;
  elsif p_ref = 'job' then
    select match_score(case when jb.subject_id is not null then array[jb.subject_id] else '{}'::int[] end,
                       jb.niche_tag_ids, jb.grade_level, jb.geog,
                       jb.mode, jb.budget_max_npr, t, w)
      into s from jobs jb where jb.id = p_id;
  end if;

  return s;
end;
$$;

-- Score → tier bucket, matching tutor_job_feed (0040): 0 strong · 1 ok · 2 weak.
create or replace function _match_tier(s numeric)
returns smallint
language sql
immutable
as $$
  select case when s is null then null
              when s >= 0.6  then 0
              when s >= 0.35 then 1
              else 2 end::smallint;
$$;

-- ════════════════════════════════════════════════════════════════════════════
-- 4. Re-create the apply RPCs to append outcome logging (behaviour unchanged).
-- ════════════════════════════════════════════════════════════════════════════
create or replace function tutor_apply_to_vacancy(
  p_vacancy_id    uuid,
  p_cover_note    text,
  p_expected_rate numeric,
  p_cv_path       text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  cost   int;
  app_id uuid;
  s      numeric;
  tier   smallint;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;  -- preserved from 0010
  if not exists (select 1 from tutors where id = caller) then
    raise exception 'not_a_tutor';
  end if;
  if not exists (select 1 from vacancies where id = p_vacancy_id and status = 'open') then
    raise exception 'vacancy_not_open';
  end if;
  if exists (select 1 from vacancy_applications where vacancy_id = p_vacancy_id and tutor_id = caller) then
    raise exception 'already_applied';
  end if;

  -- Percentage-based connect cost (0034) — NOT the legacy flat apply_coin_cost.
  cost := vacancy_apply_cost(p_vacancy_id);

  -- Atomically debit coins via the existing helper, then insert the row.
  perform _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id, 'Applied to vacancy'
  );

  -- P7: score the pair at apply time for outcome analysis + the tutor's UI.
  s    := _compute_match_score('vacancy', p_vacancy_id, caller);
  tier := _match_tier(s);

  insert into vacancy_applications(vacancy_id, tutor_id, cover_note, expected_rate,
                                   cv_storage_path, coins_spent, match_score, match_tier)
  values (p_vacancy_id, caller, p_cover_note, p_expected_rate, p_cv_path, cost, s, tier)
  returning id into app_id;

  insert into match_apply_log(ref_type, ref_id, tutor_id, match_score, match_tier, coins_spent)
  values ('vacancy', p_vacancy_id, caller, s, tier, cost)
  on conflict (ref_type, ref_id, tutor_id) do nothing;

  return app_id;
end;
$$;
grant execute on function tutor_apply_to_vacancy(uuid, text, numeric, text) to authenticated;

create or replace function spend_coins_and_bid(p_job_id uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  caller       uuid := auth.uid();
  cost         int;
  new_balance  int;
  s            numeric;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;  -- blocked users can't bid
  cost := job_apply_cost(p_job_id);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'job', p_job_id,
    'Bid on job'
  );

  -- P7: log the outcome (score at apply time). Best-effort — never block the bid.
  s := _compute_match_score('job', p_job_id, caller);
  insert into match_apply_log(ref_type, ref_id, tutor_id, match_score, match_tier, coins_spent)
  values ('job', p_job_id, caller, s, _match_tier(s), cost)
  on conflict (ref_type, ref_id, tutor_id) do nothing;

  return new_balance;
end;
$$;
grant execute on function spend_coins_and_bid(uuid) to authenticated;

-- ════════════════════════════════════════════════════════════════════════════
-- 5. match_funnel_metrics — admin §6.1 dashboard feed. Returns one jsonb blob:
--   { window_days,
--     buckets: { strong|ok|weak: { notified, applied, apply_rate } },
--     vacancies: { posted, filled, fill_rate,
--                  avg_hours_to_first_applicant, avg_hours_to_fill } }
-- match→apply is a funnel proxy (notified vs applied per score bucket over the
-- window), not a per-post join — enough to see whether high-fit notifications
-- convert better, which is the tuning question.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function match_funnel_metrics(p_days int default 30)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  since  timestamptz := now() - (p_days || ' days')::interval;
  result jsonb;
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'match_funnel_metrics: admin only';
  end if;

  with notif as (
    select case when match_score >= 0.6 then 'strong'
                when match_score >= 0.35 then 'ok' else 'weak' end as bucket,
           count(*) as c
      from notifications
     where kind = 'new_job_posted' and match_score is not null and created_at >= since
     group by 1
  ),
  appl as (
    select case when match_score >= 0.6 then 'strong'
                when match_score >= 0.35 then 'ok' else 'weak' end as bucket,
           count(*) as c
      from match_apply_log
     where match_score is not null and applied_at >= since
     group by 1
  ),
  bk as (select unnest(array['strong', 'ok', 'weak']) as bucket)
  select jsonb_object_agg(bk.bucket, jsonb_build_object(
           'notified',   coalesce(n.c, 0),
           'applied',    coalesce(a.c, 0),
           'apply_rate', round(coalesce(a.c, 0)::numeric / nullif(n.c, 0), 4)))
    into result
    from bk
    left join notif n on n.bucket = bk.bucket
    left join appl  a on a.bucket = bk.bucket;

  result := jsonb_build_object('window_days', p_days, 'buckets', result)
         || jsonb_build_object('vacancies', (
              select jsonb_build_object(
                'posted', count(*) filter (where v.created_at >= since),
                'filled', count(*) filter (where v.status = 'filled' and v.created_at >= since),
                'fill_rate', round(
                   count(*) filter (where v.status = 'filled' and v.created_at >= since)::numeric
                   / nullif(count(*) filter (where v.created_at >= since), 0), 4),
                'avg_hours_to_first_applicant', (
                   select round(avg(extract(epoch from (fa.first_app - v2.created_at)) / 3600.0)::numeric, 1)
                     from vacancies v2
                     join lateral (select min(a.created_at) as first_app
                                     from vacancy_applications a where a.vacancy_id = v2.id) fa on true
                    where v2.created_at >= since and fa.first_app is not null),
                'avg_hours_to_fill', (
                   -- approximation: status flips to 'filled' touch updated_at (admin_assign_vacancy)
                   select round(avg(extract(epoch from (v3.updated_at - v3.created_at)) / 3600.0)::numeric, 1)
                     from vacancies v3
                    where v3.status = 'filled' and v3.created_at >= since)
              ) from vacancies v));

  return result;
end;
$$;
revoke all on function match_funnel_metrics(int) from public;
grant execute on function match_funnel_metrics(int) to authenticated;
