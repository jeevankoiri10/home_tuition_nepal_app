-- Home Tuition Nepal — bidirectional reviews (Upwork-style).
--
-- 0008 added student→tutor reviews (`reviews`). This adds the reverse
-- direction: a tutor reviews a student after a contract, mirroring how an
-- Upwork freelancer reviews a client. Kept as a parallel table so the
-- existing tutor rating/ranking pipeline is untouched.
--
-- Run after 0018_contracts.sql.

-- Student rating aggregate, surfaced like tutors.rating.
alter table profiles add column if not exists student_rating       numeric(3,2) not null default 0;
alter table profiles add column if not exists student_rating_count integer      not null default 0;

create table if not exists student_reviews (
  id          uuid primary key default uuid_generate_v4(),
  student_id  uuid not null references profiles(id) on delete cascade, -- reviewee
  tutor_id    uuid not null references profiles(id) on delete cascade, -- author
  contract_id uuid references contracts(id) on delete set null,
  stars       smallint not null check (stars between 1 and 5),
  text        text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (student_id, tutor_id)
);

create index if not exists student_reviews_student_idx on student_reviews(student_id, created_at desc);
create index if not exists student_reviews_tutor_idx   on student_reviews(tutor_id, created_at desc);

drop trigger if exists trg_student_reviews_updated_at on student_reviews;
create trigger trg_student_reviews_updated_at
  before update on student_reviews
  for each row execute function set_updated_at();

alter table student_reviews enable row level security;

drop policy if exists student_reviews_select_all on student_reviews;
create policy student_reviews_select_all on student_reviews for select using (true);

-- Only the authoring tutor may write their own row.
drop policy if exists student_reviews_insert_self on student_reviews;
create policy student_reviews_insert_self on student_reviews
  for insert with check (auth.uid() = tutor_id);

drop policy if exists student_reviews_update_self on student_reviews;
create policy student_reviews_update_self on student_reviews
  for update using (auth.uid() = tutor_id) with check (auth.uid() = tutor_id);

drop policy if exists student_reviews_delete_self on student_reviews;
create policy student_reviews_delete_self on student_reviews
  for delete using (auth.uid() = tutor_id);

-- Recompute a single student's rating aggregate.
create or replace function recompute_student_rating(p_student_id uuid)
returns void language plpgsql as $$
declare
  avg_stars numeric;
  n_reviews int;
begin
  select coalesce(avg(stars)::numeric(3,2), 0)::numeric, count(*)::int
    into avg_stars, n_reviews
    from student_reviews where student_id = p_student_id;
  update profiles
     set student_rating = avg_stars, student_rating_count = n_reviews
   where id = p_student_id;
end;
$$;

-- submit_student_review — caller (tutor) reviews a student. Gate: the two
-- must share a contract (any status) OR an unlock OR a vacancy assignment,
-- mirroring submit_review's relationship gate.
create or replace function submit_student_review(
  p_student_id uuid,
  p_stars      smallint,
  p_text       text
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  caller    uuid := auth.uid();
  gated     boolean;
  review_id uuid;
begin
  if caller is null then raise exception 'not_authenticated'; end if;
  if caller = p_student_id then raise exception 'cannot_review_self'; end if;
  if p_stars < 1 or p_stars > 5 then raise exception 'invalid_stars'; end if;
  if _has_phone_or_contact(coalesce(p_text, '')) then
    raise exception 'phone_in_review';
  end if;

  gated := exists (
      select 1 from contracts
       where tutor_id = caller and student_id = p_student_id
    ) or exists (
      select 1 from wallet_ledger
       where user_id = p_student_id and reason = 'unlock' and ref_id = caller
    ) or exists (
      select 1 from vacancies
       where linked_student = p_student_id and filled_by_tutor = caller
    );
  if not gated then raise exception 'gate_not_met'; end if;

  insert into student_reviews(student_id, tutor_id, stars, text)
  values (p_student_id, caller, p_stars, p_text)
  on conflict (student_id, tutor_id) do update
    set stars = excluded.stars,
        text  = excluded.text,
        updated_at = now()
  returning id into review_id;

  perform recompute_student_rating(p_student_id);
  return review_id;
end;
$$;
grant execute on function submit_student_review(uuid, smallint, text) to authenticated;
