/// Records active-usage heartbeats so the backend can measure how long each
/// user spends in the app, split by the role they're acting in.
///
/// One [touchSession] call opens a session (pass `sessionId: null`) or extends
/// an existing one; the server keeps the authoritative duration
/// (`last_seen_at - started_at`). See migration 0027_usage_tracking.sql.
abstract class UsageRepository {
  /// Opens a session when [sessionId] is null, otherwise extends it. Returns
  /// the live session id to reuse on the next beat, or null if nothing could
  /// be recorded.
  Future<String?> touchSession({required String? sessionId, required String role});
}
