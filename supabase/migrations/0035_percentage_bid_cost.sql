-- Home Tuition Nepal — Percentage-based job-bid cost.
-- Run after 0034_percentage_connect_cost.sql.
--
-- Extends the percentage-based connect cost (0034) to the job-bid path
-- (`spend_coins_and_bid`). A bid now costs a percentage of the job's budget,
-- mirroring the vacancy apply cost, so every coin-spend "connect" in the app
-- scales with what the tutor stands to earn rather than a flat fee.
--
-- Job budgets carry two extra periods vs vacancies — 'day' and 'fixed'.
-- 'day' is normalized to a monthly equivalent; 'fixed' (one-off total) and
-- 'session' use the raw amount.

-- Assumed working days/month for daily budgets (mirrors AppConstants).
insert into platform_settings (key, value) values
  ('apply_cost_day_days', '26')
on conflict (key) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- job_apply_cost — pure read of a job's budget → clamped percentage.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function job_apply_cost(p_job_id uuid)
returns int
language plpgsql
stable
set search_path = public
as $$
declare
  b_min     numeric;
  b_max     numeric;
  b_period  text;
  pct       int := get_platform_setting_int('apply_cost_percent', 10);
  cost_min  int := get_platform_setting_int('apply_cost_min', 1);
  cost_max  int := get_platform_setting_int('apply_cost_max', 25);
  hours     int := get_platform_setting_int('apply_cost_hourly_hours', 30);
  days      int := get_platform_setting_int('apply_cost_day_days', 26);
  base      numeric;
  monthly   numeric;
  cost      int;
begin
  select budget_min_npr, budget_max_npr, budget_period
    into b_min, b_max, b_period
    from jobs
   where id = p_job_id;

  base := coalesce(b_max, b_min);

  if base is null or base <= 0 then
    return cost_min;
  end if;

  monthly := case b_period
               when 'hour' then base * hours
               when 'day'  then base * days
               else base
             end;
  cost := ceil(monthly * pct / 100.0);

  return greatest(cost_min, least(cost_max, cost));
end;
$$;
grant execute on function job_apply_cost(uuid) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- Re-point the bid RPC at job_apply_cost.
-- ────────────────────────────────────────────────────────────────────────────
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
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  cost := job_apply_cost(p_job_id);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'job', p_job_id,
    'Bid on job'
  );
  return new_balance;
end;
$$;
grant execute on function spend_coins_and_bid(uuid) to authenticated;
