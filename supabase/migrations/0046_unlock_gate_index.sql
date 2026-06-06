-- Home Tuition Nepal — Unlock-gate covering index (performance / scaling).
-- Run after 0045_vacancy_application_insert_lockdown.sql.
--
-- The contact-unlock gate query runs on every hot path that touches a tutor's
-- contact:
--   * unlock_contact (0004) — idempotency guard before debiting coins,
--   * get_unlocked_contact (0025) — gate before revealing the phone,
--   * the client's per-card "hasUnlocked" checks (map + tutor list).
-- All share the shape:
--   select 1 from wallet_ledger
--    where user_id = $caller and reason = 'unlock' and ref_id = $tutor_id;
--
-- Existing indexes are (user_id, created_at desc) and (reason, created_at desc)
-- — neither covers ref_id, so each call seeks by user_id (or reason) then
-- scans/filters every one of that user's ledger rows. For an active user with a
-- long coin history this is a growing scan on a path hit many times per screen.
--
-- A partial index keyed exactly on the gate predicate turns it into a direct
-- index seek and stays tiny (only 'unlock' rows are indexed). Additive and
-- idempotent.
create index if not exists wallet_ledger_unlock_gate_idx
  on wallet_ledger (user_id, ref_id)
  where reason = 'unlock';
