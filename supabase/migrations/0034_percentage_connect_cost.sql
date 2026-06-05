-- Home Tuition Nepal — Percentage-based connect (apply) cost.
-- Run after 0033_oauth_role_promotion.sql.
--
-- Replaces the flat `apply_coin_cost` (1 coin per application) with a cost that
-- scales with the vacancy's salary:
--
--     cost = clamp(ceil(monthly_salary * apply_cost_percent / 100),
--                  apply_cost_min, apply_cost_max)
--
-- Hourly salaries are normalized to a monthly equivalent first. The wallet
-- stays server-authoritative — this function is the single source of truth for
-- the apply cost; the Flutter `ConnectCost` helper only mirrors it for display.

-- ────────────────────────────────────────────────────────────────────────────
-- Tunable knobs (admins can edit these rows; defaults seeded once).
-- ────────────────────────────────────────────────────────────────────────────
insert into platform_settings (key, value) values
  ('apply_cost_percent',       '10'),   -- 10% of salary
  ('apply_cost_min',           '1'),    -- never free
  ('apply_cost_max',           '25'),   -- ceiling per application
  ('apply_cost_hourly_hours',  '30')    -- assumed hours/month for hourly jobs
on conflict (key) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- vacancy_apply_cost — pure read of a vacancy's salary → clamped percentage.
-- STABLE; reads vacancies + platform_settings only.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function vacancy_apply_cost(p_vacancy_id uuid)
returns int
language plpgsql
stable
set search_path = public
as $$
declare
  v_min     numeric;
  v_max     numeric;
  v_period  text;
  pct       int := get_platform_setting_int('apply_cost_percent', 10);
  cost_min  int := get_platform_setting_int('apply_cost_min', 1);
  cost_max  int := get_platform_setting_int('apply_cost_max', 25);
  hours     int := get_platform_setting_int('apply_cost_hourly_hours', 30);
  base      numeric;
  monthly   numeric;
  cost      int;
begin
  select salary_min_npr, salary_max_npr, salary_period
    into v_min, v_max, v_period
    from vacancies
   where id = p_vacancy_id;

  -- Upper band is what a tutor could earn; fall back to the lower band.
  base := coalesce(v_max, v_min);

  -- Unknown / non-positive salary → floor, so applying always costs something.
  if base is null or base <= 0 then
    return cost_min;
  end if;

  monthly := case when v_period = 'hour' then base * hours else base end;
  cost := ceil(monthly * pct / 100.0);

  return greatest(cost_min, least(cost_max, cost));
end;
$$;
grant execute on function vacancy_apply_cost(uuid) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- Re-point the apply RPCs at vacancy_apply_cost. tutor_apply_to_vacancy is the
-- one the Flutter client calls; apply_to_vacancy is the legacy debit-only path.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function tutor_apply_to_vacancy(
  p_vacancy_id   uuid,
  p_cover_note   text,
  p_expected_rate numeric,
  p_cv_path      text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  cost   int;
  app_id uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from tutors where id = caller) then
    raise exception 'not_a_tutor';
  end if;
  if not exists (select 1 from vacancies where id = p_vacancy_id and status = 'open') then
    raise exception 'vacancy_not_open';
  end if;
  if exists (select 1 from vacancy_applications where vacancy_id = p_vacancy_id and tutor_id = caller) then
    raise exception 'already_applied';
  end if;

  cost := vacancy_apply_cost(p_vacancy_id);

  -- Atomically debit coins via the existing helper, then insert the row.
  perform _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id, 'Applied to vacancy'
  );

  insert into vacancy_applications(vacancy_id, tutor_id, cover_note, expected_rate, cv_storage_path, coins_spent)
  values (p_vacancy_id, caller, p_cover_note, p_expected_rate, p_cv_path, cost)
  returning id into app_id;

  return app_id;
end;
$$;
grant execute on function tutor_apply_to_vacancy(uuid, text, numeric, text) to authenticated;

create or replace function apply_to_vacancy(p_vacancy_id uuid)
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
  cost := vacancy_apply_cost(p_vacancy_id);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id,
    'Applied to vacancy'
  );
  return new_balance;
end;
$$;
grant execute on function apply_to_vacancy(uuid) to authenticated;
