# Admin panel — backend contract

This document is the **handover** between the Flutter mobile app (this repo) and the separate Next.js admin panel (see `docs/admin_panel_plan.md`). Phase 12 shipped the **backend hardening** here; the admin panel implements the operator UI against this contract.

## Tables the admin panel reads

| Table | Purpose | Migration |
|---|---|---|
| `profiles` | All users (read) + `suspended_until`/`banned_at` (write via RPC) | 0001 + 0010 |
| `tutors` | Tutor profile + `verified` + `ranking_score` | 0002 + 0008 + 0010 |
| `vacancies` | Admin creates / publishes / closes | 0005 + 0006 |
| `vacancy_applications` | Admin shortlists + hires | 0006 |
| `jobs` | Read-only oversight | 0005 |
| `wallet_ledger` | Audit financials | 0004 |
| `coin_top_ups` | Payment reconciliation | 0009 |
| `audit_events` | Forensic feed | **0010** |
| `moderation_log` | Flag queue | **0010** |
| `verifications` | ID review queue | **0010** |
| `notifications` | Read-only oversight | 0001 |
| `platform_settings` | Runtime config | 0001 |

## RPCs (all `SECURITY DEFINER`, admin-only unless noted)

| RPC | Purpose | Audit type |
|---|---|---|
| `admin_credit(user, delta, reason)` | Manual coin adjustment | (recorded as `wallet_ledger` row + `_audit('AdminCredit',…)` next phase) |
| `admin_suspend_user(user, until, reason)` | Temporary block + system notification | `UserSuspended` |
| `admin_ban_user(user, reason)` | Permanent block | `UserBanned` |
| `admin_unban_user(user)` | Lift restriction | `UserUnbanned` |
| `admin_review_verification(id, approve, reason)` | Approve / reject ID submission; credits `id_verification_bonus` on approve; flips `tutors.verified` | `TutorVerified` or `TutorVerificationRejected` |
| `admin_assign_vacancy(application_id)` | Hire a tutor → contact-revealed notifications to both parties | (Phase 7 — no audit row yet) |
| `admin_set_setting(key, value)` | Edit `platform_settings` with audit | `PlatformSettingChanged` |
| `admin_resolve_moderation(log_id, action, notes)` | Close a moderation entry with action `warn` / `suspend` / `ban` / `dismissed` | `ModerationResolved` |
| `finalize_top_up(id, ref, payload, ok)` | Admin can manually finalize a stuck payment (also called by webhook) | (top-up status change is itself the audit) |
| `recompute_all_tutor_rankings()` | Nightly batch | — |
| `user_report_content(target, field, reason, excerpt)` | User-callable; populates `moderation_log` | — |

## Guarantees enforced by the backend

- **Append-only `audit_events`** — direct writes blocked by trigger; only `_audit(...)` (called inside admin RPCs) succeeds.
- **`account_blocked`** — every money-moving RPC (`unlock_contact`, `tutor_apply_to_vacancy`, `send_chat_message`, plus the existing wallet helpers) checks `_is_blocked(auth.uid())` before any side effect. The mobile app surfaces this via `lib/core/widgets/account_blocked_banner.dart`.
- **Append-only `wallet_ledger`** — direct writes blocked (Phase 5).
- **Notifications fan-out** — every admin RPC that affects a user inserts a row into `notifications`, so the mobile bell badge updates immediately via the existing Realtime channel (Phase 8).
- **Audit trail on settings changes** — `admin_set_setting` records `{key, old, new}` so a value rollback is one query away.

## Suggested admin panel routes (Next.js)

See `docs/admin_panel_plan.md` §4 for the full list. Mapping to this contract:

```
/users               → profiles + admin_suspend_user / admin_ban_user / admin_unban_user
/verifications       → verifications + admin_review_verification
/moderation          → moderation_log + admin_resolve_moderation
/vacancies           → vacancies CRUD + admin_assign_vacancy
/wallet              → wallet_ledger + admin_credit
/settings            → platform_settings + admin_set_setting
/audit               → audit_events (read-only)
```

## Next phases that further harden the backend

- Phase 14 — Sentry, security audit, full RLS review.
- Phase 15 — Beta launch monitoring KPIs (subset of `audit_events` shipped to Looker / Metabase).
