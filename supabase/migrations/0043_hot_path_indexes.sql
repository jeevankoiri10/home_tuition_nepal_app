-- Home Tuition Nepal — Hot-path covering indexes (performance / scaling).
-- Run after 0042_match_outcome_log.sql.
--
-- Several high-traffic queries filter on a low-cardinality column AND sort by
-- created_at, but only a single-column index on the filter exists. Postgres can
-- use the single-column index for the filter, then has to sort the matches in
-- memory every time. Composite (filter, created_at desc) indexes let the planner
-- satisfy the WHERE and the ORDER BY from one index scan — and a LIMIT can stop
-- early instead of sorting the whole match set.
--
-- All additive and idempotent (create index if not exists). The redundant
-- single-column indexes are dropped: a composite with the same leading column
-- serves single-column equality lookups too, so keeping both only wastes write
-- throughput and disk.

-- profiles: admin users/tutors directory and dashboard signup series do
--   where role = $1 order by created_at desc  (often with a range/limit).
create index if not exists profiles_role_created_idx
  on profiles (role, created_at desc);
drop index if exists profiles_role_idx;

-- vacancies: student "open vacancies" feed and admin grid do
--   where status = 'open' order by created_at desc limit 100.
create index if not exists vacancies_status_created_idx
  on vacancies (status, created_at desc);
drop index if exists vacancies_status_idx;

-- wallet_ledger: dashboard unlock count + per-day unlock series do
--   where reason = 'unlock' [and created_at >= $since].
-- Existing index is on (user_id, created_at) — no help for a reason filter.
create index if not exists wallet_ledger_reason_created_idx
  on wallet_ledger (reason, created_at desc);

-- coin_top_ups: dashboard revenue series does
--   where status = 'succeeded' and created_at >= $since.
-- Existing indexes are on (user_id, …) and (provider, provider_ref).
create index if not exists coin_top_ups_status_created_idx
  on coin_top_ups (status, created_at desc);
