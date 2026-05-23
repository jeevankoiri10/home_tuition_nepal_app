# Home Tuition Nepal — Tutor UI Spec

> **Product:** Home Tuition Nepal (KTM academy)
> **Companion to:** `docs/plan.md` and `docs/admin_panel_plan.md`.
> **Scope:** Every screen, sheet, dialog, and component a **Tutor**-role user sees in the Flutter app, plus the data each surface depends on. Student UI lives in `docs/student_UI.md`.

---

## 1. Tutor in one paragraph

A tutor signs up with Google → verifies phone via OTP → picks the **Tutor** role (permanent) → completes a profile (subjects, rate, area, availability) → uploads ID for the verified badge → lands on a **home dashboard** showing nearby tuition opportunities (admin-curated vacancies + student job posts) and their own profile views. Their day-to-day loop: scan the **Vacancies** feed and **Jobs** feed, **apply** (free or coin-gated), and respond to admin / student messages once contact is revealed. Tutors are **never seen on the map by name** — only by masked handle (`Ramesh S*`) and pin position; their pin is shown at their declared service base (jittered) only when `available = true`.

---

## 2. Design tokens

- **Theme:** Light + dark; system default; user toggle in settings.
- **Primary:** deep indigo (matches `Home Tuition Nepal` brand palette).
- **Accent:** saffron — used sparingly for verified badges and CTAs.
- **Typography:** **Inter** for Latin, **Noto Sans Devanagari** for Nepali; same scale across both.
- **Spacing:** 4/8/12/16/24/32 px scale.
- **Corners:** 12 px on cards, 8 px on inputs, 999 px on chips.
- **Elevation:** 0 / 1 (cards) / 4 (sheets); avoid heavy shadows on Android.
- **Language:** all strings via `AppLocalizations.of(context)` — **no hard-coded strings**.
- **Money:** always render as `Rs. 8,500` (no decimals); period suffix `/mo`, `/hr`, `/session`.
- **Names of others:** never show real names; always **masked** (`Ramesh S*`) per `plan.md` §5.5.

---

## 3. Information architecture

The Tutor app uses a **bottom navigation** with five tabs:

```
┌───────────────────────────────────────────────────┐
│                                                   │
│                  (screen content)                 │
│                                                   │
├───────────────────────────────────────────────────┤
│  Home   Vacancies   Jobs   Wallet   Profile       │
└───────────────────────────────────────────────────┘
```

- **Home** — dashboard with KPIs, nearby opportunities digest, profile views, latest events.
- **Vacancies** — admin-curated `HTN-NNNNN` vacancy feed.
- **Jobs** — student-posted jobs (Upwork-style bidding).
- **Wallet** — coin balance, history, buy coins.
- **Profile** — own profile, availability toggle, edit, verification status, settings.

A top app bar holds the **availability toggle** (Available / Not available — controls map visibility) on Home and Profile, plus a language chip (NE/EN) and a notification bell.

---

## 4. Screens

### 4.1 Splash & auth (shared with student)
1. **Splash** — logo, slogan *"Search tutors in your locality."*, Nepali / English chip picker shown before any auth.
2. **Auth gate** — *Sign in* or *Create your account*. *Sign in with Google* button is offered as a one-tap alternative on both tabs.
3. **Create your account** (the email/password registration form, identical for tutor and student):
   - **First name**, **Last name** (private real name — public will be `Firstname L*`).
   - **Email address** — primary login identifier.
   - **Phone number** (`+977`, 10-digit).
   - **Password** (min 8, letter + digit; strength meter).
   - **Confirm password**.
   - **Role** — radio: **I'm a tutor** · **I'm a student**. *Permanent.*
   - **I accept Terms of Service & Privacy Policy** — required checkbox.
   - **I accept the Tutors' Code of Conduct** — required checkbox, shown **only when "I'm a tutor" is selected**. Tapping the link opens `docs/tutor_code_of_conduct.md` rendered in-app.
   - **Register** button (disabled until valid).
   - Below the form: a short *"Become a tutor — how it works"* explainer (steps 1–7 from `docs/tutor_code_of_conduct.md` → "Become a tutor"), shown when the Tutor role is selected.
