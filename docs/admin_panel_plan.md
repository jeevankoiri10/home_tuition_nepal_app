# Home Tuition Nepal — Admin Panel Plan

> **Product:** Home Tuition Nepal
> **Brand:** KTM academy
> **Admin contact (default, editable in-panel):** `https://wa.me/9779807590455`
> **Companion to:** `docs/plan.md` (mobile app master plan). This document covers the **admin panel** only.

---

## 1. Purpose

The admin panel is the **operator console** for KTM academy staff. It is the only surface where humans can:

- Mediate between students and tutors (the broker workflow).
- Create and manage **Vacancies** (the structured tuition-job posts visible in §3.3 of the main plan).
- Verify tutor identities, review CVs, and gate the verified-badge.
- Audit and adjust the **coin ledger**.
- Moderate user-generated content (descriptions, bios, notes, reviews) — handle phone-in-text violations, suspensions, bans.
- Edit **platform settings** (admin WhatsApp number, coin prices, feature flags) without an app release.
- View analytics — vacancies open vs. filled, contact unlocks per day, top areas, etc.

It is **not** customer-facing. It is for KTM academy operators only.

---

## 2. Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | **Next.js 14+** (App Router) | RSC + server actions, edge-runtime where safe |
| Language | **TypeScript** (strict) | `strict: true`, `noUncheckedIndexedAccess: true` |
| Architecture | **Event-driven clean architecture** | See §3 |
| Backend | **Supabase** (Postgres + Auth + Storage + Edge Functions) | Same project as the mobile app |
| Access control | Postgres RLS + admin-role checks in server actions | Defense in depth |
| Auth | Supabase Auth: email + password + **TOTP (mandatory)** | No SMS-based 2FA for admins |
| UI | **shadcn/ui** + Tailwind | Fast to assemble, accessible, themable |
| State / data | React Server Components + **TanStack Query** (client islands) | Avoid heavyweight global state |
| Forms | **react-hook-form + zod** | Zod is the source of truth — also used in domain validators |
| Tables | TanStack Table | Sortable / filterable for vacancy & application lists |
| Maps | `react-leaflet` + OSM tiles | For vacancy location pick + tutor density heatmaps |
| Charts | Recharts | Analytics |
| Testing | Vitest + Playwright | Unit (use-cases), E2E (auth + critical flows) |
| Observability | Sentry + Supabase logs + a thin `audit_events` table | Forensics |
| Deployment | Vercel | Preview env on every PR; production behind Vercel Access |

---

## 3. Event-Driven Clean Architecture

```
src/
├── domain/                     # framework-free
│   ├── entities/               # Vacancy, Application, Tutor, Student, WalletLedger, ...
│   ├── value-objects/          # VacancyCode, NprAmount, PhoneE164, AreaLabel, ...
│   ├── events/                 # VacancyCreated, ApplicationShortlisted, TutorVerified, ContactRevealed, CoinsRefunded, UserSuspended, ...
│   ├── services/               # pure domain logic (e.g., VacancyCodeGenerator)
│   └── ports/                  # interfaces only: VacancyRepo, EventBus, NotificationGateway, AuditLog
├── application/                # use-cases (orchestrators)
│   ├── vacancies/
│   │   ├── CreateVacancy.ts
│   │   ├── PublishVacancy.ts
│   │   ├── CloseVacancy.ts
│   │   └── AssignTutorToVacancy.ts
│   ├── moderation/
│   │   ├── ReviewModerationFlag.ts
│   │   ├── SuspendUser.ts
│   │   └── BanUser.ts
│   ├── wallet/
│   │   ├── ManualCredit.ts
│   │   ├── ManualDebit.ts
│   │   └── RefundCoins.ts
│   ├── verification/
│   │   ├── ApproveTutorVerification.ts
│   │   └── RejectTutorVerification.ts
│   └── settings/
│       └── UpdatePlatformSetting.ts
├── infrastructure/             # adapters that implement domain ports
│   ├── supabase/               # SupabaseVacancyRepo, SupabaseWalletRepo, ...
│   ├── storage/                # CV PDF storage
│   ├── eventBus/               # in-process bus (v1) → Postgres LISTEN/NOTIFY (v2)
│   ├── notification/           # OneSignal/FCM client, WhatsApp deep-link helper
│   └── audit/                  # writes domain events to audit_events table
└── interface/                  # Next.js — thin wrappers
    ├── app/                    # App Router routes
    │   ├── (auth)/login
    │   ├── (admin)/dashboard
    │   ├── (admin)/vacancies
    │   ├── (admin)/applications
    │   ├── (admin)/users
    │   ├── (admin)/moderation
    │   ├── (admin)/wallet
    │   ├── (admin)/settings
    │   └── api/webhooks/...
    └── server-actions/         # `"use server"` — call use-cases, never repos directly
```

