# Home Tuition Nepal — Comprehensive Phase-wise Implementation Plan

> **Product:** Home Tuition Nepal · **Operator:** KTM academy
> **Status:** Implementation roadmap consolidating `plan.md`, `admin_panel_plan.md`, `tutor_UI.md`, `student_UI.md`, `tutor_code_of_conduct.md`, `public_site.md`.
> **Update cadence:** Treat this as the single source of truth for "what we build next." Update it as scope evolves.

This document **prescribes the build order** so the team can ship value early and stack capability deliberately. Each phase is small enough to ship independently, large enough to be meaningful, and includes acceptance criteria so we know when it's *done*.

---

## Guiding principles (apply to every phase)

1. **Locality-first map is the headline.** Every other surface supports map discovery.
2. **Privacy by default.** Masked names, server-side phone reveal, RLS on `real_name`/`phone`/`id_docs`.
3. **Bilingual from day one.** Every string lives in ARB; no hard-coded UI text.
4. **Clean code + reusable components.** Per `CLAUDE.md`.
5. **Server-authoritative coin ledger.** Never trust client balance.
6. **Ship vertical slices.** Each phase ends with at least one usable feature end-to-end.

---

## Phase map (high-level)

| # | Phase | Goal | Approx. duration |
|---|---|---|---|
| **1** | ✅ **Foundation (shipped)** | Flutter shell ready for serious feature work | 1 week |
| **2** | ✅ **Auth & profiles (shipped)** | Users can register, verify phone, set role | 1.5 weeks |
| **3** | ✅ **Tutor profile builder (shipped)** | Tutors complete a rich profile (offerings, availability, mode, education) | 1.5 weeks |
| **4** | ✅ **Map + locality search (shipped)** | Headline feature: students see nearby tutors on a map | 2 weeks |
| **5** | ✅ **Coin system & wallet (shipped)** | Server-authoritative ledger, signup grant, apply/unlock costs | 1.5 weeks |
| **6** | ✅ **Student request flows (shipped)** | Job posts + Request-a-Tutor (vacancy draft) | 1.5 weeks |
| **7** | ✅ **Vacancies + admin matching (mobile side shipped)** | `HTN-NNNNN`, admin panel MVP, tutor apply flow | 2 weeks |
| **8** | ✅ **Notifications (in-app shipped; push docs only)** | Automatic on job post, All/Unread/Read, push | 1 week |
| **9** | ✅ **In-app chat (shipped)** | After unlock/admin assignment, with phone-ban regex | 1.5 weeks |
| **10** | ✅ **Reviews, ratings, boosts (shipped)** | Ratings, featured pins, promoted posts, ranking score | 1 week |
| **11** | ✅ **Coin top-ups (durable layer shipped; SDK wiring docs)** | eSewa / Khalti / IME Pay | 1.5 weeks |
| **12** | ✅ **Admin panel hardening (backend contract shipped)** | Verification queue, moderation, wallet ops, settings | 2 weeks |
| **13** | ✅ **Public marketing site (backend + Android App Links shipped; Next.js UI separate)** | Homepage, /find-tutors, masked deep-link previews | 2 weeks |
| **14** | ✅ **Hardening + a11y + i18n QA (in-app foundations shipped)** | Sentry, security, NE-string review, accessibility | 1 week |
| **15** | Beta + launch | Play Store beta in KTM Valley, post-launch monitoring | open |