4. **Phone OTP** — 6-digit code, autofill where supported. On success `phone_verified = true`. Until verified, the account exists but cannot apply, bid, post, or unlock.
5. *(Google Sign-In branch)* If the user chose Google: a short follow-up asks for Role, Phone (+ OTP), and ToS / Code-of-Conduct acceptance — then continues into the wizard.

### 4.2 Tutor onboarding wizard
Stepper, 6 screens:
1. **Identity** — full name (private), display first name + last initial preview (`Ramesh S*`), gender, DOB, profile photo (square crop, 256 px minimum).
2. **Teaching mode** — three large cards: **Online**, **Offline (in-person)**, **Both**. Drives `tutors.teaching_mode`. *Online-only tutors skip step 3 (service-area).* For Offline / Both, step 3 is mandatory.
3. **Where you teach** (Offline / Both only) — request location permission → `geolocator` captures `lat/lng`. Reverse-geocoded area label shown; tutor can edit (`area_label` e.g. *"Kapan, Faika Chowk"*). Travel radius slider (1 / 3 / 5 / 10 km).
4. **Levels you can teach** — checklist of the canonical taxonomy: **Below Class 9**, **SEE**, **+2**, **A Level**. Multi-select; at least one required. Drives `tutors.levels_taught[]` and gates which students will see this tutor.
5. **Subjects offered (per level + price)** — for each level chosen in step 4, an editable table:
   ```
   ┌────────────┬──────────┬─────────┐
   │ Level      │ Subject  │ Price   │
   ├────────────┼──────────┼─────────┤
   │ Below 9    │ Science  │ 8,000   │  [+]
   │ +2         │ Maths    │ 12,000  │  [+]
   └────────────┴──────────┴─────────┘
   ```
   Each row writes to `tutor_offerings(level, subject, price_npr)`. Tutor can add multiple subjects per level. The lowest `price_npr` is shown as the "from" rate on cards. Plus a short bio (`about_me`), teaching-methodology (`about_sessions`), and qualifications (`qualifications`) — all three rendered as the **ABOUT ME**, **ABOUT MY SESSIONS**, **QUALIFICATIONS** sections on the public profile (phone-number ban applies).
6. **Availability** — a **3 × 7 grid** of checkboxes:
   - Rows: **Pre 10 am** (☀ early), **10 am – 5 pm** (☼ midday), **After 5 pm** (🌅 evening).
   - Columns: **Sun · Mon · Tue · Wed · Thu · Fri · Sat**.
   - Tap any cell to toggle Yes/No. Tap a row label to toggle the whole row.
   - Persisted to `tutor_availability.slots` (JSONB). Quick presets: *"Evenings only"*, *"Weekends only"*.
7. **Verification (optional now, recommended)** — citizenship / academic certificate upload (PDF/JPG); +50 coins on approval. Skip button visible.

Completes onboarding → **+1000 coin** welcome credit toast (per `platform_settings.signup_coin_grant`) → lands on Home.

### 4.3 Home (tab 1)
Three stacked sections:

**4.3.1 KPI row** (horizontal scroll on small screens)
- *Available* toggle pill (large, sticky).
- *Profile views (7 d)*.
- *Contact unlocks (lifetime)*.
- *Coin balance*.

**4.3.2 Nearby opportunities digest**
- 3 cards horizontally: **Top vacancy near you**, **Top job near you**, **Suggested student**.
- Each card: subject, area, salary/rate, distance.
- Tap → corresponding detail screen.

**4.3.3 Activity feed**
- Latest events: new application status, new view, new review, new vacancy in your area, coin credit/debit.
- Each row tappable.

Empty states: friendly illustration + CTA *"Browse vacancies"*.

### 4.4 Vacancies tab (tab 2) — **most important tutor surface**

Mirrors the structured format used by Nepali brokers (see `plan.md` §3.3).

**4.4.1 Feed**
- Filter chip row (sticky): subject • grade • salary • gender match • radius • status.
- Sort dropdown: newest / nearest / highest salary / best match.
- Cards (one per vacancy):
  - Code chip (`HTN-00276`) + status badge (Open / Applications closed).
  - Title (e.g., *"Home Tuition Teacher Required"*).
  - Area line with map pin icon: *"Kapan, Faika Chowk · 2.1 km"*.
  - Grade • Subjects.
  - Duration • Frequency.
  - Salary chip (`Rs. 8,500 /mo`).
  - Gender pref pill.
  - Notes excerpt (1 line).
  - CTA: **Apply** (or *Applied* if already applied — disabled with timestamp).