### 3.1 Rules of dependency
- **Inward only.** `domain` knows nothing of `infrastructure` or Next.js. `application` depends on `domain` ports only. `infrastructure` and `interface` implement / consume.
- **Use-cases are pure orchestrators** — they receive DTOs, call ports, emit events, return DTOs.
- **No Supabase client imports outside `infrastructure/`.**
- **No `process.env` reads outside `infrastructure/`** (use a `Config` port).
- **Domain events are first-class** — every state-changing use-case emits at least one event. Side effects subscribe.

### 3.2 Event bus
- **v1: in-process** synchronous bus (a typed `EventEmitter` wrapper). Subscribers run inside the same request → simple, transactional with Supabase via `BEGIN/COMMIT`.
- **v2 (when needed):** **Postgres `LISTEN/NOTIFY`** — emit events to a `domain_events` table, workers (Vercel cron / Supabase Edge Functions) consume them. Lets us scale push, analytics, refunds, etc., independently.

### 3.3 Audit log
- Every emitted event is **also** persisted to an `audit_events` table:
  ```sql
  audit_events (
    id           uuid primary key default gen_random_uuid(),
    type         text not null,            -- 'VacancyCreated'
    actor_id     uuid,                     -- admin user
    target_type  text,                     -- 'vacancy' | 'profile' | ...
    target_id    uuid,
    payload      jsonb not null,
    occurred_at  timestamptz default now()
  )
  ```
- Enables forensic replay, support cases, and analytics.

---

## 4. Routes & Pages

```
/login                                     — email + password + TOTP
/                                          — dashboard (KPIs, latest events)
/vacancies                                 — list + filters (status, area, grade, gender, date)
/vacancies/new                             — create form (location picker on map)
/vacancies/[code]                          — detail (HTN-00276); applications list; assign tutor
/applications                              — global applications view across vacancies
/applications/[id]                         — one application (CV preview, tutor profile snippet)
/users                                     — search students & tutors by handle / phone / public code
/users/[publicCode]                        — user detail; verify ID; suspend; ban; ledger
/moderation                                — queue of flagged content (phone-in-text, abuse reports)
/moderation/[id]                           — review & decide (warn / suspend / ban)
/wallet                                    — global ledger; manual credit/refund (with reason)
/settings                                  — platform_settings editor (admin_whatsapp, coin prices, feature flags)
/settings/admins                           — admin user management (superadmin only)
/analytics                                 — charts: vacancies open/filled, unlocks/day, top areas, coin flow
/audit                                     — searchable audit_events feed
```

---

## 5. Capabilities (by screen)

### 5.1 Dashboard (`/`)
- KPI cards: vacancies open today / filled today / total open / total filled this month; new tutors today; new students today; coin top-ups (NPR) today.
- Live activity feed (last 50 `audit_events`).
- Map: tutor density heatmap (PostGIS aggregation).
- Quick actions: **Create vacancy**, **Open moderation queue**, **Search by code**.

### 5.2 Vacancies (`/vacancies`)
- Table with: `code`, `area`, `grade`, `subjects`, `salary`, `gender_pref`, `applications_count`, `status`, `created_at`.
- Filters: status, area autocomplete, grade, subject, gender, date range.
- Inline status changes via popover (`open` → `applications_closed` → `filled`).
- Bulk close (multi-select).

### 5.3 Create / edit vacancy (`/vacancies/new`)
Mirrors the structured fields documented in `plan.md` §3.3:
- Title (auto-suggested from area + role).
- Location: free-form **`area_label`** ("Kapan, Faika Chowk") + **map pin** (react-leaflet) → stored as PostGIS `geog`.
- Number of students (default 1).
- Grade / class.
- Subjects (multi-select with free-text "Other").
- Duration / time (free-form text + optional structured start/end time).
- Frequency: per-month / per-week / one-off.
- Salary: min/max NPR + period (month/hour/session).
- Gender pref: Any / Male / Female.
- Mode: in-person / online / either.
- Notes (free-text; phone-number ban applied here too).
- **Linked student** (optional): pick from registered students or leave blank if vacancy was raised off-app.
- On save:
  - Generate next sequential `code` (`HTN-NNNNN`, atomic via DB sequence).
  - Emit `VacancyCreated`.
  - Optional: emit `VacancyPublished` to push-notify matching tutors (matched by area + subjects + gender prefs).

