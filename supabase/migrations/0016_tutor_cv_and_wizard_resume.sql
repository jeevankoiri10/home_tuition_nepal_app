-- Home Tuition Nepal — Phase 19 schema.
-- Stores the uploaded CV URL and persists the wizard step a tutor closed
-- the app on, so reopening the app drops them back at the same place.
--
-- Run after 0015_tutor_location_rpc.sql.
--
-- BUCKET PROVISIONING: the storage bucket itself must be created via the
-- Supabase dashboard (Storage → New bucket → "tutor-cvs", public read). The
-- RLS policies below assume the bucket already exists.

alter table tutors add column if not exists cv_url      text;
alter table tutors add column if not exists wizard_step integer not null default 0;

-- Allow the owning tutor to upload / overwrite / delete objects under their
-- own UUID folder, and anyone signed in to read (the marketing site uses the
-- anon key so we keep that read open too via the bucket's public flag).
do $$
begin
  if exists (select 1 from storage.buckets where id = 'tutor-cvs') then
    -- Authenticated owner can insert into their own folder.
    drop policy if exists tutor_cvs_owner_insert on storage.objects;
    create policy tutor_cvs_owner_insert
      on storage.objects for insert to authenticated
      with check (
        bucket_id = 'tutor-cvs'
        and (storage.foldername(name))[1] = auth.uid()::text
      );

    -- Owner can update (used for upsert).
    drop policy if exists tutor_cvs_owner_update on storage.objects;
    create policy tutor_cvs_owner_update
      on storage.objects for update to authenticated
      using (
        bucket_id = 'tutor-cvs'
        and (storage.foldername(name))[1] = auth.uid()::text
      );

    -- Owner can delete their own CV.
    drop policy if exists tutor_cvs_owner_delete on storage.objects;
    create policy tutor_cvs_owner_delete
      on storage.objects for delete to authenticated
      using (
        bucket_id = 'tutor-cvs'
        and (storage.foldername(name))[1] = auth.uid()::text
      );

    -- Public read (students need to download the CV via the URL stored on
    -- the tutor row). Mirrors the bucket's public flag.
    drop policy if exists tutor_cvs_public_read on storage.objects;
    create policy tutor_cvs_public_read
      on storage.objects for select
      using (bucket_id = 'tutor-cvs');
  end if;
end$$;
