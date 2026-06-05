-- Home Tuition Nepal — Server-bound the boost/promote durations (economic).
-- Run after 0048_revoke_internal_coin_rpcs.sql.
--
-- VULNERABILITY (economic): boost_tutor_featured(p_hours) and
-- promote_job(p_job_id, p_hours) (0008) charge a FLAT cost
-- (featured_listing_cost / promoted_job_cost) but set the boost/promotion
-- duration from the client-supplied p_hours, unbounded. The legitimate client
-- always sends 24 (there is no per-duration pricing tier), but a direct RPC
-- call could pass p_hours => 999999 and obtain a near-permanent featured
-- listing / promoted job for a single flat charge. This is the same
-- "client-controlled value the server trusts" class as the coin-top-up and
-- apply-cost bugs (0044/0045) — duration must be server-authoritative.
--
-- FIX: clamp the effective duration to [1, max], where max comes from a
-- platform setting (default 24h = today's intended cap). Passing 999999 now
-- yields max; passing 0/negative yields 1; the normal 24 is unchanged. Cost,
-- ownership checks, extend-from-current behaviour and the function signatures
-- are all preserved, so the client contract is unaffected. Admins can widen the
-- cap later by raising featured_listing_hours / promoted_job_hours.

create or replace function boost_tutor_featured(p_hours int default 24)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  caller      uuid := auth.uid();
  cost        int;
  max_hours   int;
  eff_hours   int;
  new_balance int;
  new_until   timestamptz;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from tutors where id = caller) then
    raise exception 'not_a_tutor';
  end if;
  cost := get_platform_setting_int('featured_listing_cost', 50);
  max_hours := get_platform_setting_int('featured_listing_hours', 24);
  eff_hours := least(greatest(coalesce(p_hours, max_hours), 1), max_hours);
  new_balance := _ledger_apply(caller, -cost, 'boost', 'tutor', caller, 'Featured listing');
  new_until := greatest(
    coalesce((select featured_until from tutors where id = caller), now()),
    now()
  ) + make_interval(hours => eff_hours);
  update tutors set featured_until = new_until where id = caller;
  perform recompute_tutor_rating(caller);
  return new_balance;
end;
$$;
grant execute on function boost_tutor_featured(int) to authenticated;

create or replace function promote_job(p_job_id uuid, p_hours int default 24)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  caller      uuid := auth.uid();
  cost        int;
  max_hours   int;
  eff_hours   int;
  new_balance int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from jobs where id = p_job_id and student_id = caller) then
    raise exception 'not_owner';
  end if;
  cost := get_platform_setting_int('promoted_job_cost', 20);
  max_hours := get_platform_setting_int('promoted_job_hours', 24);
  eff_hours := least(greatest(coalesce(p_hours, max_hours), 1), max_hours);
  new_balance := _ledger_apply(caller, -cost, 'boost', 'job', p_job_id, 'Promoted job');
  update jobs set promoted_until = greatest(coalesce(promoted_until, now()), now()) +
                                    make_interval(hours => eff_hours)
    where id = p_job_id;
  return new_balance;
end;
$$;
grant execute on function promote_job(uuid, int) to authenticated;
