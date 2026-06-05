-- Home Tuition Nepal — Phase 11 schema (coin top-ups).
-- Run after 0008_phase10_reviews_boosts.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- coin_packs — admin-curated catalog of (amount, price) pairs offered to users.
-- Bonus = extra coins on top of `coin_amount` for marketing tiers.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists coin_packs (
  id            uuid primary key default uuid_generate_v4(),
  code          text unique not null,           -- 'PACK-100', 'PACK-500', ...
  label         text not null,                  -- 'Starter pack'
  coin_amount   integer not null check (coin_amount > 0),
  bonus_coins   integer not null default 0 check (bonus_coins >= 0),
  price_npr     numeric not null check (price_npr > 0),
  active        boolean not null default true,
  sort_order    smallint not null default 0,
  created_at    timestamptz not null default now()
);

alter table coin_packs enable row level security;
drop policy if exists coin_packs_select_active on coin_packs;
create policy coin_packs_select_active on coin_packs for select using (active);

-- Seed a starter catalog. Admins can re-tune via the admin panel.
insert into coin_packs (code, label, coin_amount, bonus_coins, price_npr, sort_order)
values
  ('PACK-100',  'Starter',     100,   0,   99, 1),
  ('PACK-500',  'Popular',     500,  50,  449, 2),
  ('PACK-2000', 'Pro',        2000, 300, 1699, 3),
  ('PACK-5000', 'Power user', 5000, 900, 3999, 4)
on conflict (code) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- coin_top_ups — one row per attempted top-up. Lifecycle:
--   pending → succeeded   (webhook verified, coins credited)
--           → failed      (webhook rejected, no credit)
--           → cancelled   (user backed out)
-- The wallet credit is the same `_ledger_apply` path used everywhere else.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists coin_top_ups (
  id                 uuid primary key default uuid_generate_v4(),
  user_id            uuid not null references profiles(id) on delete cascade,
  pack_id            uuid references coin_packs(id),
  provider           text not null check (provider in ('esewa','khalti','ime_pay')),
  provider_ref       text,                                 -- provider's txn id
  coin_amount        integer not null,                     -- includes bonus
  price_npr          numeric not null,
  status             text not null check (status in ('pending','succeeded','failed','cancelled')) default 'pending',
  ledger_entry_id    uuid references wallet_ledger(id),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  webhook_payload    jsonb
);

create index if not exists coin_top_ups_user_idx on coin_top_ups(user_id, created_at desc);
create index if not exists coin_top_ups_provider_ref_idx on coin_top_ups(provider, provider_ref);

drop trigger if exists trg_coin_top_ups_updated_at on coin_top_ups;
create trigger trg_coin_top_ups_updated_at
  before update on coin_top_ups
  for each row execute function set_updated_at();

alter table coin_top_ups enable row level security;

drop policy if exists coin_top_ups_select_self on coin_top_ups;
create policy coin_top_ups_select_self on coin_top_ups for select
  using (auth.uid() = user_id or exists (select 1 from admin_users where id = auth.uid()));

drop policy if exists coin_top_ups_insert_self on coin_top_ups;
create policy coin_top_ups_insert_self on coin_top_ups for insert
  with check (auth.uid() = user_id and status = 'pending');

-- Only admins / webhook RPC may flip status — clients can't promote
-- pending → succeeded on their own. Updates go through `finalize_top_up`.
drop policy if exists coin_top_ups_admin_update on coin_top_ups;
create policy coin_top_ups_admin_update on coin_top_ups for update
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- ────────────────────────────────────────────────────────────────────────────
-- start_top_up — client-callable. Creates a pending row and returns the id
-- the client can pass to the provider SDK as `merchantTransactionId`.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function start_top_up(
  p_pack_id  uuid,
  p_provider text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  pack   record;
  id     uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if p_provider not in ('esewa','khalti','ime_pay') then raise exception 'invalid_provider'; end if;

  select * into pack from coin_packs where id = p_pack_id and active;
  if pack is null then raise exception 'pack_not_found'; end if;

  insert into coin_top_ups(user_id, pack_id, provider, coin_amount, price_npr)
  values (caller, p_pack_id, p_provider,
          pack.coin_amount + pack.bonus_coins, pack.price_npr)
  returning coin_top_ups.id into id;
  return id;
end;
$$;
grant execute on function start_top_up(uuid, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- finalize_top_up — called by the Edge Function ONCE the provider's webhook
-- signature has been verified. Idempotent: succeeded rows are not double-
-- credited. The credit goes through _ledger_apply so the wallet UI updates.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function finalize_top_up(
  p_top_up_id    uuid,
  p_provider_ref text,
  p_payload      jsonb,
  p_ok           boolean
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t   record;
  new_ledger uuid;
  balance int;
begin
  select * into t from coin_top_ups where id = p_top_up_id for update;
  if t is null then raise exception 'top_up_not_found'; end if;

  -- Idempotent
  if t.status = 'succeeded' then return; end if;
  if t.status in ('failed','cancelled') and not p_ok then return; end if;

  update coin_top_ups
     set provider_ref = coalesce(p_provider_ref, t.provider_ref),
         webhook_payload = p_payload,
         status = case when p_ok then 'succeeded' else 'failed' end
   where id = p_top_up_id;

  if p_ok then
    balance := _ledger_apply(
      t.user_id, t.coin_amount, 'topup', 'topup', p_top_up_id,
      'Coin pack via ' || t.provider
    );
    -- Capture the just-inserted ledger row's id (latest by ts for user).
    select id into new_ledger from wallet_ledger
      where user_id = t.user_id and reason = 'topup'
      order by created_at desc limit 1;
    update coin_top_ups set ledger_entry_id = new_ledger where id = p_top_up_id;

    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    values (t.user_id, 'coin_credited', 'Coins credited',
            '+' || t.coin_amount || ' coins from ' || t.provider, 'topup', p_top_up_id);
  else
    insert into notifications(user_id, kind, title, body, ref_type, ref_id)
    values (t.user_id, 'system', 'Top-up failed',
            'Your ' || t.provider || ' payment did not go through.', 'topup', p_top_up_id);
  end if;
end;
$$;
-- finalize_top_up is invoked by the webhook Edge Function (running with the
-- service_role key) — clients don't have execute. Admins call it directly
-- from the admin panel to manually mark a stuck payment.
grant execute on function finalize_top_up(uuid, text, jsonb, boolean) to service_role;

-- ────────────────────────────────────────────────────────────────────────────
-- cancel_top_up — user backs out of the provider flow.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function cancel_top_up(p_top_up_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  t record;
begin
  select * into t from coin_top_ups where id = p_top_up_id;
  if t is null or t.user_id <> auth.uid() then raise exception 'forbidden'; end if;
  if t.status <> 'pending' then return; end if;
  update coin_top_ups set status = 'cancelled' where id = p_top_up_id;
end;
$$;
grant execute on function cancel_top_up(uuid) to authenticated;
