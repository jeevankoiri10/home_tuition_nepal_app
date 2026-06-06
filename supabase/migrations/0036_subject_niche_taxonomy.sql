-- Home Tuition Nepal — Subject & Niche taxonomy (matching algorithm P1).
-- Run after 0035_percentage_bid_cost.sql.
--
-- See docs/matching-algorithm-design.md §4 / §4.1. This is the foundation the
-- composite match score (P2) is built on. It is fully ADDITIVE and reversible:
--   * two new catalog tables (subjects, niche_tags)
--   * nullable id columns alongside the existing free-text fields (never dropped)
--   * denormalized id arrays on tutors/vacancies/jobs for cheap set-overlap
--   * a resolver + backfill, with an admin review queue for the unmatched tail
--
-- Nothing here changes matching behaviour yet — it only populates the data the
-- scorer will read. The free-text `subject`/`subjects` columns stay as the
-- source of truth for display/SEO until the catalog is fully reconciled.

-- ════════════════════════════════════════════════════════════════════════════
-- 1. Canonical subject catalog (set-overlap instead of substring matching).
--    parent_id lets a "physics" tutor partially match a "science" request.
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists subjects (
  id           serial primary key,
  slug         text not null unique,
  display_name text not null,
  aliases      text[] not null default '{}',   -- includes Devanagari + romanized
  parent_id    int references subjects(id) on delete set null,
  level_tags   text[] not null default '{}',   -- e.g. {below_class_9,see,plus_2}
  created_at   timestamptz not null default now()
);

-- ════════════════════════════════════════════════════════════════════════════
-- 2. Niche / specialization catalog — orthogonal to subjects (§4.1). Exam
--    boards, prep tracks and specializations are how Nepalis actually hire.
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists niche_tags (
  id           serial primary key,
  slug         text not null unique,
  display_name text not null,
  category     text not null check (category in ('exam_board','prep_track','specialization')),
  aliases      text[] not null default '{}',
  created_at   timestamptz not null default now()
);

-- ════════════════════════════════════════════════════════════════════════════
-- 3. Additive id columns alongside the existing free-text fields.
-- ════════════════════════════════════════════════════════════════════════════
-- Per-offering canonical subject (free-text `subject` stays the source of truth).
alter table tutor_offerings add column if not exists subject_id int references subjects(id) on delete set null;

-- Denormalized aggregates on tutors for O(1) set-overlap in the scorer.
alter table tutors add column if not exists subject_ids  int[] not null default '{}';
alter table tutors add column if not exists niche_tag_ids int[] not null default '{}';

-- Requests carry their own ids (vacancies hold arrays; jobs are single-subject).
alter table vacancies add column if not exists subject_ids   int[] not null default '{}';
alter table vacancies add column if not exists niche_tag_ids int[] not null default '{}';
alter table jobs      add column if not exists subject_id    int references subjects(id) on delete set null;
alter table jobs      add column if not exists niche_tag_ids int[] not null default '{}';

-- GIN indexes make `&&` / `@>` array-overlap on the gated candidate set cheap.
create index if not exists tutors_subject_ids_gix   on tutors    using gin (subject_ids);
create index if not exists tutors_niche_tag_ids_gix on tutors    using gin (niche_tag_ids);
create index if not exists vacancies_subject_ids_gix on vacancies using gin (subject_ids);
create index if not exists jobs_niche_tag_ids_gix   on jobs      using gin (niche_tag_ids);

-- ════════════════════════════════════════════════════════════════════════════
-- 4. RLS — catalogs are public-readable, admin-writable (matches house style).
-- ════════════════════════════════════════════════════════════════════════════
alter table subjects   enable row level security;
alter table niche_tags enable row level security;

drop policy if exists subjects_select_public on subjects;
create policy subjects_select_public on subjects for select using (true);
drop policy if exists subjects_admin_write on subjects;
create policy subjects_admin_write on subjects for all
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

