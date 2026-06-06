-- ─────────────────────────────────────────────────────────────────────────────
-- 0025 — Contact reveal
--
-- The unlock flow (0004 unlock_contact) debits coins and records the ledger row
-- but never returns the tutor's phone. This adds a server-gated reveal so the
-- Call / WhatsApp actions can launch tel: / wa.me links after an unlock — while
-- keeping profiles.phone leak-proof (only reachable via this SECURITY DEFINER
-- RPC, and only for a (student, tutor) pair that has actually been unlocked).
-- ─────────────────────────────────────────────────────────────────────────────

create or replace function get_unlocked_contact(p_tutor_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  caller  uuid := auth.uid();
  gate    uuid;
  result  text;
begin
  if caller is null then raise exception 'not_authenticated'; end if;

  -- Gate: the caller must have a prior unlock for this tutor. Mirrors the
  -- one-time check in unlock_contact / hasUnlocked.
  select id into gate
    from wallet_ledger
   where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id
   limit 1;
  if gate is null then raise exception 'gate_not_met'; end if;

  select phone into result from profiles where id = p_tutor_id;
  return result;  -- null when the tutor has no phone on file
end;
$$;

grant execute on function get_unlocked_contact(uuid) to authenticated;
