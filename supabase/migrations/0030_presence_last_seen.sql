-- ─────────────────────────────────────────────────────────────────────────────
-- 0030 — Presence: last-seen timestamp
--
-- Live "online now" dots are handled client-side by Supabase Realtime Presence
-- (ephemeral, no DB writes). This adds the persistent half: a `last_seen`
-- timestamp the app refreshes on a heartbeat, so other users can see
-- "last seen 5 min ago" even after someone disconnects. Free-tier friendly —
-- just periodic single-row updates.
--
-- Run after 0029_active_role_switch.sql.
-- ─────────────────────────────────────────────────────────────────────────────

alter table public.profiles add column if not exists last_seen timestamptz;

-- touch_last_seen: stamp the caller's last_seen to now(). Called on the app's
-- presence heartbeat (~30s) while foregrounded + signed in.
create or replace function touch_last_seen()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then return; end if;
  update profiles set last_seen = now() where id = caller;
end;
$$;

grant execute on function touch_last_seen() to authenticated;
