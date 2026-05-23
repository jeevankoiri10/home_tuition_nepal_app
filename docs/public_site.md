# Home Tuition Nepal — Public / Marketing Site

> **Product:** Home Tuition Nepal · **Operator:** KTM academy
> **Surface:** Web (Next.js, SSR-friendly, SEO-first) at the deep-link domain (`htn.app` or `homenepal.app`).
> **Companion to:** `docs/plan.md`, `docs/admin_panel_plan.md`, `docs/tutor_UI.md`, `docs/student_UI.md`, `docs/tutor_code_of_conduct.md`.
> **Inspiration:** the public-marketing layout patterns used by TeacherOn (homepage hero, segmented search, stats strip, long subject directory, deep footer of static info pages) — adapted to our locality-first, Nepal-only positioning and our masked-name / no-payment privacy model.

---

## 1. Purpose

A lightweight public website that exists alongside the mobile app to:
- Acquire users (tutors and students) via SEO and shareable deep-links.
- Host marketing content — *what we are, how it works, safety, pricing, terms.*
- Render the **masked** previews for shared deep links (`/t/T-XXXXXX`, `/v/HTN-NNNNN`, `/j/J-XXXXXX`, `/s/S-XXXXXX`).
- Provide app-store install buttons.
- Provide a public, **searchable, locality-first directory** of (masked) tutors so SEO traffic lands on real value pages.

**Hard constraint:** real names, real phone numbers, exact addresses, and ID documents **never** appear on any public page. Every directory and deep-link page uses masked names (`Ramesh S*`), area labels, and the contact-unlock flow only inside the app.

---

## 2. Information architecture

**Top nav:**
- **Find Tutors** — locality-first directory (mirrors the in-app map / list but masked & SEO-friendly).
- **Vacancies** (`HTN-NNNNN`) — public-readable list of admin-curated vacancies; applying requires login in-app.
- **Request a tutor** — short web form that creates a draft vacancy for admin review.
- **Become a tutor** — explainer + register CTA.
- **Help** — static info pages (see §6).
- **Login / Register** — opens the same email+password flow used in the app.

**Top right:** *Get the app* (Play Store + App Store badges), language toggle (नेपाली / English).

---

## 3. Homepage