- Pull-to-refresh; infinite scroll.

**4.4.2 Vacancy detail**
- Full structured view (all fields from `plan.md` §3.3 / §7 `vacancies` table).
- Map preview with pin at vacancy location.
- Notes shown in full (markdown-rendered, links stripped).
- "Posted by **Home Tuition Nepal** admin" footer.
- Sticky bottom: **Apply** button → opens Apply sheet.
- Share icon → copies deep link (`htn.app/v/HTN-00276`).

**4.4.3 Apply sheet**
- Cover note textarea (with the phone-number ban warning).
- Expected rate (NPR; pre-filled with tutor's default; editable).
- CV upload (`pdf` / `jpg` / `png`, ≤ 5 MB) → uploaded to Supabase Storage `cvs/` (private bucket).
- Coin-cost line: *"This apply costs **1 coin**."* (Default; the exact cost is fetched live from `platform_settings.apply_coin_cost` so admins can change it without an app release.)
- **Submit** → calls `apply_to_vacancy` RPC → server validates moderation → on success, application appears under My applications with status *Pending*.

**4.4.4 My applications**
Sub-screen reachable from Vacancies tab via a header tab `Feed | My applications`.
- Cards grouped by status: Pending / Shortlisted / Hired / Rejected.
- Tap → vacancy detail with my application thread.
- Cancel application button on Pending.

### 4.5 Jobs tab (tab 3) — student-posted jobs (Upwork-style)

**4.5.1 Feed**
- Filter chips: subject • grade • budget • mode (in-person / online) • radius.
- Cards:
  - Student handle + masked name.
  - Subject, grade, area, schedule.
  - Budget range chip.
  - Bid count + "Promoted" tag if applicable.
  - CTA: **View & bid** (or *Bid sent* if already bid).

**4.5.2 Job detail**
- Full job fields.
- Map preview.
- Student profile snippet (masked).
- Bid list visible to the tutor only as count (privacy: tutors don't see other tutors' bids).
- Sticky bottom: **Submit bid** (with coin cost shown).

**4.5.3 Bid submission sheet**
- Cover note (phone-ban warning).
- Proposed rate.
- Coin cost shown ("Submitting this bid costs **1 coin**" — value fetched live from `platform_settings.apply_coin_cost`).
- **Submit** → `spend_coins_and_bid` RPC; toast confirms.

**4.5.4 My bids**
Sub-tab `Feed | My bids`. Same statuses as applications.

### 4.6 Wallet tab (tab 4)
- Balance hero card with big number + "+ Buy coins" CTA.
- Tabs: **History** | **Earn** | **Buy**.
- **History**: ledger feed (debit/credit, reason, ref, timestamp). Filterable.
- **Earn**: list of earning rules from `plan.md` §4.2 with per-rule progress (e.g., *"Complete profile (20 coins) — Done ✓"*, *"Verify ID (50 coins) — In review"*). Refer-a-friend deep-link share.
- **Buy**: coin packs (e.g., 100 / 500 / 2000) with price in NPR; tap → eSewa / Khalti / IME Pay flow. After top-up webhook confirms, coins appear via Supabase Realtime — no manual refresh.

### 4.7 Profile tab (tab 5)
- Header: avatar + masked name + handle + public code (`T-A4F7QK`) + verified badge + **mode chip** (Online / Offline / Both).
- **Availability** toggle (large) — controls `tutors.available` (map visibility).
- **Teaching mode** card — current selection; tap to switch between Online / Offline / Both. Switching to Online hides the service-area card.
- **Service area** card → tap to edit (map + radius). Hidden for Online-only tutors.
- **Levels you teach** card — chips for Below Class 9 / SEE / +2 / A Level. Tap to edit.
- **Subjects Offered (Level / Subject / Price)** card — full editable table mirroring onboarding step 5; bound to `tutor_offerings`.
- **Weekly availability grid** card — 3 × 7 checkbox grid mirroring onboarding step 6; bound to `tutor_availability.slots`.
- **About me** card — long-form bio (`about_me`).
- **About my sessions** card — teaching methodology (`about_sessions`).
- **Qualifications** card — degrees, institutions, certifications (`qualifications`).
- **Profile completeness** progress bar with checklist.
- **Verification** card: pending / verified / rejected with action.
- **Reviews received** list (stars, masked student name, text). Reply allowed once per review.
- **Profile views** list (last 50, masked).
- **Settings** sub-screen:
  - Language toggle (NE / EN) — affects entire app immediately.
  - Theme (system / light / dark).
  - Notifications preferences.
  - Privacy reminders (masked-name explanation, name-not-searchable note).
  - **Contact admin** — opens WhatsApp deep link to `platform_settings.admin_whatsapp` (currently `wa.me/9779807590455`, editable by admin).
  - About / Terms / Privacy.
  - **Sign out**.
  - **Delete account** (soft delete; 30-day reversible).

### 4.7a Profile Settings (full editor — reachable from Profile tab → "Edit profile")
A multi-section editor for the tutor's full profile. On mobile, sections appear as a top-of-screen segmented control or a stacked accordion; on tablets / web, they appear as a left sidebar.

**Header**
- Avatar + masked name + handle + public code (`T-A4F7QK`).
- **Wallet balance** chip showing `रू <balance>` (clickable → Wallet).
- **Withdraw** button (placeholder — wired up later if/when coin-to-NPR cashout is enabled).
- **Sign out** button.
- A persistent banner across the top: *"⚠ Your profile is in draft mode. Complete all steps to publish and go live. **80% profile completed**"* (the number is `profiles.profile_completion`). The banner disappears when `draft_status = 'published'`.

**Sections (sidebar):**
1. **Personal details** (4.7a.1)
2. **My education** (4.7a.2)
3. **My subjects** (4.7a.3)
4. **My availability** (4.7a.4)
5. **Identity verification** (4.7a.5)

Each section auto-saves on every field change (with a small "saved" toast) — *"Your progress is saved automatically, and you can come back and finish anytime."* The big **Save & Update** button at the bottom of each section explicitly **publishes** changes to the live profile (flips `draft_status` from `draft` to `published` when profile-completion ≥ a threshold like 80 %).

#### 4.7a.1 Personal details
- **Full name** — First / Last (two side-by-side fields). Renders the live masked-name preview underneath.
- **Email** (read-only after registration; change via Settings → Account).
- **Phone number** (read-only after OTP verification; change via Settings → Account).
- **Gender** — radio: Male · Female · Not specified.
- **Your tagline** — short headline (≤ 80 chars, e.g., *"Pulchowk Campus Engineering Graduate"*) → `tutors.tagline`.
- **Meta keywords** — chip input for search keywords → `tutors.meta_keywords[]`.
- **Address**
  - Country (default Nepal).
  - Zone (e.g., Bagmati).
  - City (e.g., Lalitpur).
  - Address line (e.g., Kupandole) → `tutors.address_line` — private, never publicly shown.
- **Native language** — single-select (default Nepali) → `tutors.native_language`.
- **Tutor mode** — segmented: Online / Offline / Both → `tutors.teaching_mode`.
- **Languages I know** — multi-select chip picker (long localized list including English, Hindi, Nepali, Newari, Maithili, Bhojpuri, Tharu, Magar, Gurung, Limbu, etc.) → `tutors.languages_known[]`.
- **A brief introduction** — long-form textarea with:
  - Min word count enforced (default **300 words**; live counter underneath: `Words: 37/300`).
  - **Write with AI** helper button — opens a small assist sheet that turns bullet hints into a polished bio (server-side LLM call; user reviews/edits before saving).
  - Phone-ban warning banner above the textarea (see `plan.md` §5.6).
- **Profile photo** — drag/drop or tap to upload (`jpg, jpeg, gif, png`; ≤ 5 MB).
- Sticky **Save & Update** button at the bottom.

#### 4.7a.2 My education *(all subsections optional)*
Three stacked sub-sections, each with its own list + *"Add"* action. Empty by default.

**Education** (`tutor_education`)
- Add entries: Degree (e.g., *Bachelor in ECE*), Institution (*Pulchowk Campus*), Field of study, Start year, End year (or "Ongoing"), Description.
- Drag-reorder.

**Experience** (`tutor_experience`)
- Add entries: Role title, Organization, Start year, End year, Description.

**Certificates & Awards** (`tutor_certificates`)
- Add entries: Title, Issuer, Year awarded, Optional certificate file (PDF/JPG/PNG, ≤ 5 MB, stored in `Supabase Storage` private bucket and revealed only via signed URL on the public profile).

Every subsection is **optional** — the profile can be published without any of them, but having them filled boosts the completion %.

#### 4.7a.3 My subjects
Editor for `tutor_offerings` and `tutors.levels_taught[]`. Identical to the table from onboarding step 5 (see §4.2), but the user can edit at any time.

#### 4.7a.4 My availability
Editor for `tutor_availability.slots` — the 3-band × 7-day grid identical to onboarding step 6.

#### 4.7a.5 Identity verification
- Upload **Citizenship** (front + back).
- Upload **Selfie holding citizenship** (anti-spoof check).
- Upload **Academic certificates** (optional but recommended).
- Status badges: *Not started* / *Submitted* / *Under review* / **Approved** / *Rejected (with reason)*.
- On **Approved**:
  - Verified ✓ badge appears site-wide on this tutor's card and profile.
  - Push notification *"Identity Verification Approved"* delivered (see §4.8).
  - +50 coins credited (per `platform_settings.id_verification_bonus`).
- On **Rejected**: reason is shown; the user can re-submit.

> **Design note:** screens below (§4.7b onward that reference competitor screenshots) are *informed* by the references, not copied — improve on them. We mask names, never leak raw numbers in transaction logs, and we keep the map-first identity throughout.

### 4.7b Settings screen (our take — better than the reference)
Mirrors the competitor "Settings" screen exactly, grouped as four sections:

- **Appearance**
  - **Theme Mode** card with right-aligned dropdown: **System / Light / Dark** (default *System*).
- **Account**
  - **Profile Settings** row — subtitle *"Manage your profile information"*. Tapping opens §4.7a Profile Settings.
- **Danger Zone**
  - **Delete Account** card (red outline) — *"Permanently delete your account"*. Tapping starts the 30-day soft-delete flow.
  - **Logout** card (orange outline) — *"Sign out from your account"*.
- **About**
  - **App Version** card — shows the running build (e.g., `2.0.9+1`). Long-press copies the version + commit SHA to clipboard for support.

### 4.8 Notifications screen
- Reached from the bell in the top app bar (and from the bottom nav for prominence).
- Header *"Notifications"*, hamburger menu on the left.
- **Tabs (segmented control): All · Unread · Read** — three pills, the active one highlighted in the brand indigo.
- Card list (one per notification):
  - **Top-left label** in indigo when unread (e.g., *"New job posted"*); the label switches to grey/muted when read.
  - **Body line** — the localized title: *"Online Finance, Real estate tutor needed in Mussafah"*, *"Home | online Calculus 1 tutor required in Al Barsha"*, etc.
  - **Right side:** relative time (`19m ago`, `1h ago`, `2h ago`); a chat-bubble icon — solid blue for unread, outlined grey with a check for read.
  - Tap → deep-links to the relevant detail (job, vacancy, application, identity-verification result).
  - Long-press → mark read / unread / dismiss.
- Pull-to-refresh; infinite scroll; data backed by the `notifications` table via Supabase Realtime.
- The **`new_job_posted`** notifications are the most frequent kind and are produced automatically by the `notify_matching_tutors` Edge Function described in `plan.md` §5.6a — they arrive within a few seconds of a student posting a matching job or an admin publishing a matching vacancy.
- Notification types tutors see:
  - `application_shortlisted` — *"Your application to HTN-00276 has been shortlisted."*
  - `application_hired` — *"You've been selected for HTN-00276. Tap to view the student's contact."* (taps to Contact-revealed sheet)
  - `new_vacancy_match` — *"New vacancy in Kapan — Class 7, All subjects."*
  - `new_review` — *"You received a 5★ review."*
  - `coin_credited` / `coin_debited`.
  - `identity_verification_approved` — push + in-app banner: *"Identity Verification Approved"*. Tutor's Verified ✓ badge becomes active site-wide; +50 coin credit; tapping deep-links to Profile Settings → Identity verification with the new status.
  - `identity_verification_rejected` — push: *"Verification needs attention — tap to see reason and re-submit"*.
  - `moderation_warning` (with reason).

### 4.9 Contact-revealed sheet (admin-mediated)
When the admin assigns this tutor to a vacancy, the app surfaces a full-screen sheet:
- Student real name (full, since the match is confirmed).
- Address (the **exact** vacancy address, not masked).
- Phone number with **Call** and **WhatsApp** buttons.
- "Please contact within 24 hours. Off-platform negotiations and payment are between you and the parent."
- Quick action: **Mark as contacted**.

### 4.10 Deep-link landing (web preview)
When someone opens `htn.app/t/T-A4F7QK` or a vacancy link without the app installed, a minimal masked web preview is shown (handle, masked name, area, subjects, rating, "Open in App" button to install). Real name and phone are **never** in this preview.

---

## 5. Components (reusable)

- **TutorCard** — used in Home digest, search-results, admin profile previews.
- **VacancyCard** — used in feed and notifications.
- **JobCard** — used in jobs feed.
- **PhoneBanWarning** — banner shown above every free-text input (subject of `plan.md` §5.6).
- **MaskedAvatar** — circular avatar with masked-name caption underneath.
- **CoinChip** — small pill showing a coin cost / balance.
- **MapPinPicker** — used in service-area edit.
- **VerifiedBadge** — gold ring + check icon.
- **LanguageToggle** — NE / EN segmented control.

---

## 6. State management (BLoC)

Each tab owns one Cubit / Bloc:

```
AuthCubit                — login state
LocaleCubit              — NE / EN, persisted
TutorOnboardingBloc      — steps + validation
TutorHomeBloc            — dashboard data load
VacanciesBloc            — paginated feed + filters
VacancyDetailBloc        — single vacancy + my application
ApplySheetBloc           — apply form + submit
JobsBloc                 — paginated feed
JobDetailBloc            — single job + my bid
BidSheetBloc             — bid form + submit
WalletBloc               — balance + ledger
TopUpBloc                — coin-pack purchase flow
ProfileBloc              — own profile, availability toggle
SettingsBloc             — preferences
NotificationsBloc        — feed
ContactRevealedBloc      — show / mark contacted
```

Repositories injected via `get_it`. All Supabase calls hidden behind repository interfaces so tests can swap them.

---

## 7. Permissions & sensitive data

The tutor app requests:
- **Location** (foreground) — required to suggest nearby vacancies / jobs and to be pinned on the map. Clear rationale screen before the system prompt.
- **Camera / Storage** — for ID upload, CV upload, profile photo.
- **Notifications** — for application status, new matches.

Never asked unnecessarily; never asked again after a hard deny without a clear "Why we need this" recap.

Real names, real addresses, and phone numbers of *other* users are never embedded in any tutor-facing screen except the Contact-revealed sheet (after admin assignment) and the post-unlock contact view.

---

## 8. Edge cases

- **No subjects selected yet** → Home shows a single big card prompting profile completion.
- **No vacancies in radius** → friendly empty state with *"Expand radius"* and *"Get notified when new ones arrive"* (push permission re-prompt).
- **Phone-ban regex tripped on description** → submit disabled, inline hint plus banner; logged in `moderation_log` as `warn` even if the user fixes it.
- **Insufficient coins on apply / bid** → bottom sheet shows balance, deficit, and a **Buy coins** CTA.
- **Account suspended / banned** → all CTA actions disabled; banner with appeal link to admin WhatsApp.
- **Offline** → cached Home + Vacancies feed shown, Apply / Bid disabled with offline toast.

---

## 9. Accessibility

- All tap targets ≥ 44 dp.
- Color contrast WCAG AA on both themes.
- Screen-reader labels on every icon-only button.
- Both font families tested for Devanagari and Latin co-render at 12 – 28 sp.
- Long-press on masked-name chip explains *"Real names are hidden until a match is confirmed."*

---

## 10. Open questions (tutor-side)

- Should the **Jobs** tab be hidden by default for v1, since the Vacancies feed is the headline broker flow?
- Should we let tutors **proactively message the admin** from the app for off-platform support, or only via the WhatsApp link?
- Do we surface a **"trusted by KTM academy"** ribbon on verified tutors' cards on the student side? (Probably yes — drives trust.)
- Should availability be **per-vacancy** (apply with custom hours) or only global (the profile-level availability)?
