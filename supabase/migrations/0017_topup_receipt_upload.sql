-- Home Tuition Nepal — Phase 20 schema.
-- Tracks the post-payment receipt the user uploads after sending money via
-- eSewa. An admin reviews `coin_top_ups` rows where `receipt_url is not null
-- and status = 'pending'` and credits the wallet through the existing
-- `finalize_top_up` RPC.
--
-- Run after 0016_tutor_cv_and_wizard_resume.sql.
--
-- BUCKET PROVISIONING: create the `topup-receipts` bucket in the Supabase
-- dashboard (public read; owner-only write). Policies below assume it exists.

alter table coin_top_ups add column if not exists receipt_url text;

do $$
begin
  if exists (select 1 from storage.buckets where id = 'topup-receipts') then
    -- Owner can upload to their own top-up folder. Object name layout:
    --   {topup_id}/receipt.{ext}
    -- The first folder segment is the top-up id; we check it belongs to the
    -- caller via the coin_top_ups join.
    drop policy if exists topup_receipts_owner_insert on storage.objects;
    create policy topup_receipts_owner_insert
      on storage.objects for insert to authenticated
      with check (
        bucket_id = 'topup-receipts'
        and exists (
          select 1 from coin_top_ups
           where coin_top_ups.id::text = (storage.foldername(name))[1]
             and coin_top_ups.user_id = auth.uid()
        )
      );

    drop policy if exists topup_receipts_owner_update on storage.objects;
    create policy topup_receipts_owner_update
      on storage.objects for update to authenticated
      using (
        bucket_id = 'topup-receipts'
        and exists (
          select 1 from coin_top_ups
           where coin_top_ups.id::text = (storage.foldername(name))[1]
             and coin_top_ups.user_id = auth.uid()
        )
      );

    drop policy if exists topup_receipts_public_read on storage.objects;
    create policy topup_receipts_public_read
      on storage.objects for select
      using (bucket_id = 'topup-receipts');
  end if;
end$$;
