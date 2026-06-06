-- Home Tuition Nepal — Add the _is_blocked backstop to apply_to_vacancy (security).
-- Run after 0054_revoke_audit_helper.sql.
--
-- GAP (same class as 0052): apply_to_vacancy(p_vacancy_id) (0004 → repriced 0034)
-- is a live, coin-debiting "connect" action — the wallet repository calls it at
-- supabase_wallet_repository.dart:119 (_callIntRpc('apply_to_vacancy', …)). 0010
-- gave the block guard to tutor_apply_to_vacancy / unlock_contact /
-- send_chat_message, and 0052 added it to boost/promote, but apply_to_vacancy was
-- never covered. A banned or currently-suspended user could therefore still spend
-- coins to apply to a vacancy via a direct RPC call (or this client path),
-- bypassing the suspension server-side.
--
-- _is_blocked(uuid) (0010) = banned_at set OR suspended_until in the future.
--
-- FIX: re-create the 0034 body verbatim with ONLY the _is_blocked check added
-- after the auth check (matching the order used by the other connect RPCs). The
-- percentage cost (vacancy_apply_cost), the debit and the signature are preserved,
-- so the client contract is unchanged.
--
-- NOTE: the sibling debit RPCs tutor_apply_to_vacancy and spend_coins_and_bid had
-- their guard restored/added in 0042 directly (the latest definition of each lives
-- there); this migration covers the remaining apply_to_vacancy path.

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
  if _is_blocked(caller) then raise exception 'account_blocked'; end if;  -- backstop (cf. 0010/0052)
  cost := vacancy_apply_cost(p_vacancy_id);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id,
    'Applied to vacancy'
  );
  return new_balance;
end;
$$;
grant execute on function apply_to_vacancy(uuid) to authenticated;
