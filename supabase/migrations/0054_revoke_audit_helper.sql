-- Home Tuition Nepal — Revoke PUBLIC execute on the _audit helper (security).
-- Run after 0053_apply_ledger_index.sql.
--
-- VULNERABILITY (audit-log forgery / integrity): _audit (0010) is the internal
-- SECURITY DEFINER writer for the append-only audit_events table. It sets
-- app.allow_audit_write='yes' (so the _block_direct_audit_writes trigger lets it
-- through) and inserts a row with caller-supplied type/target/payload and
-- actor_id = auth.uid(). Like _ledger_apply / finalize_top_up (revoked in 0048),
-- it was never revoked from PUBLIC, and PostgreSQL exposes it at
-- POST /rest/v1/rpc/_audit to any anon/authenticated JWT.
--
-- Impact: any user could forge audit_events rows — flooding the forensic log and
-- injecting misleading entries (fake 'PlatformSettingChanged', 'TutorVerified',
-- 'UserBanned', …). actor_id is pinned to auth.uid() so they can't frame another
-- user, but the ability to inject arbitrary admin-looking events at will defeats
-- the evidentiary value of the whole audit trail.
--
-- FIX: revoke EXECUTE from public/anon/authenticated. _audit is only ever called
-- internally by the admin RPCs (admin_suspend_user, admin_ban_user,
-- admin_unban_user, admin_review_verification, admin_set_setting,
-- admin_resolve_moderation), which run as the owning superuser and keep EXECUTE
-- regardless of the PUBLIC revoke. No app/admin client calls _audit directly.

revoke execute on function _audit(text, text, uuid, jsonb)
  from public, anon, authenticated;
