-- Home Tuition Nepal — Lock down recompute_all_tutor_rankings (DoS / scaling).
-- Run after 0050_unlock_contact_no_double_charge.sql.
--
-- VULNERABILITY (denial of service / resource exhaustion):
-- recompute_all_tutor_rankings() (0008) loops over EVERY row in `tutors` and
-- calls recompute_tutor_rating() for each — an O(N-tutors) full-table batch
-- operation whose cost grows with the platform. It was `grant`ed to
-- `authenticated` and is exposed at POST /rest/v1/rpc/recompute_all_tutor_rankings,
-- so any logged-in user could call it in a tight loop and saturate the database
-- (each call re-scans every tutor's reviews). No app or admin code calls it —
-- it is a maintenance/batch routine, not a client operation. Individual flows
-- recompute a single tutor via recompute_tutor_rating(self).
--
-- Unlike the admin analytics RPCs (match_funnel_metrics, supply_gap_report) it
-- has no internal admin_users gate, and unlike the cold-start batch jobs in 0041
-- it was never restricted to service_role.
--
-- FIX: revoke from public/anon/authenticated and grant to service_role only, so
-- only a scheduled job / admin tooling running under the service role can
-- trigger the full recompute (matching the 0041 batch-RPC pattern). No client
-- path is affected.

revoke all on function recompute_all_tutor_rankings() from public, anon, authenticated;
grant execute on function recompute_all_tutor_rankings() to service_role;
