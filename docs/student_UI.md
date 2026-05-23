# Home Tuition Nepal — Student UI Spec

> **Product:** Home Tuition Nepal (KTM academy)
> **Companion to:** `docs/plan.md`, `docs/admin_panel_plan.md`, `docs/tutor_UI.md`.
> **Scope:** Every screen, sheet, and component a **Student**-role user sees in the Flutter app, plus the data each surface depends on.

---

## 1. Student in one paragraph

A student (or parent) signs up with Google → verifies phone via OTP → picks the **Student** role (permanent) → completes a short profile → grants location → lands directly on a **live map of nearby tutors** (the inDrive-style headline experience). From the map they can: (a) tap a pin and **unlock a tutor's contact** with coins, (b) tap **Post a job** to start an Upwork-style bid, or (c) tap **Request a tutor** to send a short brief to the admin which becomes a `HTN-NNNNN` vacancy. They review tutors (masked names, ratings, distance, rate), contact them off-platform via Call / WhatsApp once unlocked, and afterwards can leave a review.

The student's single most important action: *Find a qualified tutor in my locality and reach them in 1–2 taps.*

---

## 2. Design tokens

Same tokens as the tutor app (see `tutor_UI.md` §2): light/dark themes, indigo primary + saffron accent, Inter + Noto Sans Devanagari, NE/EN first-class, masked names everywhere, money rendered as `Rs. 8,500 /mo`, etc.

---

## 3. Information architecture

The Student app uses a **bottom navigation** with five tabs:

```
┌───────────────────────────────────────────────────┐
│                                                   │
│                  (screen content)                 │
│                                                   │
├───────────────────────────────────────────────────┤
│   Map     Jobs     Saved     Messages     Profile │
└───────────────────────────────────────────────────┘
```

- **Map** — inDrive-style live map of nearby tutors. **Default landing tab.** This is the headline feature.
- **Jobs** — student's posted jobs + their bids; also where new job posts and "Request a tutor" (vacancy) live.
- **Saved** — shortlisted / saved tutors and bookmarked vacancies.
- **Messages** — once a contact is unlocked, a lightweight log of unlocked tutors + quick re-call / re-WhatsApp buttons (the platform does not host in-app chat in v1).
- **Profile** — own profile, settings, language, wallet entry.

Top app bar holds: a search field (subject / area), the **active radius** chip, a language chip (NE/EN), and a notification bell.

---

## 4. Screens

