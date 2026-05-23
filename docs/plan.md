# Home Tuition Nepal — Marketplace App Plan

> **App name:** **Home Tuition Nepal**
> **Publisher / brand:** **KTM academy**
> **Admin WhatsApp (initial default):** **`https://wa.me/9779807590455`** — this is the contact users reach when they tap **"Contact admin"** anywhere in the app (Help screen, splash footer, vacancy "Need help?" link, "Couldn't find a tutor?" CTA, deep-link web preview, push-notification fallbacks).
> - **This is the admin's WhatsApp, not a hard-coded marketing number.** The admin uses it to manually mediate between students and tutors when needed.
> - **It must be editable from the admin panel** — store it in a `platform_settings` (key/value) table, not hard-coded in client constants. The app reads the current value on launch (with a cached fallback for offline). When the admin updates it from the panel, all clients pick up the new number on next launch / next settings refresh.
> - **Do not** use any other WhatsApp number anywhere in the product. Sample numbers from competitor reference posts were template examples only and must never appear in the app, marketing material, code, or generated outputs.
> **Headline feature / one-line pitch:** *Search tutors in your locality.* Everything else (job posts, admin-curated vacancies, coins, reviews) is a supporting flow. The single most important user moment is opening the app and seeing qualified tutors in their own neighborhood, on a map, within seconds.
>
> All in-app branding, splash screen, Play Store / App Store listings, deep-link domain (e.g. `homenepal.app` or `htn.app`), email senders, push-notification sender names, and admin-panel header should reflect *Home Tuition Nepal* as the product name and *KTM academy* as the company. The vacancy-code prefix `HTN-NNNNN` (Home Tuition Nepal) is consistent with this branding.

## 1. Vision

A two-sided marketplace app (Flutter) that connects **students/parents** with **home tuition tutors** across Nepal. **The headline feature is "Search tutors in your locality."** The **primary experience is a live, locality-first map** — like **inDrive** for tutors: after login, a student lands directly on a map of their own neighborhood with nearby available tutors pinned, and can reach them in one or two taps. Locality search must feel **immediate, accurate, and granular** — down to the ward / chowk level (e.g., *Kapan – Faika Chowk*).

In parallel, it works **like Upwork** as a secondary flow — students post tuition jobs, tutors bid, students pick — but with **no in-app payment system**. All money changes hands **off-platform** (cash / eSewa / Khalti / bank, directly between student and tutor). The platform's only monetary mechanic is a **coin system** used internally for access (bidding, contact unlocks, boosts).

One app, two roles, **one role per account**. Users sign in once with Google, then choose at onboarding whether to enter as a **student** or a **tutor** — not both. If someone needs the other role, they sign up a second account with a different Google / phone identity.

## 2. Goals

- **Locality-first tutor search is the marquee feature.** Every other surface (job feed, vacancies, admin tools) exists to support discovery of nearby tutors. Optimize the locality search for the smallest meaningful unit in Nepal — a chowk, tole, or ward — not just a city-level filter.
- Frictionless Google Sign-In + phone OTP verification.
- **Map-first experience** (inDrive-style): after login the student lands on a live OSM map of their area showing nearby available tutors. Reach a tutor in 1–2 taps.
- Upwork-style flow as a secondary path: student posts a job → tutors bid (spending coins) → student picks → contact via phone/WhatsApp.
- **No payment system inside the app.** Tuition fees are negotiated and paid off-platform.
- **Coin system** is the only on-platform economy — used for bidding, unlocking contacts, and profile boosts. Coins can be **bought** (coin packs) and **earned** (referrals, profile completion, getting reviews).
- Phone numbers controlled by the platform — revealed only via the in-app Call / WhatsApp buttons, gated by coins.
- Built for Nepal: **fully bilingual (नेपाली / English)** — first-class language toggle, ships with both locales from day one. Works on low-end Android.

## 3. The Two Discovery Models (map-first; job-board as a complement)

> **Confirmation of feasibility (re-asserted):** The locality-first map view is **technically feasible and remains the headline feature**. It is implemented with `flutter_map` + OpenStreetMap tiles + PostGIS `ST_DWithin` viewport queries — all open, all free for our expected v1 traffic, all production-proven in Nepali geographies. **We do not pivot to a list-only experience.** The competitor screens (TeacherOn, Prosikshya, TeachMandu) shown for reference are list-first; our differentiator is precisely that we land the student on a map. List view exists as a complement (pull-up sheet, §4.3.6 of `docs/student_UI.md`), not a replacement.

### 3.1 Map view — inDrive-style (PRIMARY, default landing screen)
The map is **the** home screen for students. The moment login + onboarding finishes, the student lands here.

**Layout**
- Full-screen `flutter_map` with **OpenStreetMap** tiles.
- Camera auto-centers on the student's current location (`geolocator`); a soft blue dot marks "you".
- **Live tutor pins** within the visible viewport, color-coded:
  - Green = available right now
  - Amber = available later today / by appointment
  - Grey = offline (hidden by default; can be toggled on via filter)
  - Gold ring = verified ✓ tutor
  - Featured tutors (coin-boosted) get a slightly larger pin with a highlight glow.
- A **horizontal filter chip bar** at the top: subject • grade • price • gender • verified-only • radius (1 km / 3 km / 5 km / 10 km / custom).
- A **search field** above the chips: "Search subject, language, level…".
- A **persistent bottom sheet** (collapsible, inDrive-style) with a **horizontally swipable carousel of tutor cards** that mirror what's on the map. Each card shows:
  - Photo (rounded), masked name `Ramesh S*`, handle, verified badge.
  - Distance (`1.2 km`), rating ★, hourly rate, top 2 subjects.
  - "Available now" badge if applicable.
  - A primary action button: **Contact** (opens the unlock-coin confirm sheet).
- Tapping a card centers the map on that pin; tapping a pin scrolls the carousel to that card. They stay in sync.
- Floating action buttons (right edge): **Re-center on me**, **Toggle map/satellite**, **Filters**.
- Floating action button (bottom-left): **Post a job** → switches to the Upwork-style flow (§3.2).