drop policy if exists niche_tags_select_public on niche_tags;
create policy niche_tags_select_public on niche_tags for select using (true);
drop policy if exists niche_tags_admin_write on niche_tags;
create policy niche_tags_admin_write on niche_tags for all
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- ════════════════════════════════════════════════════════════════════════════
-- 5. Seed the Nepal curriculum. Parents first, then children reference them.
--    Aliases are lower-cased on lookup, so mixed case here is fine.
-- ════════════════════════════════════════════════════════════════════════════
insert into subjects (slug, display_name, aliases, level_tags) values
  ('science',            'Science',             array['vigyan','विज्ञान','sci'],                        array['below_class_9','see']),
  ('mathematics',        'Mathematics',         array['math','maths','ganit','गणित','compulsory math'], array['below_class_9','see','plus_2']),
  ('optional_mathematics','Optional Mathematics',array['opt math','optional math','add math','aitihik ganit'], array['see']),
  ('english',            'English',             array['eng','angreji','अंग्रेजी'],                      array['below_class_9','see','plus_2']),
  ('nepali',             'Nepali',              array['nepali bhasha','नेपाली'],                        array['below_class_9','see','plus_2']),
  ('social_studies',     'Social Studies',      array['social','samajik','सामाजिक','social studies and population'], array['below_class_9','see']),
  ('health_population',  'Health & Physical Edu.',array['hpe','health population','swasthya'],          array['see']),
  ('computer_science',   'Computer Science',    array['computer','it','ict','कम्प्युटर','computer studies'], array['below_class_9','see','plus_2']),
  ('accountancy',        'Accountancy',         array['accounts','account','lekha'],                    array['plus_2']),
  ('economics',          'Economics',           array['eco','arthashastra','अर्थशास्त्र'],              array['plus_2']),
  ('business_studies',   'Business Studies',    array['business','bst'],                                array['plus_2'])
on conflict (slug) do nothing;

-- Science children → parent.
insert into subjects (slug, display_name, aliases, parent_id, level_tags)
select v.slug, v.display_name, v.aliases, (select id from subjects where slug='science'), v.level_tags
from (values
  ('physics',   'Physics',   array['bhautik shastra','भौतिक'],          array['plus_2','a_level']),
  ('chemistry', 'Chemistry', array['rasayan shastra','रसायन'],          array['plus_2','a_level']),
  ('biology',   'Biology',   array['jeev vigyan','जीव विज्ञान','bio'],  array['plus_2','a_level'])
) as v(slug, display_name, aliases, level_tags)
on conflict (slug) do nothing;

insert into niche_tags (slug, display_name, category, aliases) values
  -- exam boards
  ('see',                 'SEE',                     'exam_board', array['slc','secondary education examination']),
  ('neb_plus2_science',   'NEB +2 Science',          'exam_board', array['plus 2 science','+2 science','11 science','12 science']),
  ('neb_plus2_management','NEB +2 Management',        'exam_board', array['plus 2 management','+2 management','commerce']),
  ('neb_plus2_humanities','NEB +2 Humanities',        'exam_board', array['plus 2 humanities','+2 humanities','arts']),
  ('a_levels',            'A / O Levels',             'exam_board', array['a level','o level','cambridge','gce']),
  ('ib',                  'IB',                       'exam_board', array['international baccalaureate']),
  ('cbse',                'CBSE / Indian Board',      'exam_board', array['icse','indian curriculum']),
  -- prep tracks
  ('loksewa',             'Loksewa Prep',             'prep_track', array['lok sewa','public service','psc','loksewa aayog']),
  ('ielts',               'IELTS',                    'prep_track', array['ielts prep']),
  ('pte',                 'PTE',                      'prep_track', array['pte academic']),
  ('toefl',               'TOEFL',                    'prep_track', array[]::text[]),
  ('sat',                 'SAT',                      'prep_track', array['scholastic aptitude test']),
  ('ioe_entrance',        'IOE / Engineering Entrance','prep_track', array['ioe','engineering entrance','iom engineering']),
  ('mbbs_entrance',       'MBBS / Medical Entrance',  'prep_track', array['mecee','medical entrance','cee']),
  ('ca',                  'CA',                       'prep_track', array['chartered accountancy']),
  ('acca',                'ACCA',                     'prep_track', array[]::text[]),
  ('bridge_course',       'Bridge Course',            'prep_track', array['bridge']),
  -- specializations
  ('spoken_english',      'Spoken English',           'specialization', array['conversational english','communication']),
  ('special_needs',       'Special Needs',            'specialization', array['learning disability','autism','adhd']),
  ('early_childhood',     'Early Childhood',          'specialization', array['montessori','pre-school','kindergarten','ecd']),
  ('olympiad',            'Olympiad',                 'specialization', array['math olympiad','science olympiad']),
  ('coding_kids',         'Coding for Kids',          'specialization', array['scratch','kids coding','python for kids']),
  ('music',               'Music',                    'specialization', array['guitar','piano','tabla','vocal'])
