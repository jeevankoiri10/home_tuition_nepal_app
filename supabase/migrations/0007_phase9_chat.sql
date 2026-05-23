-- Home Tuition Nepal — Phase 9 schema (in-app chat).
-- Run after 0006_phase7_vacancy_applications.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- chat_threads — 1 row per (student, tutor) pair that has met the gate
-- (either the student unlocked the tutor's contact, OR an admin assigned
-- the tutor to one of the student's vacancies).
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists chat_threads (
  id              uuid primary key default uuid_generate_v4(),
  student_id      uuid not null references profiles(id) on delete cascade,
  tutor_id        uuid not null references profiles(id) on delete cascade,
  opened_via      text not null check (opened_via in ('contact_unlock','admin_assignment')),
  vacancy_id      uuid references vacancies(id) on delete set null,
  job_id          uuid references jobs(id)      on delete set null,
  last_message_at timestamptz,
  created_at      timestamptz not null default now(),
  unique (student_id, tutor_id)
);

create index if not exists chat_threads_student_idx on chat_threads(student_id, last_message_at desc nulls last);
create index if not exists chat_threads_tutor_idx   on chat_threads(tutor_id,   last_message_at desc nulls last);

alter table chat_threads enable row level security;

drop policy if exists chat_threads_select on chat_threads;
create policy chat_threads_select
  on chat_threads for select
  using (auth.uid() in (student_id, tutor_id));

-- ────────────────────────────────────────────────────────────────────────────
-- chat_messages — append-only by either party in the thread.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists chat_messages (
  id         uuid primary key default uuid_generate_v4(),
  thread_id  uuid not null references chat_threads(id) on delete cascade,
  sender_id  uuid not null references profiles(id),
  body       text not null check (length(body) > 0 and length(body) <= 2000),
  sent_at    timestamptz not null default now(),
  read_at    timestamptz
);

create index if not exists chat_messages_thread_idx on chat_messages(thread_id, sent_at);

alter table chat_messages enable row level security;

drop policy if exists chat_messages_select on chat_messages;
create policy chat_messages_select
  on chat_messages for select
  using (
    exists (
      select 1 from chat_threads t
       where t.id = chat_messages.thread_id
         and auth.uid() in (t.student_id, t.tutor_id)
    )
  );

-- ────────────────────────────────────────────────────────────────────────────
-- Server-side phone-ban regex — backstop the client validator.
-- Matches the heuristics in lib/core/utils/phone_ban_regex.dart:
--   • 7+ digits (allowing spaces/dashes/dots in between)
--   • email addresses
--   • wa.me / t.me / viber.me links
-- ────────────────────────────────────────────────────────────────────────────
create or replace function _has_phone_or_contact(p_text text)
returns boolean
language plpgsql
immutable
as $$
declare
  digit_count int;
begin
  if p_text ~* '[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}' then return true; end if;
  if p_text ~* '(wa\.me/|t\.me/|viber\.me/|whatsapp\.com|telegram\.me|m\.me/)' then return true; end if;
  -- Count digits to skip short class numbers (e.g. "Class 11").
  digit_count := length(regexp_replace(p_text, '\D', '', 'g'));
  if digit_count >= 7 and p_text ~ '(\+?\d[\d\s\-.]{6,}\d)' then return true; end if;
  return false;
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- open_or_get_thread — only opens a thread when the gate has been met.
-- Gate (either is sufficient):
--   (a) caller is a student who already unlocked p_tutor_id (a wallet_ledger
--       row with reason='unlock' and ref_id=p_tutor_id);
--   (b) caller is a tutor or student linked via an admin_assignment
--       (vacancies.filled_by_tutor + linked_student) for the same pair.
-- Returns the thread id (creates it if missing).
-- ────────────────────────────────────────────────────────────────────────────
create or replace function open_or_get_thread(p_counterparty uuid)
returns uuid
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  caller_role  text;
  cpty_role    text;
  student_id   uuid;
  tutor_id     uuid;
  unlocked     boolean;
  assigned     boolean;
  thread_id    uuid;
  opened_via   text;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_counterparty then raise exception 'cannot_chat_with_self'; end if;

  select role into caller_role  from profiles where id = caller;
  select role into cpty_role    from profiles where id = p_counterparty;

  if caller_role is null or cpty_role is null then
    raise exception 'profile_not_found';
  end if;
  if caller_role = cpty_role then
    raise exception 'invalid_pair';
  end if;

  if caller_role = 'student' then
    student_id := caller;
    tutor_id   := p_counterparty;
  else
    student_id := p_counterparty;
    tutor_id   := caller;
  end if;

  unlocked := exists (
    select 1 from wallet_ledger
     where user_id = student_id and reason = 'unlock' and ref_id = tutor_id
  );
  assigned := exists (
    select 1 from vacancies
     where linked_student = student_id and filled_by_tutor = tutor_id
  );

  if not unlocked and not assigned then
    raise exception 'gate_not_met';
  end if;

  opened_via := case when assigned then 'admin_assignment' else 'contact_unlock' end;

  insert into chat_threads(student_id, tutor_id, opened_via)
  values (student_id, tutor_id, opened_via)
  on conflict (student_id, tutor_id) do update set student_id = excluded.student_id
  returning id into thread_id;

  return thread_id;
end;
$$;
grant execute on function open_or_get_thread(uuid) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- send_chat_message — phone-ban backstop + last_message_at touch.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function send_chat_message(p_thread_id uuid, p_body text)
returns uuid
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
  msg_id uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (
    select 1 from chat_threads
     where id = p_thread_id and auth.uid() in (student_id, tutor_id)
  ) then raise exception 'thread_not_found_or_forbidden'; end if;

  if length(coalesce(trim(p_body), '')) = 0 then
    raise exception 'empty_message';
  end if;
  if _has_phone_or_contact(p_body) then
    raise exception 'phone_in_message';
  end if;

  insert into chat_messages(thread_id, sender_id, body)
  values (p_thread_id, caller, p_body)
  returning id into msg_id;

  update chat_threads set last_message_at = now() where id = p_thread_id;
  return msg_id;
end;
$$;
grant execute on function send_chat_message(uuid, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- mark_messages_read — the counterparty's incoming messages get a timestamp.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function mark_messages_read(p_thread_id uuid)
returns void
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  update chat_messages
     set read_at = now()
   where thread_id = p_thread_id
     and sender_id <> caller
     and read_at is null;
end;
$$;
grant execute on function mark_messages_read(uuid) to authenticated;