**Interactions (inDrive parallels)**
- **Drag-to-explore**: when the camera moves, re-query tutors in the new viewport (debounced ~400 ms).
- **Pinch zoom** adjusts the implicit radius; the radius chip auto-updates.
- **Long-press on the map** drops a custom pin (e.g., "tutors near my school, not my home"); the carousel updates around that point. The student keeps their actual location private from tutors.
- **Pull-up bottom sheet** to expand into a full list view sorted by distance / rating / price.
- **Real-time updates**: Supabase Realtime channel pushes tutor `available` toggles and location changes; pins animate in/out without a refresh.
- **Empty state**: if no tutors match within the chosen radius, show a friendly empty card with two CTAs — *Expand radius* and *Post a job instead*.

**One- or two-tap contact**
1. Student taps **Contact** on a card or pin.
2. A bottom-sheet shows tutor preview + coin cost ("Unlock contact for 10 coins").
3. Student confirms → server debits coins, returns phone → Call / WhatsApp buttons appear.
4. They contact off-platform.

**Privacy on the map**
- Tutors' pins are shown at their **declared service base**, not real-time GPS. We never expose live tutor location.
- For students, the map *centers* on their location but their pin is never visible to anyone else.
- Optional **jitter** (50–100 m) is applied to tutor pins so their exact home isn't pinpointable from the map.
- Masked names (`Ramesh S*`) everywhere — see §5.5.

### 3.2 Job board — Upwork-style (SECONDARY)
Reachable from the map FAB ("Post a job") or from the bottom-tab on the student dashboard.
1. Student creates a **Job Post**: subject, grade, location, schedule, budget range, in-person/online, requirements.
2. Job appears in tutors' feed, filtered by their subjects/location/radius.
3. Tutors **spend coins** to submit a **Bid/Proposal**: cover note, proposed rate, availability.
4. Student reviews bids, shortlists, **spends coins to unlock contact** of chosen tutor(s).
5. They contact off-platform (phone/WhatsApp), agree, and pay each other directly — outside the app.
6. After the engagement, student can **leave a review**; tutor earns coins for receiving a review.

### 3.3 Admin-curated vacancies — broker model (TERTIARY)
This mirrors how existing Nepali tuition agencies (Gurukul Home Tuitions, Tuition Guru, Tuition Serve, etc.) operate today: a central admin collects a parent's requirement, posts it as a **Vacancy**, and tutors apply. The admin then matches the best tutor to the parent.

The app supports this natively so the operators of this platform can run the same broker workflow inside the app — replacing the WhatsApp/CV-screenshot loop visible in the reference posts.

**Vacancy fields (structured — match the format used by competing brokers in Nepal):**
- **Vacancy code** — auto-generated, human-friendly, monotonically increasing (e.g., `HTN-00276`). Used in WhatsApp/social posts, deep links, and admin queries.
- **Title / heading** — short summary line (e.g., *"Vacancy For Home Tuition Teacher — Kapan"*).
- **Location** — area + optional landmark (e.g., *"Kapan, Faika Chowk"*, *"Balkot, near Boys Futsal"*); geog point.
- **Number of students** — integer, default 1 (per real-world posts like *"No. of student: 1"*).
- **Class / Grade** (e.g., *Class 11 (A Level)*, *Class 7*, *Grade 10*).
- **Subject(s)** — multi-select (e.g., *Physics & Maths*, *All*, *Maths, Science, guidance in other*).
- **Duration / Time** — preferred slot, free-form (e.g., *7:45 PM – 8:45 PM*, *5pm–6pm*, *evening*). Stored as text; optional structured `start_time` / `end_time` for filtering.
- **Frequency** — per-month / per-week / one-off (default per-month).
- **Salary** — fixed (`16K`, *"Rs 8.5k Per Month"*) or range (`4,000–5,000`); stored as min/max NPR + a `period` (`month` / `hour` / `session`).
- **Gender preference** — Any / Male / Female (labeled *"Tutor: Male Only"* etc. in the UI).
- **Mode** — In-person / Online / Either.
- **Notes / requirements** — free-text constraints (e.g., *"Only Nearby location & experienced School teachers are requested to apply"*). Same phone-number ban as §5.6.
- **Status** — `open` / `applications_closed` / `filled` / `cancelled`.
- **Posted by** — admin user (always).
- **Linked student** — optional reference to a `profiles` row (when the student originally requested via the app; admins can also create vacancies on behalf of off-app parents).

**Flow (tutor side):**
1. Tutor opens the **Vacancies** tab → list ordered by recency, filterable by area / class / subject / salary / gender.
2. Each card looks like the competitor posts (location, class, subject, time, salary, gender, vac no).
3. Tutor taps **Apply** → upload CV (PDF/image), short cover note, optional expected rate. **Free** for the first N applications per month, then coin-gated to discourage spam.
4. Admin reviews applications in the admin panel, shortlists, contacts the student off-platform (the admin already has both phones), then notifies the chosen tutor in-app.
5. Tutor accepts → admin reveals student's contact to that one tutor (or vice versa).

**Flow (student side):**
- Student requests a tutor → fills a short form → it becomes a draft vacancy that the admin reviews, normalizes, assigns a code, and publishes. Student gets a notification with the vacancy code so they can quote it later.

**Sharing:**
- Every vacancy is publicly shareable via a deep link (`htn.app/v/HTN-00276`) — opens the app if installed, else a web preview with a "Open in App" button. The web preview shows the masked summary only; applying requires login.

All three flows converge on the **contact unlock / contact reveal** step — that's the coin/admin-gated sink.

## 4. Coin System (only on-platform economy)

### 4.1 What coins are spent on
All costs below are **default values stored in `platform_settings` and editable from the admin panel** — the app reads the current values on launch (no app release required to change pricing).

| Action | Who pays | Default cost | `platform_settings` key | Notes |
|---|---|---|---|---|
| **Apply to a job / vacancy / submit a bid** | Tutor | **1 coin** | `apply_coin_cost` | Single flat cost for every kind of tutor application — student-posted jobs, admin-curated vacancies, bid submissions. Refunded if the job/vacancy is cancelled or expires un-hired. |
| Unlock contact (phone/WhatsApp) | Student | 5 coins | `unlock_coin_cost` | One-time per tutor; never charged twice for the same tutor |
| Featured listing (24h) | Tutor | 50 coins | `featured_listing_cost` | Pin appears highlighted on map + top of feed |
| Pin to top of bids | Tutor | 20 coins | `pinned_bid_cost` | Bid sorted above un-boosted bids |
| Promote job post | Student | 20 coins | `promoted_job_cost` | Job appears at top of tutors' feed |

