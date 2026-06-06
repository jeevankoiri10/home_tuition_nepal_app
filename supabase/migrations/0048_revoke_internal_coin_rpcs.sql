-- Home Tuition Nepal — Revoke PUBLIC execute on internal coin RPCs (CRITICAL).
-- Run after 0047_mark_read_thread_guard.sql.
--
-- VULNERABILITY (critical — arbitrary coin minting via the public REST API):
-- In PostgreSQL a newly created function is executable by PUBLIC by default,
-- and Supabase exposes every function in `public` at POST /rest/v1/rpc/<name>
-- to any anon/authenticated JWT. Two coin-mutating SECURITY DEFINER functions
-- were never revoked from PUBLIC:
--
--   1. _ledger_apply(uuid,int,text,text,uuid,text) — the single internal wallet
--      mutator. It sets app.allow_ledger_write='yes' itself (so the
--      block_direct_ledger_writes trigger does NOT stop it) and does an
--      UNCONDITIONAL `coin_balance + p_delta` for an arbitrary p_user. Any user
--      could call:
--        POST /rest/v1/rpc/_ledger_apply
--        { p_user: <self>, p_delta: 1000000, p_reason: 'topup',
--          p_ref_type: 'topup', p_ref_id: null, p_description: 'x' }
--      and mint unlimited coins. (The new_balance<0 guard only blocks
--      over-debits; positive deltas pass.)
--
--   2. finalize_top_up(uuid,text,jsonb,boolean) — credits a top-up's stored
--      coin_amount. It was GRANTed to service_role (0009) but `grant ... to
--      service_role` does NOT remove the default PUBLIC grant. A user could
--      start_top_up() (real pending row), then self-finalize:
--        POST /rest/v1/rpc/finalize_top_up { p_top_up_id: <own>, p_ok: true }
--      crediting the coins without ever paying — bypassing the
--      webhook/admin-approval path entirely.
--
-- Both violate the "coin ledger is server-authoritative" invariant.
--
-- FIX: revoke EXECUTE from public/anon/authenticated. These functions are only
-- ever meant to be called internally — _ledger_apply by the other SECURITY
-- DEFINER coin RPCs (unlock_contact, tutor_apply_to_vacancy, spend_coins_and_bid,
-- grant_signup_coins, finalize_top_up, admin wallet RPCs), and finalize_top_up
-- by the payment webhook / admin panel under the service role. Internal callers
-- run as the owning superuser, who keeps EXECUTE regardless of the PUBLIC
-- revoke; finalize_top_up retains its explicit service_role grant. No
-- legitimate path is affected.
--
-- (This mirrors the revoke pattern already used for the broadcast RPCs in 0031
-- and the cold-start RPCs in 0041.)

revoke execute on function _ledger_apply(uuid, int, text, text, uuid, text)
  from public, anon, authenticated;

revoke execute on function finalize_top_up(uuid, text, jsonb, boolean)
  from public, anon, authenticated;
