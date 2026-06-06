-- ─────────────────────────────────────────────────────────────────────────────
-- 0027 — Usage tracking (active time per user, split by role)
--
-- Measures active foreground time so the admin dashboard can show how long
-- users spend in the app as a tutor vs as a student/parent. The app emits a
-- heartbeat (~every 30s while foregrounded); each foreground stretch is one
-- `usage_sessions` row whose duration is (last_seen_at - started_at).
--
-- Privacy: stores only timestamps + the acting role. No routes, content, or
-- location. RLS lets a user write only their own sessions; admins/service-role
-- read for aggregation.
-- ─────────────────────────────────────────────────────────────────────────────

create table if not exists usage_sessions (
  id            uuid primary key default uuid_generate_v4(),
  user_id       uuid not null references profiles(id) on delete cascade,
  role          text not null check (role in ('tutor','student')),
  started_at    timestamptz not null default now(),
  last_seen_at  timestamptz not null default now(),
  -- Active duration in seconds, kept in sync with the timestamps.
  duration_seconds integer generated always as
    (greatest(0, floor(extract(epoch from (last_seen_at - started_at)))::int)) stored,
  created_at    timestamptz not null default now()
);

create index if not exists usage_sessions_user_idx on usage_sessions (user_id, started_at desc);
create index if not exists usage_sessions_role_day_idx on usage_sessions (role, started_at);

alter table usage_sessions enable row level security;

-- A user sees and writes only their own sessions. (Service-role bypasses RLS
-- for the admin dashboard's aggregate reads.)
drop policy if exists usage_sessions_own_select on usage_sessions;
create policy usage_sessions_own_select on usage_sessions
  for select using (user_id = auth.uid());

drop policy if exists usage_sessions_own_insert on usage_sessions;
create policy usage_sessions_own_insert on usage_sessions
  for insert with check (user_id = auth.uid());

drop policy if exists usage_sessions_own_update on usage_sessions;
create policy usage_sessions_own_update on usage_sessions
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ─── touch_usage_session ─────────────────────────────────────────────────────
-- Heartbeat entry point. Pass NULL to open a session (returns its id); pass the
-- id on subsequent beats to extend `last_seen_at`. If the id is unknown (e.g.
-- pruned) a fresh session is opened. Returns the live session id.
create or replace function touch_usage_session(p_session_id uuid, p_role text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  v_id   uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if p_role not in ('tutor','student') then raise exception 'bad_role'; end if;

  if p_session_id is not null then
    update usage_sessions
       set last_seen_at = now()
     where id = p_session_id and user_id = caller
    returning id into v_id;
    if v_id is not null then
      return v_id;
    end if;
  end if;

  insert into usage_sessions (user_id, role, started_at, last_seen_at)
  values (caller, p_role, now(), now())
  returning id into v_id;
  return v_id;
end;
$$;

grant execute on function touch_usage_session(uuid, text) to authenticated;
