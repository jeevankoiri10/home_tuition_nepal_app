# Public site — backend contract

Handover between the Flutter mobile app (this repo) and the **public marketing site** (separate Next.js codebase per `docs/public_site.md`). Phase 13 shipped the **anon-readable backend** the site queries plus the Android App Links wiring. The Next.js codebase implements the UI against this contract.

## Anon access surface

The public site connects to Supabase with the **anon key** (no auth required). RLS guarantees that only the masked / public surfaces below are reachable.

### Tables — none directly

The public site **must not** query `profiles`, `tutors`, `tutor_offerings`, `wallet_ledger`, `chat_messages`, `vacancy_applications`, etc. directly. All anon access goes through the view + RPCs below.

### View

| Name | Returns | RLS / grants |
|---|---|---|
| `public_tutors_directory` | `public_code`, `handle`, `masked_name` (`Firstname L*`), `tagline`, `area_label`, `city`, `zone`, `teaching_mode`, `levels_taught[]`, `languages_known[]`, `verified`, `rating`, `rating_count`, `experience_offline_years`, `experience_online_years`, `ranking_score`, `top_subjects[]` (up to 5), `from_price_npr`, `from_price_period` | `grant select to anon, authenticated`. Excludes drafts. **Never** exposes real names / phones / exact addresses / document URLs. |

### RPCs

| Name | Params | Returns | Notes |
|---|---|---|---|
| `public_get_tutor(code)` | `text` | row from `public_tutors_directory` | for `/t/T-XXXXXX` pages |
| `public_search_tutors(subject, area, level, mode, limit)` | nullable filters | rows from `public_tutors_directory` ordered by `ranking_score` then `rating` | for `/find-tutors` |
| `public_get_vacancy(code)` | `text` (`HTN-NNNNN`) | masked vacancy fields (status `open` / `applications_closed` / `filled` only) | for `/v/HTN-NNNNN` |
| `public_homepage_stats()` | — | `jsonb` with `tutors_active`, `tutors_verified`, `vacancies_open`, `vacancies_filled_30d`, `subjects_covered`, `languages_covered`, `areas_covered` | hero strip |

## Public codes

Every shareable entity has a short, URL-safe, immutable public code (in addition to its internal UUID):

| Entity | Pattern | Example |
|---|---|---|
| Tutor | `T-XXXXXX` (6 base32) | `T-A4F7QK` |
| Student | `S-XXXXXX` | `S-9BG2HM` |
| Vacancy | `HTN-NNNNN` (zero-padded sequence) | `HTN-00276` |
| Job | `J-XXXXXX` | `J-7K3PWE` |

Codes are auto-assigned by Postgres triggers (`_assign_profile_code`, `_assign_job_code`, `assign_vacancy_code`). Existing rows were back-filled by the Phase 13 migration.

## URL scheme

The site lives at `https://htn.app` (or your chosen domain). Routes the Next.js codebase serves:

```
/                      ← homepage (hero + search + stats + top subjects)
/find-tutors           ← public_search_tutors(...) → SSR list
/t/T-XXXXXX            ← public_get_tutor(code)
/v/HTN-NNNNN           ← public_get_vacancy(code)
/s/S-XXXXXX            ← static "Open in app to view" page (no public data)
/j/J-XXXXXX            ← static "Open in app to bid" page (no public data)
/become-a-tutor        ← static marketing + deep-link to register
/request-a-tutor       ← form → POST /api/request-tutor → creates a vacancy in pending_admin_review status (server-side using service_role)
/help                  ← static (about / stay-safe / coins-pricing / pay-teachers / faqs / blog / refund / privacy / terms)
```

## Deep links into the mobile app

### Android App Links (already wired)

`AndroidManifest.xml` declares an `<intent-filter android:autoVerify="true">` for `/t/`, `/s/`, `/v/`, `/j/` on `htn.app`. The site **must** host the Digital Asset Links file at:

```
https://htn.app/.well-known/assetlinks.json
```

Contents (replace SHA-256 with the production signing certificate fingerprint):

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "app.htn.home_tuition_nepal",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:..."
      ]
    }
  }
]
```

With this file present, every `htn.app/t/...` / `/v/...` link opens the app silently (no chooser) on Android 12+ when installed; otherwise falls back to the site.

### iOS Universal Links (to be wired during iOS build)

Configure `Runner/Runner.entitlements` with `com.apple.developer.associated-domains` set to `applinks:htn.app`. Then the site hosts:

```
https://htn.app/.well-known/apple-app-site-association   (no extension, MIME application/json)
```

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.app.htn.home_tuition_nepal",
        "paths": ["/t/*", "/s/*", "/v/*", "/j/*"]
      }
    ]
  }
}
```

## SEO / privacy invariants the site MUST honour

- `<title>` and OG metadata use the handle (`Tutor #A4F7QK`) and subjects — **never** the real name.
- `schema.org/Person` JSON-LD uses `name = handle`, `address.addressLocality = area_label` (never `address_line`).
- Every page that contains a UUID, an unmasked name, an unmasked phone, or a document URL is `noindex, nofollow` and access-gated.
- `robots.txt` allows: `/`, `/find-tutors`, `/find-tutors?*`, `/t/*`, `/v/*`, `/become-a-tutor`, `/help/*`. Disallows: `/s/*`, `/j/*`, `/api/*`.
- `sitemap.xml` (generated daily by a Vercel cron) includes one entry per row in `public_tutors_directory` + per published vacancy + the static pages.

## Telemetry

The site should send anonymised page-views to the same observability stack used by the mobile app (suggested: PostHog or Plausible). **Never** ship masked names or codes to the analytics provider in URL paths — strip to `/t/[code]` / `/v/[code]` placeholders.

## Local dev

The public Next.js codebase reads `SUPABASE_URL` + `SUPABASE_ANON_KEY` from its own `.env.local`. With those set and the migration applied, every contract above works against your dev / staging project.
