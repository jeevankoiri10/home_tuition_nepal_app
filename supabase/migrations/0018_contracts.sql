-- Home Tuition Nepal — contracts (Upwork-style engagements started from chat).
--
-- A contract is proposed by one party in a chat thread, accepted by the
-- other, runs while 'active', and on 'completed' unlocks the review flow.
-- Run after 0017_topup_receipt_upload.sql.

create table if not exists contracts (
  id            uuid primary key default gen_random_uuid(),
  thread_id     uuid references chat_threads(id) on delete set null,
  student_id    uuid not null references profiles(id) on delete cascade,
  tutor_id      uuid not null references profiles(id) on delete cascade,
  proposed_by   uuid not null references profiles(id) on delete cascade,
  subject       text not null,
  rate_npr      numeric,
  rate_period   text not null default 'month' check (rate_period in ('month','week','session','hour')),
  schedule_text text,
  status        text not null default 'proposed'
                  check (status in ('proposed','active','completed','declined','cancelled')),
  created_at    timestamptz not null default now(),
  started_at    timestamptz,
  ended_at      timestamptz
);

create index if not exists contracts_thread_idx  on contracts (thread_id, created_at desc);
create index if not exists contracts_student_idx on contracts (student_id, created_at desc);
create index if not exists contracts_tutor_idx   on contracts (tutor_id, created_at desc);

alter table contracts enable row level security;

-- Either party on the contract can read it.
drop policy if exists contracts_select_party on contracts;
create policy contracts_select_party
  on contracts for select
  using (auth.uid() = student_id or auth.uid() = tutor_id);

-- Either party can create a proposal, but only as themselves (proposed_by).
drop policy if exists contracts_insert_party on contracts;
create policy contracts_insert_party
  on contracts for insert
  with check (
    auth.uid() = proposed_by
    and (auth.uid() = student_id or auth.uid() = tutor_id)
  );

-- Status transitions go through the RPCs below (security definer), so we keep
-- direct UPDATE locked down to the two parties as a backstop.
drop policy if exists contracts_update_party on contracts;
create policy contracts_update_party
  on contracts for update
  using (auth.uid() = student_id or auth.uid() = tutor_id)
  with check (auth.uid() = student_id or auth.uid() = tutor_id);

-- ─── Lifecycle RPCs ──────────────────────────────────────────────────
-- accept: only the counterparty (not the proposer) may accept a proposal.
create or replace function accept_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.student_id and auth.uid() <> c.tutor_id then
    raise exception 'not_a_party';
  end if;
  if auth.uid() = c.proposed_by then raise exception 'proposer_cannot_accept'; end if;
  if c.status <> 'proposed' then raise exception 'not_proposed'; end if;
  update contracts set status = 'active', started_at = now() where id = p_contract_id;
end;
$$;
grant execute on function accept_contract(uuid) to authenticated;

-- decline: the counterparty rejects a proposal.
create or replace function decline_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.student_id and auth.uid() <> c.tutor_id then
    raise exception 'not_a_party';
  end if;
  if c.status <> 'proposed' then raise exception 'not_proposed'; end if;
  update contracts set status = 'declined', ended_at = now() where id = p_contract_id;
end;
$$;
grant execute on function decline_contract(uuid) to authenticated;

-- end: either party ends an active contract → 'completed' (unlocks reviews).
create or replace function end_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.student_id and auth.uid() <> c.tutor_id then
    raise exception 'not_a_party';
  end if;
  if c.status <> 'active' then raise exception 'not_active'; end if;
  update contracts set status = 'completed', ended_at = now() where id = p_contract_id;
end;
$$;
grant execute on function end_contract(uuid) to authenticated;

-- cancel: the proposer withdraws a still-'proposed' contract.
create or replace function cancel_contract(p_contract_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare c contracts%rowtype;
begin
  select * into c from contracts where id = p_contract_id;
  if c.id is null then raise exception 'not_found'; end if;
  if auth.uid() <> c.proposed_by then raise exception 'not_proposer'; end if;
  if c.status <> 'proposed' then raise exception 'not_proposed'; end if;
  update contracts set status = 'cancelled', ended_at = now() where id = p_contract_id;
end;
$$;
grant execute on function cancel_contract(uuid) to authenticated;