on conflict (slug) do nothing;

-- ════════════════════════════════════════════════════════════════════════════
-- 6. Resolver — free-text → canonical subject id (slug / name / alias, ci).
--    STABLE; used by the backfill and by app-side write paths going forward.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function resolve_subject_id(p_text text)
returns int
language sql
stable
set search_path = public
as $$
  select s.id
    from subjects s
   where p_text is not null
     and ( lower(trim(p_text)) = lower(s.slug)
        or lower(trim(p_text)) = lower(s.display_name)
        or lower(trim(p_text)) = any (select lower(a) from unnest(s.aliases) a) )
   limit 1;
$$;
grant execute on function resolve_subject_id(text) to authenticated, anon;

-- ════════════════════════════════════════════════════════════════════════════
-- 7. Admin review queue — distinct free-text subjects the resolver could not
--    place. Admins map these by adding an alias to the right canonical row.
-- ════════════════════════════════════════════════════════════════════════════
create table if not exists subject_mapping_review (
  raw_subject text primary key,
  occurrences int not null default 1,
  resolved    boolean not null default false,
  created_at  timestamptz not null default now()
);
alter table subject_mapping_review enable row level security;
drop policy if exists subject_mapping_review_admin on subject_mapping_review;
create policy subject_mapping_review_admin on subject_mapping_review for all
  using (exists (select 1 from admin_users where id = auth.uid()))
  with check (exists (select 1 from admin_users where id = auth.uid()));

-- ════════════════════════════════════════════════════════════════════════════
-- 8. Backfill existing offerings, then log the unmatched tail for admin review.
-- ════════════════════════════════════════════════════════════════════════════
update tutor_offerings
   set subject_id = resolve_subject_id(subject)
 where subject_id is null;

update jobs
   set subject_id = resolve_subject_id(subject)
 where subject_id is null and subject is not null;

insert into subject_mapping_review (raw_subject, occurrences)
select lower(trim(subject)) as raw, count(*)
  from tutor_offerings
 where subject_id is null and subject is not null and trim(subject) <> ''
 group by lower(trim(subject))
on conflict (raw_subject) do update set occurrences = excluded.occurrences;

-- ════════════════════════════════════════════════════════════════════════════
-- 9. Keep tutors.subject_ids in sync with their offerings (denormalization the
--    scorer relies on). Trigger covers future writes; statement below seeds it.
-- ════════════════════════════════════════════════════════════════════════════
create or replace function _sync_tutor_subject_ids()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_tutor uuid := coalesce(new.tutor_id, old.tutor_id);
begin
  update tutors t
     set subject_ids = coalesce((
       select array_agg(distinct o.subject_id)
         from tutor_offerings o
        where o.tutor_id = v_tutor and o.subject_id is not null
     ), '{}')
   where t.id = v_tutor;
  return null;
end;
$$;

drop trigger if exists trg_sync_tutor_subject_ids on tutor_offerings;
create trigger trg_sync_tutor_subject_ids
  after insert or update of subject_id, subject or delete on tutor_offerings
  for each row execute function _sync_tutor_subject_ids();

-- Seed the aggregate for tutors that already have offerings.
update tutors t
   set subject_ids = coalesce((
     select array_agg(distinct o.subject_id)
       from tutor_offerings o
      where o.tutor_id = t.id and o.subject_id is not null
   ), '{}');
