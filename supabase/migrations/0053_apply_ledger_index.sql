-- Home Tuition Nepal — Covering index for job-bid ledger lookups (performance).
-- Run after 0052_block_guard_boost_promote.sql.
--
-- A job "bid" is recorded as a wallet_ledger row (reason='apply', ref_type='job',
-- ref_id=<job id>) rather than a separate table. Two hot/recurring paths probe
-- these rows and neither is served by an existing index:
--
--   1. tutor_job_feed (0040) — for EACH open job in the calling tutor's ranked
--      feed, an EXISTS checks "did I already bid?":
--        wl.user_id = $tutor and wl.ref_id = $job and wl.reason = 'apply'
--      Runs on every feed load, once per open job. Without a covering index it
--      falls back to scanning the tutor's whole ledger (via the user_id index)
--      per job → O(open_jobs × ledger_size).
--   2. auto_relax_thin_posts (0041) — counts applicants per job:
--        count(*) where wl.ref_id = $job and wl.reason = 'apply'
--
-- A single partial index on (ref_id, user_id) WHERE reason='apply' serves both:
-- path 1 is a point lookup (ref_id + user_id both equality), path 2 a
-- leading-column (ref_id) range scan. Partial → only 'apply' rows are indexed,
-- so it stays small. Additive/idempotent. (Sibling of the unlock-gate index in
-- 0046, which covers the reason='unlock' lookups.)
create index if not exists wallet_ledger_apply_ref_idx
  on wallet_ledger (ref_id, user_id)
  where reason = 'apply';