Total ≈ 22 weeks for a stable v1 with the long tail (#13 onward) parallelizable.

---

## Phase 1 — Foundation

**Goal:** the Flutter project is ready for serious work — themed, internationalized, routed, with DI and BLoC scaffolding. No real features yet, but every future phase plugs in cleanly.

**Out of scope:** Supabase wiring, auth, real screens. We only ship the **shell**.

### Scope
- Replace the default `flutter create` skeleton.
- Add core dependencies in `pubspec.yaml`.
- Establish folder structure (clean-architecture-friendly).
- Implement the **theme** (light + dark; indigo primary, saffron accent).
- Implement **localization** (`flutter_localizations` + `intl` + ARB files for `en` and `ne`).
- Implement a **service locator** (`get_it`) and a `BlocObserver`.
- Implement `LocaleCubit` + `ThemeCubit` (persisted to `SharedPreferences`).
- Implement a **language-picker splash screen** shown before any auth (per `tutor_UI.md` §4.1 / `student_UI.md` §4.1).
- Implement a **router** (`go_router`) with placeholder routes for the future map / login / register screens.
- Implement the **AppTheme tokens** (`AppColors`, `AppSpacing`, `AppRadii`, `AppTextStyles`).
- Centralized **AppConstants** (no magic strings/numbers).

### Deliverables (files)
- Updated `pubspec.yaml`.
- `l10n.yaml`.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ne.arb`.
- `lib/main.dart` (clean entry point).
- `lib/app/app.dart` (the `MaterialApp.router`).
- `lib/app/router.dart` (go_router config).
- `lib/app/di.dart` (get_it service locator).
- `lib/app/bloc_observer.dart`.
- `lib/core/theme/app_theme.dart`.
- `lib/core/theme/app_colors.dart`.
- `lib/core/theme/app_spacing.dart`.
- `lib/core/theme/app_radii.dart`.
- `lib/core/theme/app_text_styles.dart`.
- `lib/core/constants/app_constants.dart`.
- `lib/core/blocs/locale_cubit.dart` + `locale_state.dart`.
- `lib/core/blocs/theme_cubit.dart` + `theme_state.dart`.
- `lib/features/splash/presentation/splash_page.dart` (language picker).
- `lib/features/_placeholders/login_placeholder_page.dart` and other route stubs.

### Acceptance criteria
- `flutter pub get` succeeds.
- `flutter analyze` is clean.
- App boots to the splash screen and shows the **language picker** in both Nepali and English.
- Tapping a language persists it (`SharedPreferences`) and rebuilds the app in the chosen locale.
- Theme follows the system dark/light setting by default; manual override is wired up.
- `go_router` navigates between the splash → placeholder login screen.
- No hard-coded user-facing strings outside ARB.

### Risks / mitigations
- Some packages don't yet support newer Flutter SDK. **Mitigation:** pin known-good versions; CI smoke-tests on each PR.

---

## Phase 2 — Auth & profiles

**Goal:** A user can create an account (email/password or Google), verify their phone via OTP, choose a role (permanent), and end up at a placeholder home screen for their role. Real names are stored privately; masked names are derived for display.

**Scope:** Supabase project, RLS skeleton, `profiles` table, registration form (per `plan.md` §5.1), phone OTP, Google Sign-In, ToS + Tutors' Code of Conduct acceptance.

**Deliverables:** Supabase migrations (`profiles`, `admin_users`, `platform_settings`, `notifications`), AuthRepository, AuthBloc, register/login/OTP screens, role-pick screen, Settings → Account stub.

**Acceptance criteria:**
- Register a new account → receive OTP → enter OTP → `profiles.phone_verified = true` → land on role-specific placeholder home.
- Google Sign-In works as an alternative path; still requires phone + ToS.
- Role is immutable after first set (DB trigger).
- Masked-name display utility (`displayMaskedName(first, last) → "Ramesh S*"`) is unit-tested.
- ToS / CoC acceptance timestamps persisted.

---

## Phase 3 — Tutor profile builder

**Goal:** A tutor can build a complete profile: choose teaching mode, levels, subjects with per-level prices, availability grid, About me / About my sessions / Qualifications, plus optional Education / Experience / Certificates.

**Scope:** Supabase migrations (`tutors`, `tutor_offerings`, `tutor_availability`, `tutor_education`, `tutor_experience`, `tutor_certificates`), profile-builder wizard, Profile Settings editor (per `tutor_UI.md` §4.7a).

**Acceptance criteria:**
- Tutor can finish the 7-step onboarding wizard end-to-end.
- Profile completion % is computed server-side and shown in the banner.
- Saving each section auto-saves; explicit **Save & Update** publishes (`draft_status = 'published'`) when completion ≥ 80%.
- The phone-ban regex blocks numeric strings in About me / About sessions / Qualifications.
- Citizenship + selfie + certificates upload to private Supabase Storage buckets (signed URLs only).

---

## Phase 4 — Map view + locality search **(headline feature)**

**Goal:** A logged-in student lands on a live OpenStreetMap of their area showing nearby available tutors, can filter, search, and view tutor profiles. inDrive-style.

**Scope:**
- PostGIS enabled in Supabase.
- `flutter_map` + OSM tile provider.
- `geolocator` + `geocoding`.
- Viewport-debounced query (`ST_DWithin`).
- Sticky filter chip bar (Level, Subject, Price, Gender, Verified, Mode, Radius, Available now).
- Bottom-sheet carousel of TutorCards synced to pins.
- Pull-up full list view.
- Supabase Realtime for `tutors.available` toggles.
- Tutor profile detail (About Me / Sessions / Qualifications / Subjects Offered / Weekly Availability / Reviews).

**Acceptance criteria:**
- Student opens the app → lands on the map within 3 seconds (with location permission) → sees at least the masked-name pins of every published tutor within 5 km.
- Changing the Level chip updates the matching set instantly (only tutors whose `levels_taught[]` contains the level).
- Pins and the carousel stay in sync.
- Online-only tutors are excluded from the map but appear in the list view.
- Privacy invariants intact: no real names, no exact addresses, no phone numbers anywhere on the map screen.

---

## Phase 5 — Coin system & wallet

**Goal:** Coins are credited on signup (1000 default), debited atomically on apply (1) and unlock (5), with a full transaction history. All costs admin-editable via `platform_settings`.

**Scope:** `wallet_ledger`, `platform_settings`, Edge Functions / `security definer` RPCs for `spend_coins_and_bid`, `unlock_contact`, `apply_to_vacancy`. Wallet screen (per `student_UI.md` §4.14b).

**Acceptance criteria:**
- A new account has exactly 1000 coins on first launch after onboarding.
- Applying to a vacancy debits 1 coin (or refunds with reason).
- Trying to apply with insufficient balance shows the *Buy coins* CTA.
- Ledger is append-only; no client write paths.
- Admin can change `apply_coin_cost` and clients pick up the new value on next launch.

---

## Phase 6 — Student request flows

**Goal:** Students can post a job (Upwork-style) or request a tutor (vacancy draft for admin).

**Deliverables:** Job CRUD, Request-a-Tutor form (per `student_UI.md` §4.14c), My Posts list (§4.14d), Post Detail (§4.14e). Phone-ban regex applied to every textarea.

**Acceptance criteria:**
- Posting a job or requesting a tutor creates a `jobs` or `vacancies` row (the latter in `'pending_admin_review'` status).
- The `notify_matching_tutors` trigger fires (placeholder until Phase 8 wires real push).
- Edit / close / repost flows work.

---

## Phase 7 — Vacancies + admin matching

**Goal:** Admins (Next.js panel) can publish vacancies (`HTN-NNNNN`), tutors can apply via the Vacancies tab, admins can shortlist and assign — revealing contact to both sides.

**Scope:** `vacancies`, `vacancy_applications` tables; admin panel skeleton (auth, layout, vacancies CRUD); tutor Vacancies tab + Apply sheet (CV upload).

**Acceptance criteria:**
- Admin creates a vacancy → tutors with matching levels/subjects/area see it in their feed within seconds.
- Tutor applies with 1 coin → CV uploaded → application visible to admin.
- Admin assigns → both parties receive a *Contact-revealed* notification with the counterparty's phone + name.

---

## Phase 8 — Notifications (automatic on job post)

**Goal:** Every state change that should be visible to a user produces a notification — in-app feed plus OS push. New jobs/vacancies auto-fan-out to matching tutors per `plan.md` §5.6a.

**Scope:** `notifications` table; Postgres trigger → Edge Function → FCM/OneSignal; on-device `flutter_local_notifications`; Notifications screen with All/Unread/Read tabs; quiet hours.

**Acceptance criteria:**
- Posting a job triggers a push to every matching tutor within ~5 seconds.
- Tapping a push deep-links to the right detail screen even from a terminated app.
- Quiet hours suppress pushes but keep in-app feed complete.
- Rate cap honored per `platform_settings.notif_hourly_cap`.

---

## Phase 9 — In-app chat

**Goal:** Once a contact is unlocked (or an admin assigns a match), the two parties can chat inside the app. Phone-ban regex applied to every outgoing message.

**Scope:** `chat_threads`, `chat_messages` (with `read_at`), Realtime channel for new messages, double-tick UI, Chat screen (per `student_UI.md` §4.14f).

**Acceptance criteria:**
- A thread cannot be created without a prior unlock or assignment.
- Messages send/receive with sub-second latency on Realtime.
- Read receipts work end-to-end.
- Phone-number content in a message is rejected with a clear toast.

---

## Phase 10 — Reviews, ratings, boosts

**Goal:** Students can review tutors after engagement; tutors can boost their listing; ranking score recomputed nightly.

**Scope:** `reviews` table + RPCs, Review screen, *Featured listing* + *Pinned bid* + *Promoted job* coin sinks, `tutors.ranking_score` computed nightly.

---

## Phase 11 — Coin top-ups

**Goal:** Real money becomes coins via eSewa / Khalti / IME Pay. The only fiat ingress in the platform.

**Scope:** SDK integrations, Edge Function webhook verification, receipt screens, refund flows from admin panel.

---

## Phase 12 — Admin panel hardening

**Goal:** The admin panel is production-ready — verification queue, moderation, wallet ops, settings editor, audit log search, analytics dashboards (per `admin_panel_plan.md`).

---

## Phase 13 — Public marketing site

**Goal:** Public Next.js site live at `homenepal.app` (or chosen domain) with homepage, /find-tutors, masked deep-link previews, all info pages (per `public_site.md`). Adds SEO surface.

---

## Phase 14 — Hardening, accessibility, i18n QA

**Goal:** Sentry wired, Playwright/integration tests, accessibility audit (44 dp targets, WCAG AA, screen-reader labels), Nepali strings reviewed by a native speaker.

---

## Phase 15 — Beta + launch

**Goal:** Closed beta in Kathmandu Valley (seeded tutors), feedback loop, then Play Store rollout. Post-launch monitoring KPIs documented (active tutors, vacancies open vs. filled, unlocks/day, top-up volume).

---

## Cross-cutting tracks (run in parallel)

- **Design system** — `core/theme` evolves through every phase as new components appear.
- **Localization** — every new feature ships with both ARB locales.
- **Privacy review** — every phase ends with a 30-min review of "did anything leak real names / phones / addresses?"
- **Code review against `CLAUDE.md`** — reuse-vs-duplicate, no hard-coded strings, no Supabase outside repos.

---

## Where to look for details

- App master plan → `docs/plan.md`
- Admin panel → `docs/admin_panel_plan.md`
- Tutor UI → `docs/tutor_UI.md`
- Student UI → `docs/student_UI.md`
- Public marketing site → `docs/public_site.md`
- Tutor code of conduct → `docs/tutor_code_of_conduct.md`
- Project conventions → `CLAUDE.md`
- Prompt history → `docs/my_prompt.md`
