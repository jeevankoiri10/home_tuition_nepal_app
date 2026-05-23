# Supabase setup — Phase 2

The app boots in **dev mode** (in-memory `FakeAuthRepository`, demo OTP `123456`) when no Supabase credentials are provided. Switch to a real backend by:

## 1. Create the Supabase project

1. Sign in at https://supabase.com and create a new project.
2. Copy the **Project URL** (e.g., `https://xxxx.supabase.co`) and the **anon public key**.

## 2. Apply the Phase 2 schema

In the Supabase **SQL editor**, paste and run `supabase/migrations/0001_phase2_profiles.sql`. This creates `profiles`, `admin_users`, `platform_settings`, `notifications`, plus the role-immutability and Code-of-Conduct triggers, plus RLS policies.

## 3. Enable Phone auth (SMS OTP)

In the Supabase dashboard → **Authentication → Providers**:

- Enable **Phone**.
- Pick an SMS provider (Twilio is the easiest). Add the provider's API key and from-number.
- Set OTP length to 6.

## 4. (Optional) Enable Google OAuth

Authentication → Providers → **Google** → enable and paste the OAuth client ID/secret from Google Cloud Console. (Add `https://xxxx.supabase.co/auth/v1/callback` as an authorized redirect URI.)

## 5. Run the app with credentials

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJh...
```

When `SUPABASE_URL` is non-empty, `lib/app/di.dart` registers the real `SupabaseAuthRepository` instead of the fake one.

## 6. Verify

- Open the app → Splash → Login → Register.
- Register a new student → OTP code arrives via SMS → enter it → land on the Student home placeholder.
- Repeat as tutor → must accept the Code of Conduct → OTP → land on Tutor home.

## 7. Common gotchas

- **`profiles_insert_self` policy fails:** the insert must run while the user is authenticated. Our flow calls `signUp()` first and then inserts the row — Supabase auto-signs-in the user on signup, so this should work. If it doesn't, check that **Email confirmations** is disabled for the project (Auth → Email → "Confirm email") during development.
- **OTP never arrives:** check the SMS provider's logs; double-check the `+977` prefix is included.
- **Role-immutability errors on UPDATE:** that's the `trg_profiles_block_role_change` trigger doing its job. Don't update `role` from the client.

## 8. Local-dev shortcut

If you just want to click through the UI without any backend, omit the `--dart-define` flags. The `FakeAuthRepository` accepts any well-formed input and the demo OTP is `123456`.
