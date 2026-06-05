-- Home Tuition Nepal — Add the _is_blocked backstop to boost/promote (security).
-- Run after 0051_lock_recompute_all_rankings.sql.
--
-- GAP: 0010 (admin hardening) added `if _is_blocked(caller) then raise
-- 'account_blocked'` to the paid "connect" actions — tutor_apply_to_vacancy,
-- unlock_contact, send_chat_message — so a banned/suspended user can't perform
-- them server-side even if they bypass the client's block screen by calling the
-- RPC directly. boost_tutor_featured and promote_job (0008) were never given the
-- same backstop, so a banned or currently-suspended user could still spend coins
-- to feature their listing / promote their jobs via a direct RPC call —
-- effectively buying visibility while under suspension.
--
-- _is_blocked(uuid) (0010) = banned_at set OR suspended_until in the future.
--
-- FIX: redefine both with the same guard. These bodies are the 0049 versions
-- (which clamp the client-supplied duration) with ONLY the _is_blocked check
-- added — the duration clamp, costs, ownership checks and signatures are
-- preserved verbatim, so nothing else changes.

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
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;
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
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;
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
