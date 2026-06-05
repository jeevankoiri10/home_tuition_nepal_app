-- Home Tuition Nepal — Make unlock_contact double-charge-safe (correctness).
-- Run after 0049_clamp_boost_duration.sql.
--
-- BUG (concurrency / double-charge): unlock_contact (0004) is meant to charge a
-- (student, tutor) unlock exactly once — it SELECTs for an existing 'unlock'
-- ledger row and skips the debit if found. But that check-then-debit is not
-- atomic: two concurrent calls for the same pair (e.g. a double-tap, or a
-- retried request) both read "not yet unlocked", both fall through to
-- _ledger_apply, and the student is charged twice for one unlock. There is no
-- unique constraint on (user_id, ref_id) for unlock rows to catch it.
--
-- This harms the user (not the platform), so it isn't an exploit, but it is a
-- real money bug under everyday double-tap behaviour.
--
-- FIX: take a transaction-scoped advisory lock keyed on (caller, tutor) before
-- the idempotency check. Concurrent unlocks of the SAME pair now serialize — the
-- second waits, then sees the first's ledger row and returns without charging.
-- Different pairs don't contend (two-key lock). No schema/data change, so this
-- is safe to apply even if some pairs were already double-charged historically
-- (a unique index would fail on such rows; an advisory lock won't).
create or replace function unlock_contact(p_tutor_id uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  caller       uuid := auth.uid();
  already      uuid;
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_tutor_id then raise exception 'cannot_unlock_self'; end if;

  -- Serialize concurrent unlocks of this exact (student, tutor) pair so the
  -- one-time idempotency check below can't be raced into a double charge.
  perform pg_advisory_xact_lock(hashtext(caller::text), hashtext(p_tutor_id::text));

  -- One-time per (student, tutor) — if already unlocked, no debit.
  select id into already
    from wallet_ledger
   where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id
   limit 1;
  if already is not null then
    return (select coin_balance from profiles where id = caller);
  end if;

  cost := get_platform_setting_int('unlock_coin_cost', 5);
  new_balance := _ledger_apply(
    caller, -cost, 'unlock', 'tutor', p_tutor_id,
    'Unlocked contact for tutor'
  );
  return new_balance;
end;
$$;
grant execute on function unlock_contact(uuid) to authenticated;
