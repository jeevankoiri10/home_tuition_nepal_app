import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Maps a raw Postgres / PostgREST error to a short, user-facing message.
/// Keeps cryptic SQLSTATE codes and RLS internals out of the UI while still
/// giving the user an actionable hint. Reusable across every repository.
String friendlyDbMessage(Object error, {required String fallback}) {
  if (error is sb.PostgrestException) {
    final code = error.code ?? '';
    final msg = error.message.toLowerCase();
    // RLS denial — almost always a stale / missing session.
    if (code == '42501' || msg.contains('row-level security')) {
      return 'You don’t have permission to do that. Please sign in again.';
    }
    // NOT NULL violation — a required field is missing.
    if (code == '23502') {
      return 'Please fill in all the required fields.';
    }
    // Foreign-key violation — referenced row (e.g. the profile) is missing.
    if (code == '23503') {
      return 'Your account isn’t fully set up yet. Please sign in again.';
    }
    // Unique violation — duplicate submission.
    if (code == '23505') {
      return 'This already exists.';
    }
    // CHECK violation — an out-of-range / invalid value.
    if (code == '23514') {
      return 'Some of the details aren’t valid. Please review and try again.';
    }
    // Missing table / schema cache — backend not migrated.
    if (code == 'PGRST205' || msg.contains('does not exist')) {
      return 'This feature isn’t available right now. Please try again later.';
    }
  }
  return fallback;
}
