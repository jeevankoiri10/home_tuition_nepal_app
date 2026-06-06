-- Home Tuition Nepal — canonical admin wallet RPCs.
--
-- The admin panel needs manual credit / debit / refund. Earlier drafts did a
-- direct INSERT into wallet_ledger, which fails twice over: the table's
-- append-only trigger (block_direct_ledger_writes) rejects any insert that
-- doesn't go through _ledger_apply, and the reason CHECK only allows the
-- closed set {signup,apply,unlock,boost,topup,reward,refund,admin}.
--
-- These RPCs route through _ledger_apply (which sets the write guard, updates
-- profiles.coin_balance, and enforces the non-negative invariant) and use
-- valid reasons. Run after 0019_student_reviews.sql.

-- Manual credit (+delta) or debit (-delta). The free-text reason is stored as
-- the ledger description; the ledger reason is always 'admin'.
create or replace function admin_adjust_coins(
  p_user_id uuid,
  p_delta   int,
  p_reason  text
) returns int
language plpgsql
security definer
set search_path = public
as $$
declare caller uuid := auth.uid();
begin
  if not exists (select 1 from admin_users where id = caller) then
    raise exception 'not_admin';
  end if;
  if p_delta = 0 then raise exception 'delta_must_be_nonzero'; end if;
  return _ledger_apply(p_user_id, p_delta, 'admin', null, null, p_reason);
end;
$$;
grant execute on function admin_adjust_coins(uuid, int, text) to authenticated;

-- Refund: a positive credit recorded under the dedicated 'refund' reason so it
-- is distinguishable from a goodwill 'admin' credit in the ledger UI.
create or replace function refund_coins(
  p_user_id uuid,
  p_amount  int,
  p_note    text
) returns int
language plpgsql
security definer
set search_path = public
as $$
declare caller uuid := auth.uid();
begin
  if not exists (select 1 from admin_users where id = caller) then
    raise exception 'not_admin';
  end if;
  if p_amount <= 0 then raise exception 'amount_must_be_positive'; end if;
  return _ledger_apply(p_user_id, p_amount, 'refund', null, null, p_note);
end;
$$;
grant execute on function refund_coins(uuid, int, text) to authenticated;
