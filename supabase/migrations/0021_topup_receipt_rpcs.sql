-- Home Tuition Nepal — manual eSewa receipt review RPCs.
--
-- The eSewa flow is: user pays via QR → uploads a receipt → an admin verifies
-- it → coins are credited. coin_top_ups only allows admins to UPDATE the row
-- (0009), so a user attaching their own receipt_url via a direct update is
-- blocked by RLS. These owner/admin-gated RPCs close that gap cleanly and
-- reuse finalize_top_up for the actual credit.
--
-- Run after 0020_wallet_admin_rpcs.sql.

-- Add the receipt_url column if 0017 hasn't run (it adds the same column).
alter table coin_top_ups add column if not exists receipt_url text;

-- Owner attaches their receipt to their own pending top-up.
create or replace function submit_topup_receipt(
  p_top_up_id  uuid,
  p_receipt_url text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare t record;
begin
  select * into t from coin_top_ups where id = p_top_up_id;
  if t is null then raise exception 'top_up_not_found'; end if;
  if t.user_id <> auth.uid() then raise exception 'forbidden'; end if;
  if t.status <> 'pending' then raise exception 'not_pending'; end if;
  update coin_top_ups set receipt_url = p_receipt_url where id = p_top_up_id;
end;
$$;
grant execute on function submit_topup_receipt(uuid, text) to authenticated;

-- Admin approves a receipted top-up → credits coins via finalize_top_up.
create or replace function approve_topup_receipt(p_top_up_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare t record;
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  select * into t from coin_top_ups where id = p_top_up_id;
  if t is null then raise exception 'top_up_not_found'; end if;
  if t.receipt_url is null then raise exception 'no_receipt'; end if;
  if t.status <> 'pending' then raise exception 'not_pending'; end if;
  perform finalize_top_up(
    p_top_up_id,
    null,
    jsonb_build_object('manual_approval', true, 'approved_by', auth.uid()),
    true
  );
end;
$$;
grant execute on function approve_topup_receipt(uuid) to authenticated;

-- Admin rejects a receipted top-up → marks it failed, no credit.
create or replace function reject_topup_receipt(p_top_up_id uuid, p_note text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (select 1 from admin_users where id = auth.uid()) then
    raise exception 'not_admin';
  end if;
  perform finalize_top_up(
    p_top_up_id,
    null,
    jsonb_build_object('manual_rejection', true, 'rejected_by', auth.uid(), 'note', p_note),
    false
  );
end;
$$;
grant execute on function reject_topup_receipt(uuid, text) to authenticated;