### 4.2 How coins are earned (free)
| Action | Coins | Cap |
|---|---|---|
| Complete profile (photo + bio + verified phone) | 20 | once |
| Verify ID (citizenship/license) | 50 | once |
| Refer a friend who completes signup | 30 | unlimited |
| Receive a 4★+ review (tutor) | 10 | unlimited |
| Leave a review (student) | 5 | one per engagement |
| Daily check-in | 1 | once per day |

### 4.3 How coins are bought
- Coin packs (e.g., 100 / 500 / 2000 coins) purchased via **eSewa / Khalti / IME Pay** (Nepal-local payment processors) or in-app billing.
- *This is the only money flowing through the platform — and it's for coins, not for tuition.*

### 4.4 Wallet rules
- One wallet per user. Each account has a single role (student **or** tutor), so coin sinks are role-specific (students spend on unlocks; tutors spend on bids/boosts).
- Coins never expire.
- Coins are non-refundable to fiat (per ToS).
- Server-side ledger (append-only) for every credit/debit. No client-side balance trust.

## 5. Core User Flows

### 5.1 Onboarding (shared)

**Primary path — Email + Password registration (the "Create your account" form):**
A single registration form is used for both roles. Fields, in order:
1. **First name** (required, ≤ 40 chars).
2. **Last name** (required, ≤ 40 chars; combined with first name forms the private `real_name`; the public masked form is `Firstname L*`).
3. **Email address** (required, validated; becomes the primary login identifier).
4. **Phone number** (required; country code locked to `+977`; 10-digit input; will be OTP-verified before the account is usable).
5. **Password** (required; min 8 chars, at least one letter + one digit; strength meter shown).
6. **Confirm password** (required; must match Password).
7. **Role** — radio with two large options: **I'm a tutor** · **I'm a student**. Exactly one. **Permanent for the account** — once registered, the role cannot be changed in-app; users wanting the other role must register a separate account (server-enforced: `profiles.role` is immutable after first set).
8. **"I accept Terms of Service & Privacy Policy"** — required checkbox. Tutors additionally see and must accept the **Tutors' Code of Conduct** (see `docs/tutor_code_of_conduct.md`) before the Register button enables.
9. **Register** button — disabled until all required fields are valid and ToS is accepted.

On submit:
- Supabase Auth user is created (`email` + `password`).
- A `profiles` row is inserted with `first_name`, `last_name`, `email`, `phone`, `role`. Handle (e.g., `Tutor #A4F7`) auto-generated server-side.
- A **6-digit OTP** is sent to the phone via the SMS provider (Twilio / MessageBird / Vonage); the user is taken to a Phone-OTP-verification screen. `phone_verified` flips to `true` on success. Until verified, the account exists but cannot post jobs, apply, or unlock contacts.

