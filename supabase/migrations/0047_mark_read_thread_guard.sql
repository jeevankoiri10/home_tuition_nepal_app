-- Home Tuition Nepal — Fix missing thread-membership check in mark_messages_read.
-- Run after 0046_unlock_gate_index.sql.
--
-- VULNERABILITY (IDOR / broken access control):
-- mark_messages_read (0007) is SECURITY DEFINER (bypasses RLS) but only checks
-- that the caller is authenticated — it never verifies the caller is a member
-- of p_thread_id. open_or_get_thread and send_chat_message both enforce
-- `auth.uid() in (student_id, tutor_id)`; this RPC was missing that guard.
--
-- Impact: any authenticated user could call mark_messages_read(<any thread id>)
-- and flip read_at on messages in threads they are not part of. Because read_at
-- drives unread badges / "new message" indicators, an attacker could suppress
-- unread state for arbitrary users across the platform (griefing / abuse), and
-- tamper with read-receipt integrity for conversations they have no part in.
--
-- FIX: add the same thread-membership check the other chat RPCs use. Behaviour
-- for legitimate participants is unchanged.
create or replace function mark_messages_read(p_thread_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (
    select 1 from chat_threads
     where id = p_thread_id and caller in (student_id, tutor_id)
  ) then raise exception 'thread_not_found_or_forbidden'; end if;

  update chat_messages
     set read_at = now()
   where thread_id = p_thread_id
     and sender_id <> caller
     and read_at is null;
end;
$$;
grant execute on function mark_messages_read(uuid) to authenticated;