**Hero**
- Headline: *"Search tutors in your locality — across Nepal."*
- Sub-headline: *"Home Tuition Nepal by KTM academy. Free to browse, free to register. Find verified home tutors and online teachers near you."*
- **Big search bar**:
  - Subject / Skill (autocomplete from `top_subjects` view).
  - Location (autocomplete: province → city → area; defaults to the user's geo-IP city).
  - Segmented control: **All Teachers · Home Teachers · Online Teachers · Vacancies**.
  - **Search** button.
- A pair of secondary CTAs underneath:
  - **Find a tutor** (students) → `/find-tutors`.
  - **Become a tutor** (tutors) → `/become-a-tutor`.

**Quality strip**
- A short row of trust signals — masked names, no leaked phone numbers, verified-ID badge, Code-of-Conduct accepted by every tutor. (Adapted from TeacherOn's *"Only 55.1% of teachers that apply make through our application process"* idea, but framed around our verification and conduct gates, not exam-pass rates we don't have.)

**Stats (refreshed nightly from Postgres)**
- *N+ active tutors* across Nepal.
- *N+ Vacancies filled this month.*
- *N+ subjects covered.*
- *Coverage: 7 provinces, N+ cities, N+ wards.*

(Compute as a nightly `public_stats` view; cache in CDN for 24 h.)

**How it works strip** — three columns:
1. *For students* — Pick your level → see tutors near you → unlock contact with coins. ([Read more](#how-it-works-students))
2. *For tutors* — Register → build your profile → apply to vacancies and jobs ([Read more](#how-it-works-teachers)).
3. *For parents looking for a vacancy* — Request a tutor → admin matches you with a vetted teacher.

**Top subjects directory** (SEO)
A long, hyperlinked, alphabetized list of top subjects/skills (Maths, Science, Physics, Chemistry, English, Nepali, Accountancy, Computer Science, IELTS, SEE prep, +2 prep, A-Level subjects, etc.). Each link routes to `/find-tutors?subject=<slug>`. Helps land long-tail Google traffic.

**Top locations directory** (SEO)
A vertical list grouped by province → city → ward / chowk: *Bagmati > Kathmandu > Baneshwor*, *Bagmati > Lalitpur > Kupandole*, *Gandaki > Pokhara > Lakeside*, …. Each link routes to `/find-tutors?area=<slug>`.

**Footer with install badges** (Play Store + App Store).

---

## 4. /find-tutors (public directory)

**Filter rail (left, sticky on desktop; modal on mobile):**
- Subject / Skill.
- Level (Below Class 9 / SEE / +2 / A Level / *All levels*).
- Location (province → city → area).
- Online / Offline / Both.
- Price range.
- Gender preference.
- Verified-only toggle.

**Result list** — TeacherOn-style cards. Each card shows:
- Avatar (left).
- **Masked name** + verified badge + handle (e.g., *"Ramesh S* · T-A4F7QK"*).
- 2–4 subject tags pulled from `tutor_offerings.subject` for the active level filter.
- Bio excerpt (`about_me`, truncated to ~3 lines with `…`).
- Bottom metadata row, comma-separated:
  - Area / province label (clickable).
  - **Price** rendered flexibly per `tutor_offerings.price_period`: `रू6,000–10,000/month`, `रू400/hour`, `रू850–1,500/day`, `रू3,000 fixed`.
  - **Offline experience** (`X.X yr.` — from `tutors.experience_offline_years`).
  - **Online experience** (`X.X yr.` — from `tutors.experience_online_years`).
  - **Distance** (`N km`) when the visitor's location is known.
- Tap → tutor public profile page `/t/T-XXXXXX` (masked profile).

Pagination + sort (Distance / Price / Rating / Newest).

---

## 5. /t/T-XXXXXX (public tutor profile — masked)

Same content as the in-app tutor profile (§4.4 of `student_UI.md`) but rendered server-side for SEO, with:
- **Real name never present.** Title tag uses the handle + subjects: `<title>Maths & Science tutor in Baneshwor — Home Tuition Nepal</title>`.
- `<meta name="robots" content="index,follow">` is fine because nothing identifying is exposed.
- The header CTA is **Open in App to Book** (deep link to mobile app); a fallback **Open the app to view contact** if the visitor isn't logged in.
- ABOUT ME / ABOUT MY SESSIONS / QUALIFICATIONS sections.
- Subjects Offered table.
- Weekly availability grid.
- Reviews (paginated, masked-student-name).
- Sticky bottom CTA: **Open in App** (Android App Link / iOS Universal Link) — never reveals phone in the browser.

`/s/S-XXXXXX`, `/v/HTN-NNNNN`, `/j/J-XXXXXX` follow the same masked-preview pattern (see `plan.md` §7a).

---

## 6. Static / info pages (footer)

Mirroring TeacherOn's footer architecture but rewritten for Nepal + our model:

**Resources**
- **About us** — what KTM academy is, the platform's mission, locality-first promise.
- **How it works — for students** — full walkthrough of the student funnel (browse map → unlock contact → off-platform contact).
- **How it works — for teachers** — mirrors `docs/tutor_code_of_conduct.md` → *"Become a tutor"* section.
- **Stay safe** — safety guidelines for both parties: meet in safe locations, never share OTPs, never pay before the first session, report misconduct via admin WhatsApp.
- **Coins & pricing** — explains the coin system, current default costs (synced live from `platform_settings`), how to earn vs. buy, packs and prices in NPR via eSewa / Khalti / IME Pay. Reinforces: **the platform does not handle tuition payments** — coins are for in-app access only.
- **Refer & earn coins** — the referral reward (30 coins per signup, per `plan.md` §4.2). Generates a per-user referral link.
- **Pay teachers** — guidance for parents on paying tutors directly (off-platform): cash, eSewa, Khalti, bank — and what's a fair monthly rate per level.
- **Blog** — slow-burn content marketing (study tips, exam-prep guides, parent advice).
- **FAQs** — top 20 questions for students and tutors.
- **Learning Mind 💥** — *(optional)* a section featuring student / tutor stories.

**For teachers**
- **Get paid** — off-platform payment guidance.
- **Premium membership** — paid tier (future): boosted ranking, unlimited free applies for a month, extra featured slots. Maps to `tutors.premium_until`.
- **Online teaching guide** — best practices for online tutors (tools, WhatsApp call etiquette, screen-share apps).
- **How to get jobs** — practical advice on profile completion, response times, applying smartly.
- **Applying to jobs** — explains the coin cost (`platform_settings.apply_coin_cost`) and tips.
- **Teacher Rankings** — public leaderboard (top-rated, top-verified, most-active) sorted by `tutors.ranking_score`. **Only the masked handle and stats** appear — no real names.

**Help and Feedback**
- **Testimonials** — masked-name quotes from students and tutors.
- **Contact us** — opens WhatsApp at `platform_settings.admin_whatsapp` (default `https://wa.me/9779807590455`).
- **Refund policy** — coin purchases are non-refundable (per ToS); off-platform tuition disputes are not the platform's responsibility but admin will help mediate.
- **Privacy policy** — data we collect, how we protect masked identity, our retention policy, GDPR-style rights, contact for data requests.
- **Terms** — the legal terms.

**Footer baseline**
- *© KTM academy. Home Tuition Nepal. All rights reserved.*
- App store badges.
- Language toggle (नेपाली / English) duplicated.

---

## 7. SEO / privacy invariants

- All public pages: `Robots: index, follow` **except** any page that contains a UUID, an unmasked name, an unmasked phone number, or any document URL — those are `noindex, nofollow` and access-gated.
- `<title>` and OG metadata never include real names; always use handle + subjects + area.
- Structured data (`schema.org/Person` for tutors): name field set to **handle**, not real name; address narrowed to the area label only.
- Sitemap.xml lists `/find-tutors`, `/find-tutors?area=*`, `/find-tutors?subject=*`, `/t/*` (masked), `/v/*` (masked), `/how-it-works-*`, `/stay-safe`, `/coins-pricing`, etc.
- All API routes used by the public site return **only** masked fields. Any unmasked field requires an in-app authenticated session.

---

## 8. Tech notes

- Same Next.js + TypeScript codebase as the admin panel? — **No**: a separate public-facing Next.js app, deployed to its own domain. The admin panel stays on a private domain behind Vercel Access. Both share Supabase as the backend.
- The public app uses the **Supabase anon role** with strict RLS that only exposes masked / public columns.
- ISR for `/find-tutors`, `/t/*`, `/v/*` pages with 1-hour revalidation; on-demand revalidate from the admin panel when content changes.
- Image optimization through Next.js `<Image>` (Supabase Storage public URLs for avatars only).

---

## 9. Open questions

- Should the public directory **default to all of Nepal** or **detect the visitor's city via IP** and default the location filter? (Probably IP-detect with a clear "change" affordance.)
- Should we keep an **Assignment help** vertical alongside home tuition (TeacherOn has it), or focus exclusively on home-tuition in v1? *Current default: support via `jobs.job_type='assignment_help'` (with a `due_date`) but don't market it prominently until home-tuition is proven.*
- Premium membership pricing — coin-purchasable or fiat-purchasable? Probably fiat (via eSewa / Khalti) since it's a paid tier.
