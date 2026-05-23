-- Home Tuition Nepal — Phase 10 schema (reviews, ratings, boosts).
-- Run after 0007_phase9_chat.sql.

-- ────────────────────────────────────────────────────────────────────────────
-- reviews — one row per (student, tutor) pair. Edits replace the row.
-- ────────────────────────────────────────────────────────────────────────────
create table if not exists reviews (
  id          uuid primary key default uuid_generate_v4(),
  tutor_id    uuid not null references profiles(id) on delete cascade,
  student_id  uuid not null references profiles(id) on delete cascade,
  job_id      uuid references jobs(id)      on delete set null,
  vacancy_id  uuid references vacancies(id) on delete set null,
  stars       smallint not null check (stars between 1 and 5),
  text        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (tutor_id, student_id)
);

create index if not exists reviews_tutor_idx on reviews(tutor_id, created_at desc);
create index if not exists reviews_student_idx on reviews(student_id, created_at desc);

drop trigger if exists trg_reviews_updated_at on reviews;
create trigger trg_reviews_updated_at
  before update on reviews
  for each row execute function set_updated_at();

alter table reviews enable row level security;

-- Anyone authenticated can read reviews; only the author can write their row.
drop policy if exists reviews_select_all on reviews;
create policy reviews_select_all on reviews for select using (true);

drop policy if exists reviews_insert_self on reviews;
create policy reviews_insert_self on reviews for insert with check (auth.uid() = student_id);

drop policy if exists reviews_update_self on reviews;
create policy reviews_update_self on reviews for update
  using (auth.uid() = student_id) with check (auth.uid() = student_id);

drop policy if exists reviews_delete_self on reviews;
create policy reviews_delete_self on reviews for delete using (auth.uid() = student_id);

-- ────────────────────────────────────────────────────────────────────────────
-- submit_review — must already have a relationship gate (unlock or assignment).
-- Recomputes tutors.rating + rating_count + ranking_score on every write.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function submit_review(
  p_tutor_id uuid,
  p_stars    smallint,
  p_text     text
) returns uuid
language plpgsql
security definer
as $$
declare
  caller     uuid := auth.uid();
  unlocked   boolean;
  assigned   boolean;
  review_id  uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_tutor_id then raise exception 'cannot_review_self'; end if;
  if p_stars < 1 or p_stars > 5 then raise exception 'invalid_stars'; end if;
  if _has_phone_or_contact(coalesce(p_text, '')) then
    raise exception 'phone_in_review';
  end if;

  unlocked := exists (
    select 1 from wallet_ledger
     where user_id = caller and reason = 'unlock' and ref_id = p_tutor_id
  );
  assigned := exists (
    select 1 from vacancies
     where linked_student = caller and filled_by_tutor = p_tutor_id
  );
  if not unlocked and not assigned then
    raise exception 'gate_not_met';
  end if;

  insert into reviews(tutor_id, student_id, stars, text)
  values (p_tutor_id, caller, p_stars, p_text)
  on conflict (tutor_id, student_id) do update
    set stars = excluded.stars,
        text  = excluded.text,
        updated_at = now()
  returning id into review_id;

  perform recompute_tutor_rating(p_tutor_id);
  return review_id;
end;
$$;
grant execute on function submit_review(uuid, smallint, text) to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- recompute_tutor_rating — single tutor's rating + rating_count + ranking_score.
-- ranking_score = weighted blend of rating, review count, completion %, verified
-- flag, premium membership, and a recency bonus from updated_at.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function recompute_tutor_rating(p_tutor_id uuid)
returns void
language plpgsql
as $$
declare
  avg_stars numeric;
  n_reviews int;
  t         record;
  score     numeric;
begin
  select coalesce(avg(stars)::numeric(3,2), 0)::numeric,
         count(*)::int
    into avg_stars, n_reviews
    from reviews where tutor_id = p_tutor_id;

  update tutors set rating = avg_stars, rating_count = n_reviews
   where id = p_tutor_id;

  select * into t from tutors where id = p_tutor_id;
  if t is null then return; end if;

  score := 0;
  score := score + coalesce(t.rating, 0) * 15;                     -- 0..75
  score := score + least(coalesce(t.rating_count, 0), 20) * 1.0;   -- 0..20
  score := score + coalesce(t.profile_completion, 0) * 0.2;        -- 0..20
  if t.verified then score := score + 10; end if;
  if t.premium_until is not null and t.premium_until > now() then score := score + 8; end if;
  if t.featured_until is not null and t.featured_until > now() then score := score + 5; end if;
  -- recency bonus (decays over a year)
  score := score + greatest(0, 5 - extract(epoch from (now() - t.updated_at)) / (86400 * 73.0));

  update tutors set ranking_score = score where id = p_tutor_id;
end;
$$;

-- Nightly batch — call from a cron / Edge Function trigger.
create or replace function recompute_all_tutor_rankings()
returns void
language plpgsql
as $$
declare r record;
begin
  for r in select id from tutors loop
    perform recompute_tutor_rating(r.id);
  end loop;
end;
$$;
grant execute on function recompute_all_tutor_rankings() to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- Boost RPCs — debit coins atomically and set the expiry timestamp.
-- ────────────────────────────────────────────────────────────────────────────
create or replace function boost_tutor_featured(p_hours int default 24)
returns int
language plpgsql
security definer
as $$
declare
  caller      uuid := auth.uid();
  cost        int;
  new_balance int;
  new_until   timestamptz;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from tutors where id = caller) then
    raise exception 'not_a_tutor';
  end if;
  cost := get_platform_setting_int('featured_listing_cost', 50);
  new_balance := _ledger_apply(caller, -cost, 'boost', 'tutor', caller, 'Featured listing');
  new_until := greatest(
    coalesce((select featured_until from tutors where id = caller), now()),
    now()
  ) + make_interval(hours => p_hours);
  update tutors set featured_until = new_until where id = caller;
  perform recompute_tutor_rating(caller);
  return new_balance;
end;
$$;
grant execute on function boost_tutor_featured(int) to authenticated;

create or replace function promote_job(p_job_id uuid, p_hours int default 24)
returns int
language plpgsql
security definer
as $$
declare
  caller      uuid := auth.uid();
  cost        int;
  new_balance int;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if not exists (select 1 from jobs where id = p_job_id and student_id = caller) then
    raise exception 'not_owner';
  end if;
  cost := get_platform_setting_int('promoted_job_cost', 20);
  new_balance := _ledger_apply(caller, -cost, 'boost', 'job', p_job_id, 'Promoted job');
  update jobs set promoted_until = greatest(coalesce(promoted_until, now()), now()) +
                                    make_interval(hours => p_hours)
    where id = p_job_id;
  return new_balance;
end;
$$;
grant execute on function promote_job(uuid, int) to authenticated;