**Alternative path — Google Sign-In:**
Google Sign-In remains available as a one-tap alternative on the login / register screen. When used, the flow short-circuits steps 3 and 5–6 (email and password are taken from Google), but the user still must:
- Choose role (Student / Tutor) on a follow-up screen — permanent.
- Enter and OTP-verify a phone number.
- Accept ToS (and Tutors' Code of Conduct for tutors).

**Schema impact:**
```sql
ALTER TABLE profiles
  ADD COLUMN first_name text not null,
  ADD COLUMN last_name  text not null,
  ADD COLUMN tos_accepted_at        timestamptz,
  ADD COLUMN code_of_conduct_accepted_at timestamptz;     -- tutors only; null for students
-- real_name continues to be derived as first_name || ' ' || last_name (PRIVATE)
-- masked public form is first_name || ' ' || left(last_name, 1) || '*'
```

**After registration & OTP verification, both roles continue with:**
- Profile setup (photo, gender, DOB).
- Location permission → `geolocator` captures lat/lng; reverse-geocode for display.
- Role-specific onboarding wizards (see `docs/tutor_UI.md` §4.2 and `docs/student_UI.md` §4.2).
- **Initial coin grant: +1000 coins** credited on onboarding completion (editable from the admin panel via `platform_settings.signup_coin_grant`; changes apply prospectively to new accounts).

### 5.2 Tutor flow
- Build tutor profile: subjects, grade levels, languages, hourly rate, bio, qualifications, optional ID doc → verified badge.
- Set service area (home base + radius in km) and availability windows.
- Toggle Available / Not available — controls map visibility.
- **Jobs feed**: see student job posts that match. Spend coins to bid.
- **My bids**: track pending / shortlisted / hired / rejected.
- **My profile views & contacts**: see who unlocked your contact.
- Wallet: balance, history, buy coins, claim earned coins.

### 5.3 Student flow
- **Post a Job**: subject, grade, location (auto from geolocator + manual override), schedule, budget, requirements. Free to post.
- **My Jobs**: list of own jobs with bid counts.
- **Bids inbox**: tutor proposals per job; shortlist, unlock contact (spend coins).
- **Map**: alternative discovery; spend coins to unlock contacts directly.
- **Reviews**: after the engagement, leave a star + text review.
- Wallet: balance, history, buy coins.

### 5.4 Contact bridge (the platform's only "transaction")
- All phone numbers stored server-side; never exposed in API responses until unlock.
- On unlock: server checks balance → debits coins → logs unlock event → returns number to client. Call/WhatsApp launchers use `tel:` and `https://wa.me/<num>` (`url_launcher`).
- Rate-limit unlocks per user per day to prevent abuse.

### 5.5 Identity privacy (names hidden from outside the platform)
**Real names are never exposed publicly.** They are only visible to other authenticated users *inside the app*, and only after the appropriate gating step.

**Name-masking rule (Upwork-style):**
- Inside the app, other users see only **first name + first letter of surname + asterisk**.
  Examples: `Ramesh S*`, `Sita K*`, `John D*`.
- Server-side derives `maskedName = firstName + " " + surname[0] + "*"` and returns **only** that in any list/feed/profile-preview response.
- The full real name is **never** sent to clients except in two narrow cases:
  - To the **tutor themselves** (their own profile).
  - To the **counterparty after a successful, paid contact unlock** (so the student knows who they're calling).
- Profile slugs, URLs, and OG metadata use the **handle** (e.g., `Tutor #A4F7`), never the real name.
- `robots.txt` + meta `noindex` on every web surface; admin panel behind auth; no public profile URLs.
- Postgres Row Level Security (RLS) treats `real_name`, `phone`, `id_docs`, exact address as restricted columns, readable only by the owner; counterparties get them only via `security definer` RPC after a paid unlock or shortlist.
- Search engines and crawlers must not be able to index a tutor's real name.

### 5.6 Content moderation — no phone numbers in free-text fields
To prevent users from bypassing the coin-gated contact-unlock funnel, **all free-text fields** (job descriptions, bid cover notes, tutor bio, reviews, profile blurb) are scanned for phone numbers, email addresses, and other contact identifiers.

**UI behavior (client-side):**
- Below every free-text input, show a persistent warning note:
  > **⚠️ Do not include phone numbers, WhatsApp links, email addresses, or external contact details in this field. Your account will be blocked if any are detected. Use the in-app contact unlock instead.**
- Live regex validation as the user types. If a number pattern is detected, **disable the submit button** and highlight the offending text in red with the message: *"Phone numbers are not allowed here."*

**Server-side enforcement (authoritative):**
- Implemented as a Postgres `BEFORE INSERT/UPDATE` trigger (or a Supabase Edge Function called from the client; the trigger is the authoritative belt-and-suspenders) on `jobs.description`, `bids.cover_note`, `reviews.text`, `tutors.bio`, `profiles.about`.
- Regex + heuristics catch:
  - Bare numbers (`98XXXXXXXX`, `9779XXXXXXXX`, `+977...`).
  - Spaced / dashed / dotted formats (`98 12 345 678`, `98-12-345`, `9.8.1.2`).
  - Words spelled in numbers ("nine eight seven...").
  - Common obfuscations (`o` for `0`, `l` for `1`, spaces between digits).
  - Email addresses, `wa.me/`, `t.me/`, `viber.me/`, social handles with contact intent.
- On detection:
  - **First offense**: reject write, send in-app warning, log to `moderation/{uid}`.
  - **Second offense**: 7-day suspension (cannot bid, cannot unlock, cannot post jobs).
  - **Third offense**: permanent ban; coin balance forfeited per ToS.
- Admin can review/override from the admin panel; appeals flow logged in `moderation_log`.

### 5.6a Automatic notifications on job / vacancy post
The moment a student posts a job (or a vacancy is published by the admin), a notification is **automatically delivered** to every matching tutor. This is what the user sees as a *"New job posted"* card in the Notifications screen and as an OS-level banner on their device.

**End-to-end mechanism:**
1. **DB trigger.** A Postgres `AFTER INSERT` trigger on `jobs` (and on `vacancies` when `status` flips to `'open'`) calls a `notify_matching_tutors(job_id | vacancy_id)` Edge Function via `pg_net`.
2. **Match query (server-side).** The Edge Function selects every tutor `T` such that:
   - `T.role = 'tutor'` and `T.phone_verified = true` and not suspended.
   - `T.levels_taught[]` contains the job's level OR the job has no level.
   - `T.subjects[]` intersects the job's subject(s) OR the job has no subject.
   - `T.teaching_mode` is compatible with the job's `mode`.
   - If the job is in-person: `ST_DWithin(T.geog, job.geog, T.service_radius_km * 1000)`.
   - Optional gender pref: `T.gender = job.gender_pref` or `job.gender_pref = 'any'`.
3. **Persist + fan out.** For each matched tutor, insert a `notifications` row (`kind = 'new_job_posted'`) and enqueue a push via OneSignal / FCM.
4. **On device — Flutter app.**
   - If the app is **foreground**, the new notification streams via Supabase Realtime on the `notifications` table; the in-app Notifications screen prepends a new card with a soft haptic.
   - If the app is **background or terminated**, the OS push arrives; we hand it to `flutter_local_notifications` so it appears as a system-tray notification with the same title/body. Tapping it deep-links into the job/vacancy detail screen.
5. **Rate / spam guards.** Per-tutor cap: at most one notification per matching job (deduped by `ref_id`); per-tutor hourly cap of N (default 20, in `platform_settings.notif_hourly_cap`) to prevent flooding.
6. **Quiet hours.** Each tutor can set quiet hours in Profile → Notifications; pushes during quiet hours are suppressed (the `notifications` row still lands so the in-app feed is complete).
7. **Localization.** Notification body is generated server-side per the tutor's `profiles.language` from a template (`new_job_posted.title_ne`, `new_job_posted.title_en`).

**Flutter packages:**
- `firebase_messaging` (or `onesignal_flutter`) — remote push reception.
- `flutter_local_notifications` — on-device presentation, channel setup, deep-link routing.
- `supabase_flutter` Realtime — foreground feed sync.

### 5.7 Localization — Nepali & English (bilingual)
The app ships with **two equally-supported languages: नेपाली (Nepali) and English**. Neither is a translation afterthought; both are first-class from day one.

**Language selection:**
- On first launch, the language picker is shown **before** Google Sign-In, with two large buttons (`नेपाली` / `English`). Choice is stored locally and on the server (`profiles.language`).
- A language toggle is permanently available in Settings and on a small chip in the app bar of the splash / login screens.
- The picker defaults to **Nepali** for users whose device locale is `ne-NP`; otherwise English.

**Coverage — what must be translated:**
- 100 % of UI strings (Flutter `intl` ARB files: `app_en.arb`, `app_ne.arb`).
- All system-generated text: validation messages, error toasts, push-notification bodies, in-app banners.
- Onboarding, role pick, profile fields, map filter labels, vacancy fields, coin-system labels, wallet, reviews, admin-facing notifications, deep-link web preview.
- Vacancy free-text fields (notes, descriptions) are user-entered and **not** auto-translated — the user writes in either language and the text is rendered as-is. UI labels around it are always localized.
- Currency / numbers use the same numerals across both locales for clarity (`Rs. 8,500`), but date and time formatting follow each locale's conventions.

**Implementation:**
- Flutter built-in `flutter_localizations` + `intl` package with `.arb` files.
- `MaterialApp.supportedLocales: [Locale('en'), Locale('ne')]` and `MaterialApp.locale` bound to BLoC (`LocaleCubit`).
- All hard-coded strings go through `AppLocalizations.of(context).<key>` — lint rule (`avoid_hardcoded_strings`) and CI check to prevent regressions.
- Nepali strings reviewed by a native speaker before merge.
- Fonts: bundle a Devanagari-capable font (e.g., **Noto Sans Devanagari**) alongside the default Latin font; ensure both render at all sizes.
- RTL is **not** required (Nepali is LTR).

**Server / admin side:**
- Push-notification templates stored per-locale in the admin panel; the dispatcher picks the right one based on `profiles.language`.
- Admin panel itself is English-only in v1 (operators are bilingual; user-facing text needs both).

**Schema impact:**
```sql
ALTER TABLE profiles ADD COLUMN language text check (language in ('en','ne')) default 'ne';
```

## 6. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| App | **Flutter** (existing project) | Single codebase, Android + iOS |
| Auth | **Supabase Auth** (`supabase_flutter`) | Google OAuth + Phone OTP (Twilio/MessageBird/Vonage as SMS provider) |
| Backend / DB | **Supabase Postgres** | Real-time job feed, bids, wallet via Supabase Realtime channels |
| Server logic | **Supabase Edge Functions** (Deno/TypeScript) | Wallet ledger, coin debits, contact unlocks, fraud checks, content moderation |
| Storage | **Supabase Storage** | Photos, ID uploads (signed URLs only; never public buckets for ID docs) |
| Access control | **Postgres Row Level Security (RLS)** | Replaces Firestore Security Rules; restricts `real_name`, `phone`, `id_docs` to owner + matched counterparty |
| Maps | **OpenStreetMap** via `flutter_map` | Free tiles in dev; Stadia/Mapbox in prod |
| Location | `geolocator` + `geocoding` | Permissions + reverse geocoding |
| Geo-queries | **PostGIS** (`geography` column + `ST_DWithin`) | Native radius queries in Postgres; fallback geohash column for client filtering |
| Contact launchers | `url_launcher` | `tel:` and `wa.me` |
| State mgmt | **`flutter_bloc` (BLoC pattern)** | Standardize on BLoC/Cubit across the app — events, states, repositories injected via `get_it` |
| Push | **OneSignal** or **FCM directly** | Supabase has no push service; trigger from Edge Functions |
| Coin top-up | **eSewa / Khalti / IME Pay SDKs** | Nepal-local; only money flow into the platform; verified via Edge Function webhook |
| Admin panel | **Next.js + TypeScript (App Router), event-driven clean architecture** | Separate codebase, built later. Mediates teacher↔student matching, manages vacancies, verification, phone-number control, coin audits, moderation queue. See §7b. |

## 7. Data Model (Supabase Postgres)

All tables protected by **Row Level Security (RLS)** policies. Private columns (`real_name`, `phone`, `id_docs`, exact address) are excluded from `select` policies for non-owner readers and re-exposed only via `security definer` RPC functions that check the unlock/shortlist condition.

```sql
-- profiles: 1:1 with auth.users
profiles (
  id              uuid primary key references auth.users(id),
  handle          text unique not null,        -- PUBLIC, e.g. "Tutor #A4F7"
  real_name       text not null,               -- PRIVATE (RLS-restricted)
  photo_url       text,
  email           text,                        -- PRIVATE
  phone           text,                        -- PRIVATE; E.164
  phone_verified  bool default false,
  role            text not null check (role in ('student','tutor')),  -- exactly one; immutable after first set (enforced by trigger)
  area_label      text,                        -- PUBLIC coarse label, e.g. "Baneshwor"
  exact_address   text,                        -- PRIVATE
  student_level   text check (student_level in ('below_class_9','see','plus_2','a_level')),  -- PUBLIC; set for student-role accounts at onboarding; nullable for tutors
  geog            geography(Point, 4326),      -- PostGIS, for radius queries
  geohash         text,
  coin_balance    integer default 0,           -- mirror of authoritative ledger sum
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
)

-- Canonical student-level taxonomy used everywhere a level is mentioned
-- (tutor profile, student profile, map filter, vacancy, job).
-- Values: 'below_class_9', 'see', 'plus_2', 'a_level'
-- Display labels (localized): "Below Class 9" / "SEE" / "+2" / "A Level"

tutors (
  id                  uuid primary key references profiles(id),
  subjects            text[],                 -- denormalized convenience list; authoritative source is tutor_offerings
  grade_levels        text[],                 -- free-form grade detail (e.g., 'Class 7', 'Grade 10')
  levels_taught       text[] not null,        -- subset of the canonical taxonomy; derived from tutor_offerings.level
  languages           text[],
  base_rate_npr       numeric,                -- 'from' rate shown on cards; authoritative per-level pricing in tutor_offerings
  about_me            text,                   -- "ABOUT ME" section — bio / background
  about_sessions      text,                   -- "ABOUT MY SESSIONS" section — teaching methodology
  qualifications      text,                   -- "QUALIFICATIONS" section — degrees, certifications, institutions
  teaching_mode       text not null check (teaching_mode in ('online','offline','both')) default 'offline',
                                              -- chosen at tutor profile setup.
                                              -- online-only tutors are NOT pinned on the map but appear in list + search.
                                              -- offline / both tutors are pinned on the map at their service base.
  tagline             text,                   -- one-line headline, e.g. "Pulchowk Campus Engineering Graduate"
  meta_keywords       text[],                 -- search keywords for SEO/in-app search
  country             text default 'Nepal',
  zone                text,                   -- 'Bagmati'
  city                text,                   -- 'Lalitpur'
  address_line        text,                   -- 'Kupandole' — coarse address; never publicly shown
  native_language     text,                   -- single, e.g. 'Nepali'
  languages_known     text[],                 -- multi: ['English','Hindi','Nepali']
  draft_status        text check (draft_status in ('draft','published')) default 'draft',
  profile_completion  smallint default 0,     -- 0–100, computed server-side from required-field coverage
  experience_offline_years numeric default 0, -- TeacherOn-style: years of in-person tuition experience
  experience_online_years  numeric default 0, -- years of online teaching experience
  premium_until            timestamptz,        -- if non-null and > now(), tutor has premium membership (boosted ranking)
  ranking_score            numeric default 0   -- computed nightly: weighted (rating, reviews, completion, verification, premium, recency)
  service_radius_km   numeric,
  available           bool default false,
  rating              numeric,
  rating_count        integer default 0,
  verified            bool default false,
  featured_until      timestamptz
)

-- Subjects offered table — authoritative per (level, subject, price) for each tutor.
-- Mirrors the "Subjects Offered" grid on the tutor profile (Level / Subject / Price).
-- TeacherOn-style flexible pricing: tutors can quote per-hour, per-day, or per-month,
-- and can quote a range (price_min..price_max) instead of a single number.
tutor_offerings (
  id              uuid primary key default gen_random_uuid(),
  tutor_id        uuid references profiles(id) on delete cascade,
  level           text not null check (level in ('below_class_9','see','plus_2','a_level')),
  subject         text not null,
  price_min_npr   numeric not null,
  price_max_npr   numeric,                       -- null = single price (== price_min_npr)
  price_period    text not null check (price_period in ('hour','day','month','session')) default 'month',
  unique (tutor_id, level, subject)
)

-- Tutor education / experience / certificates — all OPTIONAL.
-- Each is its own table because tutors typically have multiple entries.
tutor_education (
  id              uuid primary key default gen_random_uuid(),
  tutor_id        uuid references profiles(id) on delete cascade,
  degree          text,                       -- 'Bachelor in ECE'
  institution     text,                       -- 'Pulchowk Campus'
  field_of_study  text,
  start_year      smallint,
  end_year        smallint,                   -- null = ongoing
  description     text,
  sort_order      smallint default 0
)

tutor_experience (
  id              uuid primary key default gen_random_uuid(),
  tutor_id        uuid references profiles(id) on delete cascade,
  role_title      text,                       -- 'Math Tutor'
  organization    text,
  start_year      smallint,
  end_year        smallint,
  description     text,
  sort_order      smallint default 0
)

tutor_certificates (
  id              uuid primary key default gen_random_uuid(),
  tutor_id        uuid references profiles(id) on delete cascade,
  title           text,
  issuer          text,
  year_awarded    smallint,
  file_path       text,                       -- supabase storage object (private, signed-URL)
  sort_order      smallint default 0
)

-- Weekly availability grid — 3 time-bands × 7 days.
-- Bands: 'pre_10am' (☀️ early), '10_5pm' (☼ midday), 'after_5pm' (🌅 evening).
-- Days are encoded as a JSONB map of weekday → bool. Single row per tutor.
tutor_availability (
  tutor_id    uuid primary key references profiles(id) on delete cascade,
  -- shape:
  -- {
  --   "pre_10am":  {"sun": true,  "mon": false, "tue": false, "wed": false, "thu": false, "fri": false, "sat": true},
  --   "10_5pm":    {"sun": true,  "mon": true,  "tue": true,  "wed": true,  "thu": true,  "fri": true,  "sat": true},
  --   "after_5pm": {"sun": true,  "mon": true,  "tue": true,  "wed": true,  "thu": true,  "fri": true,  "sat": false}
  -- }
  slots       jsonb not null default '{}'::jsonb,
  updated_at  timestamptz default now()
)

jobs (
  id              uuid primary key default gen_random_uuid(),
  student_id      uuid references profiles(id),
  job_type        text not null check (job_type in ('home_tuition','online_tuition','assignment_help')) default 'home_tuition',
  subject         text,
  grade_level     text,                       -- 'Grade 7', 'Class 11', etc.
  geog            geography(Point, 4326),
  area_label      text,
  schedule        text,
  engagement_type text check (engagement_type in ('full_time','part_time','one_off')),
  due_date        date,                        -- relevant for assignment_help
  budget_min_npr  numeric,
  budget_max_npr  numeric,                     -- null = single fixed price
  budget_period   text check (budget_period in ('hour','day','month','session','fixed')) default 'month',
  mode            text check (mode in ('in-person','online','either')),
  gender_pref     text check (gender_pref in ('any','male','female')) default 'any',
  communicate_languages text[],                -- languages the student can communicate in
  can_travel      bool default true,           -- whether tutor needs to travel to student
  status          text check (status in ('open','shortlisting','hired','closed','expired')),
  promoted_until  timestamptz,
  created_at      timestamptz default now()
)

bids (
  id                  uuid primary key default gen_random_uuid(),
  job_id              uuid references jobs(id),
  tutor_id            uuid references profiles(id),
  cover_note          text,
  proposed_rate_npr   numeric,
  status              text check (status in ('pending','shortlisted','hired','rejected')),
  pinned              bool default false,
  coins_spent         integer,
  created_at          timestamptz default now()
)

contact_unlocks (
  id            uuid primary key default gen_random_uuid(),
  student_id    uuid references profiles(id),
  tutor_id      uuid references profiles(id),
  channel       text check (channel in ('call','whatsapp')),
  job_id        uuid references jobs(id),   -- null if unlocked from map
  coins_spent   integer,
  ts            timestamptz default now()
)

reviews (
  id          uuid primary key default gen_random_uuid(),
  tutor_id    uuid references profiles(id),
  student_id  uuid references profiles(id),
  job_id      uuid references jobs(id),
  stars       smallint check (stars between 1 and 5),
  text        text,
  ts          timestamptz default now()
)

-- append-only wallet ledger
wallet_ledger (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references profiles(id),
  delta           integer not null,
  reason          text check (reason in ('bid','unlock','boost','topup','reward','refund','admin')),
  ref_id          uuid,
  balance_after   integer not null,
  ts              timestamptz default now()
)

vacancies (
  id              uuid primary key default gen_random_uuid(),
  code            text unique not null,            -- 'HTN-00276', auto-generated
  title           text,                            -- 'Vacancy For Home Tuition Teacher — Kapan'
  posted_by_admin uuid references admin_users(id),
  linked_student  uuid references profiles(id),    -- nullable; vacancy may be on behalf of an off-app parent
  area_label      text not null,                   -- 'Kapan, Faika Chowk'
  geog            geography(Point, 4326),
  num_students    integer default 1,
  grade           text,                            -- 'Class 11 (A Level)'
  subjects        text[],                          -- ['Physics','Maths']
  duration_text   text,                            -- '7:45 PM – 8:45 PM' or 'evening'
  start_time      time,                            -- optional structured time for filtering
  end_time        time,
  frequency       text check (frequency in ('per_month','per_week','one_off')) default 'per_month',
  salary_min_npr  numeric,
  salary_max_npr  numeric,
  salary_period   text check (salary_period in ('month','hour','session')) default 'month',
  gender_pref     text check (gender_pref in ('any','male','female')),
  mode            text check (mode in ('in-person','online','either')),
  notes           text,                            -- 'Only Nearby location & experienced School teachers...'
  status          text check (status in ('open','applications_closed','filled','cancelled')),
  filled_by_tutor uuid references profiles(id),
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
)

vacancy_applications (
  id              uuid primary key default gen_random_uuid(),
  vacancy_id      uuid references vacancies(id),
  tutor_id        uuid references profiles(id),
  cover_note      text,
  expected_rate   numeric,
  cv_storage_path text,                            -- supabase storage object
  status          text check (status in ('pending','shortlisted','rejected','hired')),
  coins_spent     integer default 0,
  created_at      timestamptz default now()
)

admin_users (
  id          uuid primary key references auth.users(id),
  role        text check (role in ('superadmin','operator','moderator')),
  created_at  timestamptz default now()
)

-- Admin-editable runtime settings (e.g. admin WhatsApp number, coin prices, feature flags).
-- Clients read these on launch with a cached fallback.
platform_settings (
  key         text primary key,           -- 'admin_whatsapp', 'bid_coin_cost', 'unlock_coin_cost', ...
  value       text,
  updated_by  uuid references admin_users(id),
  updated_at  timestamptz default now()
)
-- Seed values:
-- ('admin_whatsapp',         'https://wa.me/9779807590455')
-- ('signup_coin_grant',      '1000')   -- coins credited on new account
-- ('apply_coin_cost',        '1')      -- coins to apply / bid / submit a proposal
-- ('unlock_coin_cost',       '5')      -- coins for a student to reveal a tutor's contact
-- ('featured_listing_cost',  '50')
-- ('pinned_bid_cost',        '20')
-- ('promoted_job_cost',      '20')

-- In-app chat between matched parties. Activated AFTER one of:
--   (a) student unlocks the tutor's contact (paid via coin), or
--   (b) admin assigns the tutor to a vacancy.
-- Until one of these gates fires, no chat can exist between the pair.
chat_threads (
  id              uuid primary key default gen_random_uuid(),
  student_id      uuid references profiles(id),
  tutor_id        uuid references profiles(id),
  job_id          uuid references jobs(id),
  vacancy_id      uuid references vacancies(id),
  opened_via      text check (opened_via in ('contact_unlock','admin_assignment')),
  last_message_at timestamptz,
  unique (student_id, tutor_id, job_id, vacancy_id)
)

chat_messages (
  id          uuid primary key default gen_random_uuid(),
  thread_id   uuid references chat_threads(id) on delete cascade,
  sender_id   uuid references profiles(id),
  body        text not null,                   -- phone-ban applied via the same trigger as other free-text fields
  sent_at     timestamptz default now(),
  read_at     timestamptz                       -- null until counterparty reads → drives the double-tick UI
)

-- App-wide notification feed (used by the in-app Notifications screen + dispatched as push).
notifications (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references profiles(id),
  kind        text not null,                    -- 'new_job_posted', 'application_shortlisted', 'identity_verification_approved', ...
  title       text not null,                    -- localized via title_key (server formats per profiles.language)
  body        text,
  ref_type    text,                             -- 'job' | 'vacancy' | 'application' | ...
  ref_id      uuid,
  read_at     timestamptz,
  created_at  timestamptz default now()
)

moderation_log (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references profiles(id),
  field       text,           -- 'job.description', 'bid.cover_note', etc.
  reason      text,           -- 'phone_in_text', 'email_in_text', ...
  excerpt     text,
  action      text,           -- 'reject', 'warn', 'suspend', 'ban'
  ts          timestamptz default now()
)
```

**Key RPC functions** (Edge Functions or `security definer` SQL):
- `spend_coins_and_bid(job_id, cover_note, rate)` — atomic debit + insert into `bids`.
- `unlock_contact(tutor_id, channel, job_id?)` — atomic debit + insert + return `phone`.
- `reveal_real_name(other_user_id)` — returns `real_name` only if a successful unlock or shortlist exists.
- `apply_to_vacancy(vacancy_id, cover_note, expected_rate, cv_path)` — atomic free/coin-gated apply.
- `admin_assign_vacancy(vacancy_id, tutor_id)` — admin-only; sets vacancy `filled_by_tutor` + flips application status.

## 7a. Public IDs & Deep Links

Every entity that users may share gets a **short, human-friendly public code** (separate from its internal UUID). Codes are stable, URL-safe, and case-insensitive.

| Entity | Code format | Example | Deep link |
|---|---|---|---|
| Tutor profile | `T-XXXXXX` (6 base32) | `T-A4F7QK` | `htn.app/t/T-A4F7QK` |
| Student profile | `S-XXXXXX` | `S-9BG2HM` | `htn.app/s/S-9BG2HM` |
| Vacancy | `HTN-NNNNN` (zero-padded sequence) | `HTN-00276` | `htn.app/v/HTN-00276` |
| Job post | `J-XXXXXX` | `J-7K3PWE` | `htn.app/j/J-7K3PWE` |

**Rules:**
- Public codes are immutable once assigned; UUIDs remain the internal foreign-key identifier.
- Deep links open the app if installed (Android App Links + iOS Universal Links); otherwise a minimal web preview is shown.
- Web preview shows only **masked** info: handle, masked name (`Ramesh S*`), area label, subjects, rating, vacancy details where applicable. **Never** the real name, full address, or phone number.
- Applying / contacting from a deep link requires login.
- An authenticated tutor can copy/share their own profile link from settings; same for students. Admins can copy any vacancy link from the admin panel.

## 7b. Admin Panel (separate Next.js + TypeScript app)

The admin panel is built **later** as a separate codebase (Next.js + TypeScript, App Router) using **event-driven clean architecture** and authenticated access. It is the only way to create/manage vacancies, verify users, audit the coin ledger, run moderation queues, and broker tutor↔student matches.

**Architecture (high-level):**
- **Layers:**
  - `domain/` — pure entities, value objects, domain events (`VacancyCreated`, `ApplicationShortlisted`, `TutorVerified`, `CoinsRefunded`, `ContactRevealed`), and domain services. No framework imports.
  - `application/` — use-cases / interactors (`CreateVacancy`, `AssignTutorToVacancy`, `RefundCoins`, `BanUser`), each accepting input DTOs and emitting domain events.
  - `infrastructure/` — Supabase client adapter, storage adapter, payment-webhook adapter, notification adapter, event bus (in-process for v1; later Postgres `LISTEN/NOTIFY` or NATS).
  - `interface/` — Next.js route handlers, server actions, RSC pages; thin — they only assemble use-cases.
- **Event-driven:**
  - Every state-changing use-case emits one or more domain events.
  - Side effects (push notifications, audit log, coin refunds, analytics) are subscribers, not direct calls. Keeps use-cases pure and testable.
  - Events are persisted to an `audit_events` table for replay/forensics.
- **Auth:** Supabase Auth with admin-only sign-in (email + TOTP). `admin_users.role` (`superadmin` / `operator` / `moderator`) gates each route. Server-side checks on every action.
- **Capabilities:**
  - Create / edit / close vacancies; auto-generate codes.
  - Review applications, shortlist, assign tutor → triggers contact reveal to both sides.
  - Verify tutor IDs (citizenship, certificates).
  - Review moderation flags (phone-in-text, abuse reports); ban / suspend.
  - Coin ledger audit; manual credits/refunds (with mandatory reason → audit event).
  - Phone-number control: lookup, mask preview, suspend numbers.
  - Search by public code (`HTN-00276`, `T-A4F7QK`, etc.).
  - Analytics dashboards (vacancies open vs. filled, contact unlocks per day, top areas, etc.).
- **Testing:** use-cases unit-tested without Supabase via in-memory adapters; integration tests against a Supabase preview project.

## 8. Screens (MVP)

1. Splash / auth gate
2. Google Sign-In
3. Phone OTP verification
4. Profile setup → location permission → role pick
5. **Map home (inDrive-style, default landing for students)** — full-screen map, filter chips, search, swipable tutor-card carousel in a collapsible bottom sheet, real-time pin updates, recenter/filter FABs, "Post a job" FAB
6. Map filters sheet (subject, grade, price, gender, verified-only, radius, availability)
7. Full-list view (pulled-up bottom sheet) sorted by distance / rating / price
8. Tutor profile detail (from a pin/card)
9. Contact unlock confirm sheet (shows coin cost)
10. **Jobs feed** (tutor) / **Post job** (student)
11. Job detail with bids
12. Bid submission sheet
13. **Vacancies tab** (tutor) — admin-curated vacancy list with filters
14. **Vacancy detail** — full structured fields (code, location, grade, subjects, duration, salary, gender, notes)
15. **Apply to vacancy** sheet — cover note + expected rate + CV upload
16. **Request a tutor** (student) — short form that becomes a draft vacancy for admin review
17. **Shareable profile / vacancy** view via deep link (masked preview if not logged in)
18. My jobs / My bids / My applications / My profile views
19. Wallet — balance, history, buy coins
20. Coin pack purchase (eSewa / Khalti / IME Pay)
21. Reviews + rate-after-engagement prompt
22. Notifications, settings, language toggle (NE/EN)

## 9. Milestones

- **M0 — Foundation (week 1)**: Supabase project, schema + RLS policies, Google OAuth + Phone OTP, routing, theme, BLoC scaffold, NE/EN i18n scaffold.
- **M1 — Profiles & roles (week 2)**: Onboarding role-pick (Student XOR Tutor, immutable), student & tutor profile CRUD, photo upload to Supabase Storage, handle generation, location capture, PostGIS column, immutability trigger on `profiles.role`.
- **M2 — Map home, inDrive-style (weeks 3–4, **primary MVP feature**)**: `flutter_map` + OSM, PostGIS `ST_DWithin` viewport queries (debounced on camera move), color-coded pins (green/amber/grey + verified ring + featured glow), filter chip bar, search field, collapsible bottom-sheet carousel of tutor cards synced to pins, Supabase Realtime channel for live `available` updates, pin jitter for privacy, masked-name display, recenter/filter FABs, "Post a job" FAB.
- **M3 — Job posting + bidding (week 5)**: Job CRUD, bid submission, bids inbox, shortlisting, content-moderation triggers.
- **M3.5 — Admin-curated vacancies (week 5–6)**: `vacancies` + `vacancy_applications` schema, public vacancy codes (`HTN-00276`), tutor-side Vacancies tab with apply flow + CV upload to Supabase Storage, deep-link routes (`/v/<code>`, `/t/<code>`, `/s/<code>`, `/j/<code>`) for both mobile (Android App Links + iOS Universal Links) and a minimal masked web preview.
- **M4 — Coin system + ledger (week 6)**: `wallet_ledger` table, atomic RPC functions for bid/unlock/boost, earning rules, wallet UI.
- **M5 — Contact bridge (week 7)**: `unlock_contact` + `reveal_real_name` RPCs, Call/WhatsApp launchers, unlock rate-limits.
- **M6 — Coin top-ups (week 8)**: eSewa / Khalti / IME Pay integration, Edge Function webhook verification, coin pack purchases, receipts.
- **M7 — Reviews, boosts, polish (week 9)**: Ratings, featured tutors, promoted jobs, pinned bids.
- **M8 — Admin tools + hardening (week 10)**: Next.js admin panel (verification, phone control, ledger audit, moderation queue), abuse mitigation.
- **M9 — Beta launch (week 11)**: Play Store beta in Kathmandu Valley, feedback loop.

## 10. Open Questions / Decisions Needed

- Bid-cost formula: flat (e.g., 5 coins) or scaled to budget (e.g., 1% of budget midpoint)?
- Should the **first bid on every job be free** for new tutors, to seed the marketplace?
- Should contact unlock cost differ by **map vs. job-bid** (e.g., cheaper after a tutor's bid was shortlisted)?
- Should we ever allow **partial coin refunds** (e.g., if a student never reads a tutor's bid within 14 days)?
- Coin pack pricing in NPR and bonus tiers (e.g., 100 NPR = 100 coins, 500 NPR = 600 coins).
- Verification: manual review of ID docs, or partner with a KYC vendor?
- Languages: ship NE + EN at launch, or English-only beta first?

## 11. Risks

- **Marketplace cold-start** — no tutors means no bids, no students means no jobs. Mitigation: seed Kathmandu Valley first; give new tutors free bid credits; recruit tutors manually.
- **Coin economy abuse** — fake referrals, self-reviews. Mitigation: server-side fraud heuristics, phone-uniqueness, manual review for big rewards.
- **Off-platform leakage** — once contact is unlocked, future engagements happen entirely outside the app, so we earn nothing further. This is intentional in v1 (no payment system) but means **coins must be the only viable funnel**, and contact unlock pricing must be tuned.
- **Phone-number scraping** — server-side reveal + rate-limits + watermarked display.
- **Identity leakage via search engines** — real names hidden behind handles; `noindex` on all web surfaces; no public profile URLs; Firestore rules treat name/phone/address as restricted.
- **Map tile cost** at scale — plan migration from public OSM tiles.
- **Trust & safety** — harassment / impersonation. Need a reporting flow from day 1.
