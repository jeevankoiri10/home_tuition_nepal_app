-- Home Tuition Nepal — tutor profile completion v2.
--
-- The original compute_tutor_completion (0002) ignored two core onboarding
-- steps: the service-area map pin (tutors.geog) and the uploaded CV
-- (tutors.cv_url, added in 0016). This redefines it to include both, with
-- weights re-balanced to still sum to 100. Kept byte-for-byte in sync with
-- TutorProfile.computeCompletion on the client.
--
-- Run after 0021_topup_receipt_rpcs.sql. The refresh_tutor_completion trigger
-- (0002) already recomputes on every tutor write, so cv_url / geog changes
-- now move the bar.

create or replace function compute_tutor_completion(t_id uuid)
returns smallint
language sql
as $$
  with t as (select * from tutors where id = t_id),
       o_count as (select count(*) c from tutor_offerings where tutor_id = t_id),
       avail as (select slots from tutor_availability where tutor_id = t_id)
  select greatest(0, least(100,
    (case when (select teaching_mode from t) is not null then 10 else 0 end) +
    (case when array_length((select levels_taught from t), 1) > 0 then 10 else 0 end) +
    (case when (select c from o_count) > 0 then 15 else 0 end) +
    (case when (select c from o_count) >= 3 then 5  else 0 end) +
    (case when coalesce(length((select about_me from t)),0)       >= 100 then 10 else 0 end) +
    (case when coalesce(length((select about_sessions from t)),0) >= 50  then 10 else 0 end) +
    (case when coalesce(length((select qualifications from t)),0) >= 30  then 10 else 0 end) +
    (case when (select slots from avail) is not null
              and jsonb_typeof((select slots from avail)) = 'object'
              and (select count(*) from jsonb_each((select slots from avail))) > 0
              then 10 else 0 end) +
    (case when array_length((select languages_known from t), 1) > 0 then 5 else 0 end) +
    (case when (select geog from t) is not null then 5 else 0 end) +
    (case when coalesce(length((select cv_url from t)),0) > 0 then 10 else 0 end)
  ))::smallint;
$$;

-- Recompute everyone once so existing rows reflect the new formula.
update tutors set profile_completion = compute_tutor_completion(id);