### 5.4 Vacancy detail (`/vacancies/[code]`)
- Header: code, title, status badge.
- Tabs: **Overview** | **Applications** | **Audit**.
- Overview: full field block + edit button.
- Applications: list of `vacancy_applications` for this vacancy with CV preview (Supabase Storage signed URL), tutor profile snippet (masked name + handle + rating), expected rate, applied-at; per-row actions: **Shortlist**, **Reject**, **Hire** (= assign).
- **Hire** runs `AssignTutorToVacancy` use-case → flips application status, sets `vacancies.filled_by_tutor`, vacancy status → `filled`, emits `ApplicationShortlisted`/`TutorHired`/`ContactRevealed` events that:
  - Push-notify the student and tutor.
  - Insert a `contact_unlocks` row (admin-mediated; no coin debit).
- Audit tab: filtered `audit_events` feed for this vacancy.

### 5.5 Applications (`/applications`)
- Global view across all vacancies; useful for triage.
- Filters: status, vacancy code, tutor handle.

### 5.6 Users (`/users`)
- Search by handle, public code (`T-A4F7QK`, `S-9BG2HM`), phone, email.
- Per-user detail page:
  - **Identity:** real name, masked name preview, public code, photo, phone, email, role (`student` | `tutor`), language, area.
  - **Verification:** ID doc previews (signed URL, expiring); **Approve** / **Reject** with reason → emits `TutorVerified` / `TutorVerificationRejected`.
  - **Activity:** contact unlocks (in/out), vacancy applications, bids, reviews given/received.
  - **Wallet ledger** for this user.
  - **Moderation history:** prior flags, suspensions.
  - **Danger zone:** suspend (with duration + reason), ban (permanent).

### 5.7 Moderation queue (`/moderation`)
- Rows: flagged content from `moderation_log` (phone-in-text, email-in-text, abuse reports).
- Per-row: excerpt with offending span highlighted, user, prior offense count.
- Actions: **Warn (no ban)**, **Suspend 7 days**, **Ban**, **Mark as false positive** (improves regex tuning).
- Each action emits `UserWarned` / `UserSuspended` / `UserBanned`.

### 5.8 Wallet (`/wallet`)
- Global ledger: paginated `wallet_ledger` feed with filters by `reason`, `user`, `date`.
- Per-row link to user's full ledger.
- **Manual credit** / **Manual debit** / **Refund**: form requires a reason (free-text) and an admin password re-prompt; emits `CoinsAdjusted` with the reason.
- Top-up monitoring: pending eSewa / Khalti / IME Pay webhook events.

### 5.9 Settings (`/settings`)
- Form-backed editor for `platform_settings` rows:
  - `admin_whatsapp` (default `https://wa.me/9779807590455`).
  - Coin prices: `bid_coin_cost_base`, `unlock_coin_cost`, `featured_listing_cost`, etc.
  - Earning amounts: `signup_bonus`, `profile_completion_bonus`, `referral_reward`, ...
  - Coin pack pricing (display only; actual prices configured in payment processor).
  - Feature flags: `enable_map_view`, `enable_job_board`, `enable_vacancies`, `enable_topups`.
  - Default UI language for new accounts (`ne` or `en`).
  - Vacancy code prefix (`HTN-`).
- Every save emits `PlatformSettingChanged` + writes to `audit_events`.
- Clients re-fetch settings on app launch (cached fallback for offline).

### 5.10 Admin user management (`/settings/admins`) — superadmin only
- Invite by email (creates Supabase Auth user with mandatory TOTP enrollment on first login).
- Assign role: `superadmin` | `operator` | `moderator`.
- Revoke access.

### 5.11 Analytics (`/analytics`)
- Vacancies opened / filled per week (line).
- Time-to-fill (histogram).
- Contact unlocks per day, split by map vs. job vs. vacancy (stacked area).
- Coin flow: top-ups vs. spends per day.
- Top areas (table).
- Top subjects (table).
- Tutor verification funnel.

### 5.12 Audit log (`/audit`)
- Search/filter `audit_events` by type, actor, target, date.
- Click into any event to see full JSON payload.

---

## 6. Auth & Access Control

- **Supabase Auth** with email + password + **mandatory TOTP** for every admin user. No SMS 2FA.
- **`admin_users` table** mirrors `auth.users` with a `role` column (`superadmin` | `operator` | `moderator`).
- Middleware (`middleware.ts`) checks:
  1. Authenticated.
  2. `admin_users` row exists for the user.
  3. Role permitted for the route (route → required role mapping in a small map).
