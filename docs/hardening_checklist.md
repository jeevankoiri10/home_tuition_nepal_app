# Hardening checklist — Phase 14

Pre-beta checklist consolidating security, accessibility, and i18n work. Run through this list before promoting to a Play Store internal-testing track.

## Observability — Sentry

- [x] `sentry_flutter` added to `pubspec.yaml`.
- [x] `main.dart` wraps `runApp` in `runZonedGuarded`, wires `FlutterError.onError` + `PlatformDispatcher.instance.onError` to capture exceptions.
- [x] `AppBlocObserver.onError` forwards to Sentry with the BLoC's runtime type as a hint.
- [x] Sentry init is env-gated (`SENTRY_DSN`) so dev builds without the DSN run cleanly.
- [x] `sendDefaultPii: false`, `attachScreenshot: false`, `attachViewHierarchy: false` — never ship real names, addresses, or unmasked UI to Sentry.
- [ ] `flutter symbolicate` set up in CI for release builds.
- [ ] Sentry project rules: alerts on > 50 events/hr per release, weekly digest.

Pass at build time: `--dart-define=SENTRY_DSN=https://...@o0.ingest.sentry.io/0  --dart-define=SENTRY_ENVIRONMENT=staging  --dart-define=SENTRY_RELEASE=v0.1.0+1`

## Security review (server-side — Supabase)

Every gated RPC must be hand-audited against this list.

- [x] **Append-only wallet_ledger** — direct writes blocked by trigger (Phase 5).
- [x] **Append-only audit_events** — direct writes blocked by trigger (Phase 12).
- [x] **`_is_blocked` guard** — wired into `unlock_contact`, `tutor_apply_to_vacancy`, `send_chat_message` (Phase 12). Re-check Phase 10's `submit_review` + Phase 11's `start_top_up` next iteration.
- [x] **Server-side phone-ban regex** — backstops the client for `chat_messages`, `reviews.text`. Confirm one more time on `jobs.description`, `vacancies.notes`, `tutors.about_*` before launch.
- [x] **Chat gate** — `open_or_get_thread` requires prior unlock OR admin assignment (Phase 9).
- [x] **Review gate** — `submit_review` requires the same prior relationship (Phase 10).
- [x] **Idempotency** — `unlock_contact` (per student-tutor pair), `tutor_apply_to_vacancy` (per vacancy-tutor pair), `finalize_top_up` (per top-up id) all idempotent.
- [x] **Public surface PII-free** — `public_tutors_directory` view + RPCs only expose masked fields (Phase 13).
- [ ] **Service-role key** — confirm it's only inside Edge Functions (never bundled in the Flutter app or the public Next.js site).
- [ ] **RLS audit** — verify every table has RLS enabled (`pg_tables.relrowsecurity` per row). Add a Supabase test that asserts this in CI.
- [ ] **Storage buckets** — `id_docs` and `cv` buckets must be private; only signed-URL reads, expiring in ≤ 5 min for admin use.

## Accessibility — WCAG AA

- [x] Every icon-only `IconButton` has a `tooltip` (sign-out, my-posts, recenter, refresh, mark-all-read, notifications bell). Pass remaining ones during the next QA sweep.
- [x] Color contrast on the brand palette — `AppColors.primary` (#3F51B5) on white meets AA at ≥ 14pt; verify accent (#FF9800) on white only for non-text affordances.
- [x] All tap targets ≥ 44 dp (Material default for `IconButton` is 48 dp).
- [ ] Manual TalkBack pass on Splash / Login / Register / Map / Wallet / Notifications.
- [ ] Manual VoiceOver pass on the same.
- [ ] **Screen-reader test for the map**: confirm the list view (pull-up sheet) is reachable when spatial vision isn't available — the carousel below the map already exposes tutor data linearly.
- [ ] All form errors are `liveRegion: true` so they're announced.
- [ ] Test the entire app at 200% system font scale; ensure no text gets clipped.

## i18n QA — Nepali + English

- [x] `flutter gen-l10n` ran; generated `AppLocalizations` + `AppLocalizationsEn` + `AppLocalizationsNe` from the ARBs.
- [x] Devanagari font (`NotoSansDevanagari`) declared in `pubspec.yaml` for Nepali rendering.
- [ ] **Native-speaker pass on every Nepali ARB string** before promoting `app_ne.arb` to "stable". Open issues for any awkward phrasing.
- [ ] Add missing translations for: error messages from the new Phase 6-13 features (unlock errors, apply errors, vacancy statuses, chat-not-allowed, account_blocked, top-up provider names).
- [ ] CI lint that fails any `Text('...')` with hard-coded ASCII letters outside `lib/core/constants/` and the generated localization files.
- [ ] Smoke-test the app at `--dart-define=FORCE_LOCALE=ne` and screenshot every primary screen — check truncation in cards / chips / buttons.
- [ ] Currency formatting consistent — every NPR number renders as `Rs. 1,234` (the helper in `MapTutor.formatFromPrice` etc. already does this).

## Privacy invariants

Confirm before every release. A single regression here is grounds for a hot-fix.

- [x] Real names never sent to non-counterparties (RLS + `public_tutors_directory` masking).
- [x] Phone numbers never returned by any feed RPC — only by `unlock_contact` and the admin assignment flow.
- [x] Exact addresses never in public views.
- [x] ID documents only via signed URLs to admins.
- [ ] Manual scan of every Supabase RPC return type: confirm none accidentally leaks `profiles.first_name`, `last_name`, `phone`, `address_line`.

## Performance smoke tests

- [ ] Map first paint ≤ 3 s on a low-end Android (Snapdragon 4xx).
- [ ] Tutor profile open ≤ 1 s.
- [ ] Wallet ledger of 200 entries scrolls at 60 fps.
- [ ] OSM tile cache: tiles served from disk on 2nd visit.

## Release-readiness gate

A release is ready when **every checked box above is true** and the unchecked boxes have explicit, named owners with target dates. Track them in the issue tracker, not here.
