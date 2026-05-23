-- Home Tuition Nepal — Phase 5 schema (coin system & wallet).
-- Run after 0003_phase4_map.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- wallet_ledger — append-only. Authoritative source of every credit / debit.
-- profiles.coin_balance is a mirror updated by trigger; never trust the client.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists wallet_ledger (
  id             uuid primary key default uuid_generate_v4(),
  user_id        uuid not null references profiles(id) on delete cascade,
  delta          integer not null,
  reason         text not null check (reason in (
    'signup', 'apply', 'unlock', 'boost', 'topup',
    'reward', 'refund', 'admin'
  )),
  ref_type       text,                          -- 'job' | 'vacancy' | 'tutor' | null
  ref_id         uuid,
  balance_after  integer not null,
  description    text,                          -- short human-readable line for the wallet UI
  created_at     timestamptz not null default now()
);

create index if not exists wallet_ledger_user_idx on wallet_ledger(user_id, created_at desc);

alter table wallet_ledger enable row level security;

drop policy if exists wallet_ledger_select_self on wallet_ledger;
create policy wallet_ledger_select_self
  on wallet_ledger for select
  using (auth.uid() = user_id);

-- No insert/update/delete from the client — only via SECURITY DEFINER RPCs below.

-- Block any direct write attempts even if a policy is added by mistake.
create or replace function block_direct_ledger_writes() returns trigger
language plpgsql as $$
begin
  if current_setting('app.allow_ledger_write', true) is distinct from 'yes' then
    raise exception 'wallet_ledger is append-only via security-definer RPCs';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_wallet_ledger_block on wallet_ledger;
create trigger trg_wallet_ledger_block
  before insert or update or delete on wallet_ledger
  for each row execute function block_direct_ledger_writes();

-- ────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ────────────────────────────────────────────────────────────────────────────
create or replace function get_platform_setting_int(p_key text, p_default int default 0)
returns int
language sql
stable
as $$
  select coalesce(
    (select value::int from platform_settings where key = p_key),
    p_default
  );
$$;
grant execute on function get_platform_setting_int(text, int) to authenticated;

-- The single internal mutator. All RPCs go through this.
create or replace function _ledger_apply(
  p_user uuid,
  p_delta int,
  p_reason text,
  p_ref_type text,
  p_ref_id uuid,
  p_description text
) returns int
language plpgsql
security definer
as $$
declare
  new_balance int;
begin
  perform set_config('app.allow_ledger_write', 'yes', true);

  update profiles
     set coin_balance = coin_balance + p_delta
   where id = p_user
   returning coin_balance into new_balance;

  if new_balance is null then
    raise exception 'user not found';
  end if;

  if new_balance < 0 then
    raise exception 'insufficient_coins';
  end if;

  insert into wallet_ledger(user_id, delta, reason, ref_type, ref_id, balance_after, description)
  values (p_user, p_delta, p_reason, p_ref_type, p_ref_id, new_balance, p_description);

  return new_balance;
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- Signup grant — credit the configured `signup_coin_grant` on a brand-new
-- profile. Trigger fires AFTER INSERT on profiles.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function grant_signup_coins() returns trigger
language plpgsql
security definer
as $$
declare
  amount int;
begin
  amount := get_platform_setting_int('signup_coin_grant', 1000);
  if amount <= 0 then return new; end if;
  perform _ledger_apply(
    new.id, amount, 'signup', null, null, 'Welcome bonus on signup'
  );
  return new;
end;
$$;

drop trigger if exists trg_profiles_signup_grant on profiles;
create trigger trg_profiles_signup_grant
  after insert on profiles
  for each row execute function grant_signup_coins();

-- ────────────────────────────────────────────────────────────────────────────
-- Client-callable RPCs
-- ────────────────────────────────────────────────────────────────────────────
create or replace function unlock_contact(p_tutor_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  already      uuid;
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_tutor_id then raise exception 'cannot_unlock_self'; end if;

  -- One-time per (student, tutor) — if already unlocked, no debit.
  select id into already
    from wallet_ledger
   where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id
   limit 1;
  if already is not null then
    return (select coin_balance from profiles where id = caller);
  end if;

  cost := get_platform_setting_int('unlock_coin_cost', 5);
  new_balance := _ledger_apply(
    caller, -cost, 'unlock', 'tutor', p_tutor_id,
    'Unlocked contact for tutor'
  );
  return new_balance;
end;
$$;
grant execute on function unlock_contact(uuid) to authenticated;

create or replace function apply_to_vacancy(p_vacancy_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  cost := get_platform_setting_int('apply_coin_cost', 1);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'vacancy', p_vacancy_id,
    'Applied to vacancy'
  );
  return new_balance;
end;
$$;
grant execute on function apply_to_vacancy(uuid) to authenticated;

create or replace function spend_coins_and_bid(p_job_id uuid)
returns int
language plpgsql
security definer
as $$
declare
  caller       uuid := auth.uid();
  cost         int;
  new_balance  int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  cost := get_platform_setting_int('apply_coin_cost', 1);
  new_balance := _ledger_apply(
    caller, -cost, 'apply', 'job', p_job_id,
    'Bid on job'
  );
  return new_balance;
end;
$$;
grant execute on function spend_coins_and_bid(uuid) to authenticated;

-- Admin-only manual adjustments.
create or replace function admin_credit(p_user uuid, p_delta int, p_reason_note text)
returns int
language plpgsql
security definer
as $$
declare
  caller uuid := auth.uid();
begin
  if not exists (select 1 from admin_users where id = caller) then
    raise exception 'not_admin';
  end if;
  return _ledger_apply(p_user, p_delta, 'admin', null, null, p_reason_note);
end;
$$;
grant execute on function admin_credit(uuid, int, text) to authenticated;
