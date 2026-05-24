-- Phase 8 push notifications: each authenticated device persists its FCM
-- (or OneSignal) token on the profile row so the future `push_dispatcher`
-- Edge Function can look up where to send remote notifications.
--
-- Token is optional — users who never grant Permission.notification (or are
-- on web) keep it null. Tokens are not user-private at the privacy-policy
-- level but live behind the same RLS as the rest of profiles.* and are
-- never exposed to other authenticated users.

alter table profiles
  add column if not exists push_token text;

create index if not exists profiles_push_token_idx
  on profiles (push_token)
  where push_token is not null;
