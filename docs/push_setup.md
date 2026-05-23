# Push notifications — wiring guide

Phase 8 shipped the **in-app feed** (Notifications screen, real-time Supabase channel for inserts, bell badge in every AppBar). Remote OS push (FCM / OneSignal) is intentionally **not** wired by default because it requires platform credentials. Follow these steps once you have them.

## Choice: FCM directly or OneSignal

| | FCM directly | OneSignal |
|---|---|---|
| Setup time | medium (google-services.json + APNs cert) | low (single dashboard) |
| Cost | free | free tier; paid for advanced segmentation |
| Vendor risk | none | depends on OneSignal |
| Recommended | default | if non-engineers will run campaigns |

Both flows hand the push to `flutter_local_notifications` on receipt so the user gets a system-tray banner even when the app is backgrounded or terminated.

## Server-side fan-out (already in SQL)

The `notify_matching_tutors()` trigger from `0005_phase6_jobs_vacancies.sql` already inserts a `notifications` row for every matching tutor when a job or vacancy opens. To extend this into a real push:

1. Add a small **Supabase Edge Function** `push_dispatcher` triggered by `AFTER INSERT ON notifications` via `pg_net` (or via the Database Webhooks UI in Supabase studio).
2. The function reads the row, looks up the user's push token, and POSTs to FCM or OneSignal's REST API.
3. Push tokens are stored in a new column `profiles.push_token` (add it in a future migration) — the Flutter app writes its token after `Permission.notification` is granted.

## Client-side reception (Flutter)

Add to `pubspec.yaml`:

```yaml
firebase_core: ^3.6.0
firebase_messaging: ^15.1.3
flutter_local_notifications: ^17.2.3
```

Then in `lib/main.dart`:

```dart
await Firebase.initializeApp();
final token = await FirebaseMessaging.instance.getToken();
// Persist token to profiles.push_token via SupabaseAuthRepository.
FirebaseMessaging.onMessage.listen(_showLocalNotification);
FirebaseMessaging.onMessageOpenedApp.listen(_handleDeepLink);
```

`_showLocalNotification` builds a `flutter_local_notifications` payload from the FCM message and shows it. `_handleDeepLink` calls `GoRouter.go(...)` to the right detail page based on `ref_type` / `ref_id` in the message data.

## Quiet hours

`profiles` already has a `language` column for per-user templating. Add `quiet_hours_start time` and `quiet_hours_end time` columns, and check them in the `push_dispatcher` Edge Function before sending. The in-app feed is **never** suppressed by quiet hours.

## Rate cap

`platform_settings.notif_hourly_cap` is already supported by `PlatformSettingsService` (defaults to 20). Enforce it server-side inside `push_dispatcher` by counting rows per tutor in the last hour before dispatching.

## Testing without credentials

Phase 8 ships the `FakeNotificationsRepository` (in-memory feed with seeded items + an `inject()` hook). Tests use `inject()` to simulate real-time inserts. The `notifications_bloc_test.dart` suite covers load, filter, mark-read, and live insert.