- Server actions repeat the check (never trust middleware alone).
- IP allowlist optional (Vercel Firewall / Supabase row policy).
- Session length: 8 hours; idle timeout 30 min.

**Role matrix:**

| Capability | Moderator | Operator | Superadmin |
|---|:---:|:---:|:---:|
| View vacancies / applications | ✓ | ✓ | ✓ |
| Create / edit vacancy | | ✓ | ✓ |
| Assign tutor to vacancy | | ✓ | ✓ |
| Verify tutor ID | | ✓ | ✓ |
| Moderate content (warn/suspend) | ✓ | ✓ | ✓ |
| Ban user | | ✓ | ✓ |
| Wallet manual credit/debit/refund | | ✓ | ✓ |
| Edit platform settings | | | ✓ |
| Manage admins | | | ✓ |

---

## 7. Notifications (out of the panel)

Whenever an event implies a user-facing notification, the panel emits the domain event and a notification subscriber sends the message:
- **Application shortlisted / hired** → push + in-app + email (if subscribed) — both Nepali & English templates per the recipient's `profiles.language`.
- **Vacancy published** → push to matched tutors.
- **Suspension / ban** → push + email (with appeal link).
- **Verification approved / rejected** → push.
- **Coin top-up confirmed / failed** → push.

Templates live in a small `notification_templates` table editable in settings (NE/EN side by side).

---

## 8. Data the panel owns / shares

The panel reuses the schema in `plan.md` §7. The admin-specific tables (`admin_users`, `audit_events`, `platform_settings`, `notification_templates`) live in the same Supabase project.

Sensitive reads (`real_name`, `phone`, `id_docs`, exact `geog`) bypass RLS via `service_role` server-side **only inside server actions / route handlers**, never exposed to the browser.

---

## 9. Security

- TOTP mandatory; no password reset over email without a second factor.
- All admin actions are **audited** (`audit_events`).
- All sensitive reads server-side; **never send `real_name` or `phone` to the browser** unless the page explicitly needs it (e.g., user-detail page; redacted by default with a "Reveal" button that re-logs the access).
- Storage buckets: `id_docs` and `cvs` are **private**; admin views via short-lived signed URLs (5 min).
- Rate-limit risky actions (manual credit > N coins requires superadmin co-sign).
- CSRF: Next.js server actions are CSRF-protected by default; double-check on raw API routes.
- Content Security Policy: strict; only Supabase + Sentry + Vercel domains.

---

## 10. Build Order / Milestones

- **A0 — Skeleton (week 1)**: Next.js + TS strict, Supabase client wired, Tailwind + shadcn/ui, auth middleware, role-based routing, audit-event scaffolding, in-process event bus.
- **A1 — Vacancies (week 2)**: List + filters, create/edit form (with map picker), code generator, `VacancyCreated` event, push to matched tutors.
- **A2 — Applications (week 3)**: Applications list, CV preview via signed URLs, shortlist / reject / hire flow, `AssignTutorToVacancy` use-case, contact-reveal side effect.
- **A3 — Users + verification (week 4)**: User search, detail, ID verification, suspend/ban, ledger view.
- **A4 — Moderation queue (week 5)**: `moderation_log` consumer, action UI, regex-tuning feedback loop ("false positive").
- **A5 — Wallet ops (week 6)**: Global ledger view, manual credit/debit/refund with mandatory reason and admin re-auth.
- **A6 — Settings (week 7)**: `platform_settings` editor (start with `admin_whatsapp`), coin prices, feature flags, notification templates (NE/EN).
- **A7 — Analytics + audit (week 8)**: Dashboard KPIs, charts, searchable audit feed.
- **A8 — Hardening (week 9)**: Playwright E2E, Sentry wiring, IP allowlist, role matrix review, security audit, deploy to production with Vercel Access.

---

## 11. Open Questions

- Do operators need a **mobile-friendly responsive** view, or is desktop-only acceptable? (Probably desktop-only for v1.)
- Should ID document storage be **server-side encrypted at rest** with a separate KMS, or is Supabase Storage's default encryption enough?
- WhatsApp **Business API** integration for outbound messages, or do we keep WhatsApp as a user-initiated link only (current plan)?
- Multi-tenant — will we ever need to host other tutoring brands on the same admin panel, or is KTM academy single-tenant for the foreseeable future? Single-tenant is the default assumption.
- Should `audit_events` retention be **forever** (small JSON rows; cheap) or tiered to cold storage after 12 months?
