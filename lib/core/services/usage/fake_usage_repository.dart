import 'usage_repository.dart';

/// No-op [UsageRepository] used when Supabase isn't configured (dev/offline).
/// Echoes back a stable session id so the tracker's bookkeeping still works.
class FakeUsageRepository implements UsageRepository {
  @override
  Future<String?> touchSession({required String? sessionId, required String role}) async =>
      sessionId ?? 'fake-session';
}