### 4.1 Splash & auth (shared with tutor)
1. **Splash** — logo, slogan *"Search tutors in your locality."*, NE/EN chip picker shown before any auth.
2. **Auth gate** — *Sign in* or *Create your account*. *Sign in with Google* offered as a one-tap alternative.
3. **Create your account** (the same email/password form used for tutors — see `tutor_UI.md` §4.1):
   - First name, Last name, Email, Phone (`+977`), Password + Confirm, Role radio (**I'm a tutor** / **I'm a student** — Student selected here, **permanent**), ToS checkbox, **Register**.
   - (The Tutors' Code of Conduct checkbox is hidden for students; only ToS / Privacy is required.)
4. **Phone OTP** (`+977`, 6-digit). On success `phone_verified = true`; until verified, the student cannot unlock contacts, post jobs, or request a tutor.
5. *(Google Sign-In branch)* If chosen, a short follow-up asks for Role, Phone (+ OTP), and ToS acceptance.

### 4.2 Student onboarding wizard
Short — students need to get to the map fast. 4 steps:
1. **Select Student's Level** — large list-picker mirroring the standard Nepali education taxonomy: **Below Class 9**, **SEE**, **+2**, **A Level**. Single-select; persisted to `profiles.student_level`. A *Skip to Home* link is available — but skipping means the map shows tutors for *all* levels rather than only the matching ones (a banner reminds the student they can set it later in Profile). This is the very first onboarding screen after role pick because it gates everything downstream.
2. **Who is this for?** — "Myself" / "My child" / "Someone else"; first name + last initial (masked-name preview shown live: *"Sita K*"*); gender; DOB (optional, only required if "Myself"); avatar.
3. **Where do you need a tutor?** — request location permission with rationale screen, capture `lat/lng` via `geolocator`, reverse-geocode `area_label` (editable). Optional secondary location (e.g., "near my school").
4. **What subject?** — multi-select chips. Subject options are **scoped to the level chosen in step 1** (e.g., for +2 the chips show +2-relevant subjects). This step isn't required — students can also skip and browse freely — but pre-fills filters on first map view.

Completes onboarding → **+1000 coin** welcome credit toast (per `platform_settings.signup_coin_grant`) → lands on **Map** tab with the Level filter chip already set to the student's level.

### 4.3 Map (tab 1) — **headline screen, inDrive-style**

The single most important screen of the app. Mirrors `plan.md` §3.1 in full.

**4.3.1 Layout**
- Full-screen `flutter_map` with **OpenStreetMap** tiles.
- Camera auto-centers on the student's current location; a soft blue dot marks "you".
- Tutor pins (color-coded):
  - **Green** — available now.
  - **Amber** — available later today / by appointment.
  - **Grey** — offline (off by default; togglable in filters).
  - **Gold ring** — verified ✓.
  - **Featured pins** (coin-boosted) — slightly larger with a glow.
- Pins are shown at the tutor's declared service base with 50–100 m **jitter** for privacy. Real-time GPS is never exposed.

**4.3.2 Top of screen**
- Search field: *"Search subject, language, level…"*.
- Horizontal scrollable **filter chip bar**:
  - **Level** (pre-set to the student's `profiles.student_level`; tap to change between Below Class 9 / SEE / +2 / A Level; *"All levels"* option available). This is the most important chip — it shapes everything else.
  - **Subject** (subject options are scoped to the active Level chip; e.g., picking *+2* changes the subject suggestions accordingly).
  - **Price** range.
  - **Gender preference** (Any / Male / Female).
  - **Verified only** toggle.
  - **Mode** (Offline / Online / Both — defaults to *Offline + Both* for the map view, since Online-only tutors aren't pinned).
  - **Radius** (1 / 3 / 5 / 10 km / custom).
  - **Available now** toggle.
- Active radius shown as a soft transparent circle on the map.

**Map matching rule:** a tutor pin is shown only if `tutors.levels_taught[]` contains the active Level chip's value (or the chip is set to *"All levels"*). Online-only tutors are excluded from the map by default — they surface in the list view.

**4.3.3 Bottom of screen**
- **Collapsible bottom sheet** with a **horizontally swipable carousel of TutorCards** mirroring the visible pins. Each card:
  - Masked-name avatar (`Ramesh S*`).
  - Verified badge if applicable.
  - Distance (`1.2 km`), rating ★ (count), hourly rate.
  - Top 2 subjects.
  - *Available now* badge when relevant.
  - Primary button: **Contact** (opens unlock sheet).
- Tap a card → camera flies to that pin and re-centers. Tap a pin → carousel scrolls to that card. Always in sync.
- Pull the sheet up → expanded **full list view** sorted by distance / rating / price.

**4.3.4 Floating actions**
- Right edge: **Re-center on me**, **Map / satellite toggle**, **Filters**.
- Bottom-left: **Post a job** (FAB → Jobs flow).
- Bottom-left secondary: **Request a tutor** (FAB → Vacancy request flow).

**4.3.5 Interactions**
- **Drag-to-explore** — camera move triggers a debounced (~400 ms) re-query of tutors in the new viewport.
- **Pinch-zoom** adjusts implicit radius and updates the radius chip.
- **Long-press on the map** drops a custom search-center pin (e.g., "tutors near my school instead of home"); carousel updates.
- **Real-time** — Supabase Realtime channel pushes `available` toggles and base-location updates; pins animate in/out without refresh.
- **Empty state** — when no tutors match in the chosen radius: friendly empty card with two CTAs — *Expand radius* and *Request a tutor*.

### 4.3.6 Find Teachers — list view (pulled-up sheet)
When the bottom sheet is pulled fully up, it becomes a **full-screen list** of tutors matching the current filters. This is the **list counterpart to the map** — same data set, same filters, different view. Inspired by the standard "Find Teachers" pattern in Nepali tuition apps.

Each row:
- Circular avatar (left).
- Masked name (`Bidhya T*`) + verified badge.
- **Area chip** (e.g., *Chabahil*, *Kalimati*, *Lazimpat*).
- One-line qualification summary (auto-extracted from `tutors.qualifications`, e.g., *"+2 in Science"*, *"Bachelors in Microbiology"*, *"BSC.CSIT"*).
- **Price** on the right (e.g., `Rs. 7,000`) — the lowest `tutor_offerings.price_npr` for the active Level filter ("from" rate).
- **Rating** (`★ 4.6 · 12` or `Not rated ☆`).

Header: title *"Find Teachers"*, a **filter / search** icon (opens the same filter sheet as the map), sort dropdown (Distance / Price low → high / Rating / Newest).

Tap a row → tutor profile detail (§4.4). Long-press → quick **Save** / **Share**.

### 4.4 Tutor profile (full)
Opened by tapping a card's title, a list-view row, or a pin info bubble.

**Header card** (mirrors the standard Nepali tuition-app tutor-detail layout):
- Avatar (left).
- Masked name (top), with verified badge.
- **"from" price** in NPR (e.g., `Rs. 5,000`) — lowest `tutor_offerings.price_npr` for the student's active level.
- **Area chip** (e.g., *Koteswor, Kathmandu*).
- **Level chip** (e.g., *+2 Science*) — primary level + headline subject.
- **Rating** badge (`★ 4.6 · 12` or `Not rated ☆`).
- Distance line + mode chip (Online / Offline / Both).

**Primary CTA bar:**
- **Book this teacher** — green, full-width.
- In our model, *Book* maps to the **coin-gated contact unlock** (`unlock_contact` RPC). Tapping opens the contact-unlock sheet (§4.5), which after confirmation surfaces Call / WhatsApp.
- For Online-only tutors, the same CTA still applies — only the post-unlock guidance differs ("Schedule a virtual session over WhatsApp / call").
- Secondary buttons: **Save** (heart), **Share** (deep-link `htn.app/t/T-A4F7QK`).

**Sections (scroll):**
- **ABOUT ME** — `tutors.about_me` (long-form bio, phone numbers stripped server-side).
- **ABOUT MY SESSIONS** — `tutors.about_sessions` (teaching methodology).
- **QUALIFICATIONS** — `tutors.qualifications` (degrees, institutions, certifications).
- **Subjects Offered** — table rendered from `tutor_offerings`:
  ```
  Level         Subject       Price
  Below 9       Science       Rs. 8,000
  +2            Maths         Rs. 12,000
  ```
- **Weekly availability** — read-only 3×7 grid from `tutor_availability.slots`.
- **Languages** — chips.
- **Reviews** — paginated (stars, masked student name, text).
- "Reports & safety" subtle link at the bottom.

Sticky bottom action bar persists *Save · Share · **Book this teacher*** across scroll.

### 4.5 Contact-unlock sheet (= "Book this teacher" confirm)
- Modal bottom sheet.
- Tutor preview card.
- *"Unlock contact for **5 coins**."* Coin cost is fetched live from `platform_settings.unlock_coin_cost`.
- Coin balance shown; if short, *Buy more* CTA replaces *Confirm*.
- **Confirm** → calls `unlock_contact` RPC → server debits coins atomically, returns `phone` and full real name.
- After unlock: replaced by a small panel with **Call** and **WhatsApp** buttons (`tel:` and `wa.me/<num>` via `url_launcher`). Tutor's real name now visible. A *Save to Messages* affordance.

### 4.6 Jobs tab (tab 2)
A combined view of the two student-initiated flows.

**4.6.1 Top header tabs:**
`My jobs | My requests (vacancies) | New`

**4.6.2 My jobs**
- Cards: subject, area, budget, bid-count, status (Open / Shortlisting / Hired / Closed / Expired).
- Tap → job detail.

**4.6.3 Job detail** (student view)
- Full job fields.
- **Bids list** — masked tutor cards with cover note, proposed rate, rating.
- Filters: lowest rate / highest rated / nearest / verified-only.
- Per-bid actions: **Shortlist**, **Unlock contact** (coin cost shown), **Reject**.
- Sticky bottom: **Close job** / **Edit**.

**4.6.4 Post a job**
- Form: subject, grade, area (auto + editable), schedule, budget min/max, in-person / online, requirements (with phone-ban warning).
- Optional **Promote** toggle (20 coins) — appears at top of tutor feeds.
- **Submit** → job appears in feed and in My jobs.

**4.6.5 My requests (vacancies)**
- List of `HTN-NNNNN` vacancies the student has requested from the admin.
- Status: Submitted → Under review → Published → Filled / Cancelled.
- Tap → vacancy detail (student view): structured fields + admin's current status note. No bid list (those are admin-managed). The student is notified when the admin assigns a tutor and the contact-revealed sheet appears.

**4.6.6 Request a tutor (new vacancy)**
- Short form (lighter than Post a job):
  - Where: area + map pin.
  - Number of students.
  - Grade.
  - Subjects.
  - Preferred time / duration.
  - Frequency.
  - Salary range.
  - Gender preference.
  - Mode (in-person / online / either).
  - Notes / constraints (phone-ban warning).
- **Submit** → creates a draft `vacancies` row in `status = 'open'` (or `'pending_admin_review'` depending on workflow). Admin reviews, normalizes, assigns the `HTN-NNNNN` code, and publishes. Student gets a push when the code is issued.

### 4.7 Saved tab (tab 3)
- Two sub-tabs: **Tutors** | **Vacancies**.
- Tutors: tap to open tutor profile.
- Vacancies: bookmarked admin-curated vacancies the student wants to reference (e.g., for friends).
- Long-press on a saved tutor → quick **Unlock contact** if not already.

### 4.8 Messages tab (tab 4)
The platform does **not** host in-app chat in v1. This tab is a **contact-log**:
- One row per tutor whose contact the student has unlocked.
- Each row shows: avatar, real name (unlocked), last unlock date, channel (Call / WhatsApp).
- Quick action chips on the row: **Call**, **WhatsApp**, **View profile**, **Leave review** (after engagement).
- Search across unlocked contacts.

### 4.9 Profile tab (tab 5)
- Header: avatar, masked name preview (what others would see), full real name, handle, public code (`S-9BG2HM`).
- **Wallet** card → opens wallet screen (balance + buy coins).
- **My location** card → edit primary + secondary locations.
- **My subject preferences** card.
- **Reviews I've left**.
- **Settings** sub-screen — laid out exactly as in the competitor reference, with four labeled sections:
  - **Appearance** → *Theme Mode* card with dropdown (System / Light / Dark). Below it: *Language* card with NE / EN toggle.
  - **Account** → *Profile Settings* card (*Manage your profile information*) → opens full profile editor. Also: *Notifications* preferences (quiet hours, channels), and *Contact admin* (opens WhatsApp at `platform_settings.admin_whatsapp`).
  - **Danger Zone** → *Delete Account* card (red outline, *"Permanently delete your account"*, starts the 30-day soft-delete flow) and *Logout* card (orange outline, *"Sign out from your account"*).
  - **About** → *App Version* card showing the running build (e.g., `2.0.9+1`); long-press to copy version + commit SHA. Terms / Privacy linked underneath.

### 4.10 Wallet screen (linked from Profile)
- Balance hero card + **Buy coins** CTA.
- Tabs: **History** | **Earn** | **Buy**.
- Same structure as tutor wallet (`tutor_UI.md` §4.6) but with student-specific earning rules (referral, profile completion, leaving a review).
- Buy: coin packs via eSewa / Khalti / IME Pay.

### 4.11 Reviews
- After a contact is unlocked, the app prompts (push + in-app banner) for a review 7 days later.
- Form: 1–5 ★ + free-text (phone-ban warning).
- Submitting earns the student 5 coins.

### 4.12 Notifications screen
- Reached from the bell.
- Types students see:
  - `new_tutor_nearby` — *"3 new tutors near you matching Class 7 Maths."*
  - `bid_received` — *"You got a new bid on your job."*
  - `vacancy_published` — *"Your request is live as HTN-00276."*
  - `tutor_assigned` — *"Admin has matched you with a tutor. Tap to see contact."* (taps to Contact-revealed sheet)
  - `coin_credited` / `coin_debited`.
  - `review_reminder`.

### 4.13 Contact-revealed sheet (admin-mediated)
When the admin assigns a tutor to the student's vacancy, the app surfaces a full-screen sheet:
- Tutor real name (full).
- Photo + verified badge.
- Brief profile (subjects, rate, area).
- Phone with **Call** and **WhatsApp** buttons.
- "Please contact within 24 hours. Off-platform negotiations and payment are between you and the tutor."
- Quick action: **Mark as contacted** + reminder to leave a review later.

> **Design note for §4.14a – §4.14g:** the screens below were *informed* by the competitor screenshots the user shared — we use them to understand **what the user needs** at each step, not to copy the layout. Where the references are cluttered, we simplify; where they leak information (e.g., raw phone numbers in transaction descriptions or post details), we mask; where they're list-only, we keep our **map-first** identity. Treat each spec as a starting point for design — improve on it, don't mirror it.

### 4.14a Notifications screen (our take — better than the reference)
- Header *"Notifications"* with hamburger menu.
- **Segmented tabs: All · Unread · Read.**
- Cards as in `tutor_UI.md` §4.8: left label (e.g., *"New job posted"*, *"Tutor matched"*, *"Bid received"*, *"Identity Verification Approved"*) + body line + relative time + chat-bubble icon (solid when unread, outlined-with-check when read). Tap → deep-link to the referenced detail.

### 4.14b Coin Wallet screen (our take — better than the reference)
- Header *"Coin Wallet"* with hamburger menu.
- **Gradient hero card** (indigo → magenta) with:
  - A glowing gold coin icon on the left.
  - *"CURRENT BALANCE"* label in white uppercase.
  - The balance number large (e.g., `392`) with the word `coins`.
- **Buy Coins** — full-width gradient button below the hero.
- **Transaction History** title.
- Table-style list with columns **Date · Details · Coins**:
  - Date column left-aligned (`Dec 1`, `Sep 30`).
  - Details column wraps; describes the entry in plain text — e.g., *"Premium subscription renewed for December, 2025 @ 14 coins/month"*, *"For showing contact details to student S-XXXXXX"* (we never show real phone numbers in the ledger), *"Apply to vacancy HTN-00276"*.
  - Coins column right-aligned, **red** for debits (`-14`, `-1`), **green** for credits (`+50`), `0` for free events (admin-mediated reveals, refunds at zero).
- Pagination: infinite scroll; filter chips at top for *All · Spends · Earnings · Top-ups*.
- Source: `wallet_ledger` rows for the current user.

### 4.14c Request a Tutor screen (our take — better than the reference)
The most important student-initiated flow after the map. Layout mirrors the competitor "Request a Tutor" screen exactly:

- Header *"Request a Tutor"* with back arrow.
- **Card 1 — Details of your requirement**
  - Multiline textarea. Placeholder example: *"Hi, I need maths and Hindi tutors online."*
  - **Orange info banner** below: *"⚠ Please don't share any contact details (phone, email, website etc) here."* This is the platform-wide phone-ban warning (see `plan.md` §5.6), rendered as a soft orange-tinted strip with an info icon.
  - Server-side regex still enforces the ban.
- **Card 2 — Location**
  - Pill input with a map-pin icon and the current area label (`Delhi Cantt railway Junction, Kirby Place` in the example; for us, e.g., *Kapan, Faika Chowk*). Tapping opens a map picker; pre-filled from `geolocator`.
- **Card 3 — Phone Number**
  - Pill input with a phone icon. Pre-filled with the student's `+977` verified phone; editable but re-validated.
- **Card 4 — Subjects**
  - Chip multi-select; chips highlight in soft indigo. Suggestions are scoped to the active level.
- **Card 5 — Your Level**
  - Single-select with a graduation-cap icon: Below Class 9 / SEE / +2 / A Level. Pre-filled from `profiles.student_level`.
- (Continuing below in the scrollable form: Schedule / Duration, Salary range, Gender preference, Mode in-person/online, Notes, **Submit**.)
- On submit, this creates a draft `vacancies` row (admin-curated path) **or** a `jobs` row (Upwork-style) depending on a single segmented control at the top of the form. Default: vacancy (admin-mediated), which is the simpler experience for parents.
- On creation, the `notify_matching_tutors` trigger (`plan.md` §5.6a) fires automatically — every matching tutor receives a **"New job posted"** push within seconds, surfacing in their Notifications screen.

### 4.14d My Posts screen (our take — better than the reference)
- Header *"My Posts"* with hamburger menu.
- Sticky gradient **Post Requirement** button across the top — opens §4.14c.
- Scrollable list of cards (one per job/vacancy the student has posted). Each card:
  - **Title** (top-left, bold) — e.g., *"Online Maths teacher needed in Kapan"*.
  - **Status badge** (top-right) — pill outline; *Open* (indigo) / *Shortlisting* (amber) / *Hired* (green) / **Closed** (red) / *Expired* (grey).
  - One-line **description excerpt** under the title.
  - **Price** line (e.g., `Rs. 8,500/month`).
  - **Map-pin row** with the area label.
  - Card footer with two text-link actions: **View Messages** (chat icon, blue) → opens the chat thread for this post if one exists, else lists bids; **Repost** (refresh icon, blue) → relists the post and re-fires the matching-tutors notifications.
- Tap on the card body → §4.14e Post Detail.

### 4.14e Post Detail screen (our take — better than the reference)
- Header *"Post Detail"* with back arrow.
- If the post is closed: a **red alert banner** at the very top — *"This requirement is closed."* (red outline, red exclamation icon).
- Title in large bold (e.g., *"EnCase Home teacher needed in Ludhiana"* → for us, e.g., *"Home Maths teacher needed in Kapan"*).
- Action button row: **View Messages** (chat icon) and **Repost** (refresh icon).
- Subject pill chip (e.g., *EnCase* in the example; for us, *Maths*, *Science*, etc.).
- **Detail card** — rows with leading icons:
  - 📍 Location (area label).
  - 📅 Posted (date).
  - 👤 Requires (Full Time / Part Time / One-off).
  - 👤 Posted by (the student's masked name + handle).
  - 📞 Verified — **never** show a phone number on this screen; show *"WhatsApp verified ✓"* if the student's phone is verified. The actual number is revealed only to a tutor who is hired (admin assignment) or to a student who unlocked the tutor's contact (their own contact is not the privacy gate).
  - 🚻 Gender Preference (None / Male / Female).
  - 📶 Online — *Available online* or *Not available online*.
  - 🏠 Home — *Available for home tutoring* or *Not available for home tutoring*.
  - 🚗 Travel — *Can travel* or *Cannot travel*.
- **Description** section — full `jobs.description` or `vacancies.notes` rendered as plain text (links and phone numbers stripped by the server).

### 4.14f Chat screen (in-app messaging, replicated layout)
Replaces the v1 "contact log" Messages tab with **proper in-app chat** between matched parties (chat only opens after a successful contact unlock or admin assignment — see `plan.md` data model `chat_threads`).

- Header: back arrow + circular avatar + counterparty masked name (`Teacher2 T*`) + overflow menu (Report, Block, Mute).
- Background: light beige to match the reference.
- Date-divider chips down the centerline (e.g., *Aug 1, 2022*, *17 mins ago*).
- Speech bubbles aligned right-for-me, left-for-them; pastel green for both sides (matching the reference).
- Each bubble shows the text, a timestamp underneath (`Aug 1, 2022, 6:08:58 PM`), and a **double-tick** indicator (`✓✓`) — blue when read by the counterparty (read receipt comes from `chat_messages.read_at`), grey when only delivered.
- Bottom: rounded text input *"Type a message…"* + gradient circular **send** button.
- Phone-ban regex applies to every outgoing message (same trigger as job descriptions); offending messages are blocked client-side with an inline error before send, and server-side as a backstop.
- Real names of the counterparty are revealed only inside this thread (since chat presupposes a successful match) — the chat header still uses the masked name to keep behavior consistent across screens, but the avatar tap opens the full unmasked profile.

### 4.14g Create Account screen (replicated layout — "Student/Parents" variant)
A cleaner, less-stepped variant of the registration form (`plan.md` §5.1), matching the reference:
- Top: a back arrow.
- Centered illustration — a circular gradient badge with a *person-plus* icon.
- **Create Account** title (bold) + subtitle *"Fill in your details to get started"*.
- Form card with four inputs:
  - **Role dropdown** — *"Student/Parents"* (default) or *"Tutor"*. Wraps to `profiles.role` (`'student'` covers parents acting on behalf of a child — they pick *"My child"* in the *Who is this for?* step later).
  - **Full Name** (single field; server splits into first/last on the space; or split into two fields per the existing spec — both layouts allowed).
  - **Email** (icon: envelope).
  - **Password** (icon: lock; trailing eye toggle to show/hide).
- **"I accept the terms and conditions"** checkbox with the link styled in indigo. For Tutor role, the Tutors' Code of Conduct checkbox appears as a second line.
- Big gradient **Register** button (indigo → magenta).
- After tap → phone OTP screen (`plan.md` §5.1).

### 4.14 Deep-link landing (web preview)
Opening `htn.app/t/T-A4F7QK`, `htn.app/v/HTN-00276`, or `htn.app/j/J-XXXXXX` without the app installed shows a minimal masked preview (handle, masked name, area, subjects/grade/salary). No real name, no phone. **Open in App** button.

---

## 5. Components (reusable)

Shared with the tutor app (`tutor_UI.md` §5): `TutorCard`, `VacancyCard`, `JobCard`, `PhoneBanWarning`, `MaskedAvatar`, `CoinChip`, `MapPinPicker`, `VerifiedBadge`, `LanguageToggle`.

Student-specific: `TutorCarousel` (bottom sheet), `RadiusChip`, `FilterChipBar`, `MapFAB` cluster.

---

## 6. State management (BLoC)

```
AuthCubit                — login state
LocaleCubit              — NE / EN
StudentOnboardingBloc    — wizard
MapBloc                  — viewport, filters, tutor list, debounced re-query
TutorProfileBloc         — full tutor view
UnlockBloc               — confirm + RPC + post-unlock state
JobsBloc                 — my jobs + new job form
JobDetailBloc            — bids list + actions
VacancyRequestBloc       — request-a-tutor form
MyVacanciesBloc          — my requested vacancies
SavedBloc                — saved tutors + vacancies
MessagesBloc             — contact log
WalletBloc / TopUpBloc   — balance + buy
ProfileBloc              — own profile + settings
NotificationsBloc        — feed
ReviewBloc               — submit review
ContactRevealedBloc      — admin-mediated reveal
```

Repositories injected via `get_it`. Supabase calls hidden behind interfaces.

---

## 7. Permissions

- **Location** (foreground) — required for the map; precise location. Clear rationale screen before the system prompt.
- **Notifications** — for tutor matches and bids.
- Optional: contact picker (only if the student wants to refer friends).

Other users' real names and phone numbers are never embedded in student-facing screens except (a) post-unlock contact panel and (b) admin-mediated Contact-revealed sheet.

---

## 8. Edge cases

- **No tutors in radius** → empty card with *Expand radius* and *Request a tutor* CTAs.
- **Location permission denied** → the map falls back to a city-level default (Kathmandu Valley) with a banner explaining limited results until permission is granted.
- **Insufficient coins to unlock** → bottom sheet shows balance, deficit, and a **Buy coins** CTA.
- **Posted job has no bids after 48 h** → push prompt: *"Want admins to find a tutor for you? Convert this job to a vacancy."*
- **Account suspended / banned** → unlock disabled; banner with appeal WhatsApp link.
- **Offline** → cached map tiles (last viewport) + cached tutor list; unlock and post disabled with offline toast.

---

## 9. Accessibility

- All tap targets ≥ 44 dp.
- WCAG AA contrast on both themes.
- Screen-reader labels on every icon-only button.
- Map pins have a list-view fallback so the screen is usable without spatial vision.
- Both font families tested for Devanagari and Latin at 12 – 28 sp.

---

## 10. Open questions (student-side)

- Should the map default to **Kathmandu Valley** if the user is outside Nepal but has the app open? (Yes — most useful default.)
- Should we show tutors who are **offline** by default with a "Notify when available" CTA? (Probably yes, gated to verified-only to avoid clutter.)
- Should "Saved tutors" be **synced across devices** at launch, or local-first?
- Do we let students **rate the admin/broker experience** when a vacancy fills? (Separate from the tutor review.)
- Should the **Messages** tab eventually host real in-app chat? Out of scope for v1; reconsider after launch.
