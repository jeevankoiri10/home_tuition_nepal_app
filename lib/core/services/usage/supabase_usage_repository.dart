import 'package:supabase_flutter/supabase_flutter.dart';

import 'usage_repository.dart';

/// Supabase-backed [UsageRepository] — one RPC call per heartbeat. The
/// `touch_usage_session` function gates on `auth.uid()`, so the session is
/// always attributed to the signed-in user server-side.
class SupabaseUsageRepository implements UsageRepository {
  SupabaseUsageRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String?> touchSession({required String? sessionId, required String role}) async {
    final result = await _client.rpc(
      'touch_usage_session',
      params: {'p_session_id': sessionId, 'p_role': role},
    );
    return result as String?;
  }
}
