# Home Tuition Nepal — Project Conventions for Claude

> Brand: **Home Tuition Nepal** by **KTM academy**
> Stack: Flutter (mobile app), Supabase (backend), Next.js + TypeScript (admin panel — separate codebase, see `docs/admin_panel_plan.md`).

## Non-negotiable rules

1. **Always write clean code.**
   - Clear, descriptive names — no abbreviations unless industry-standard.
   - Single responsibility per file / class / function. If a widget or function does two things, split it.
   - No dead code, no commented-out blocks left behind, no `TODO` without a tracking note.
   - No magic numbers or hard-coded strings in UI — use constants, theme tokens, and `AppLocalizations` (NE/EN).
   - Format on save (`dart format`). Lint must be green (`flutter analyze`) before any commit.
   - Small, focused commits. Each commit compiles and passes tests.

2. **Always use reusable components.**
   - Before writing a new widget, search `lib/` for an existing one that fits — extend or generalize before duplicating.
   - Shared widgets live in `lib/widgets/` (or a feature's `widgets/` subfolder when feature-scoped).
   - Every recurring UI pattern in the app (cards, chips, sheets, dialogs, form inputs, empty states, loading skeletons) must be a reusable component — not copy-pasted.
   - Canonical shared components (defined in `docs/tutor_UI.md` §5 and `docs/student_UI.md` §5): `TutorCard`, `VacancyCard`, `JobCard`, `PhoneBanWarning`, `MaskedAvatar`, `CoinChip`, `MapPinPicker`, `VerifiedBadge`, `LanguageToggle`, `TutorCarousel`, `RadiusChip`, `FilterChipBar`. Reuse these rather than inventing parallel versions.
   - Theme, colors, text styles, spacing — pulled from a single `AppTheme` / design-token source, never inlined.

## Architecture references

- App master plan: `docs/plan.md`
- Admin panel plan: `docs/admin_panel_plan.md`
- Tutor UI spec: `docs/tutor_UI.md`
- Student UI spec: `docs/student_UI.md`
- Prompt log: `docs/my_prompt.md`

## Stack expectations

- **State management:** `flutter_bloc` (BLoC / Cubit). Repositories injected via `get_it`. No `setState` for anything beyond local widget state.
- **Localization:** `flutter_localizations` + `intl` with `app_en.arb` and `app_ne.arb`. **No hard-coded UI strings.** Lint check enforces this.
- **Maps:** `flutter_map` + OpenStreetMap tiles.
- **Backend:** `supabase_flutter`. All DB access via repository interfaces — no direct Supabase calls in BLoCs or widgets.
- **Privacy invariants:**
  - Real names never shown publicly; UI always uses masked names (`Ramesh S*`).
  - Phone numbers revealed only via the unlock RPC (server-side).
  - Free-text inputs show the **phone-ban warning** (`PhoneBanWarning`) and validate against phone-number patterns before submit.

## Code review checklist (apply before completing any task)

- [ ] No hard-coded strings? Everything is via `AppLocalizations`.
- [ ] No duplicated widgets — reused or extended existing components.
- [ ] No direct Supabase calls outside a repository.
- [ ] BLoC events / states named clearly, no leaking implementation details.
- [ ] Theme tokens used for color / spacing / typography.
- [ ] Masked-name and phone-ban invariants intact.
- [ ] `flutter analyze` clean.

## What to ask before changing

- Anything that touches the **map view** — it's the headline feature; preserve the inDrive-style interaction model documented in `docs/student_UI.md` §4.3.
- Anything that touches the **coin ledger** — must remain server-authoritative; never trust client balance.
- Anything that touches **identity privacy** — masking and contact-unlock gates must remain intact end-to-end.
