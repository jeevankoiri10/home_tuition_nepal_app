import 'dart:async';

import '../domain/models/app_notification.dart';
import '../domain/notifications_repository.dart';

/// In-memory feed seeded with a few demo notifications so the screen is not
/// empty during local dev. Used when no Supabase creds are available.
class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository();

  final Map<String, List<AppNotification>> _byUser = {};
  final StreamController<AppNotification> _inserts = StreamController.broadcast();

  void _seedIfEmpty(String userId) {
    if (_byUser.containsKey(userId)) return;
    final now = DateTime.now();
    _byUser[userId] = [
      AppNotification(
        id: 'n-1',
        userId: userId,
        kind: NotificationKind.newJobPosted,
        title: 'New job posted',
        body: 'Maths tutor needed in Kapan',
        refType: 'job',
        refId: 'fake-job-1',
        createdAt: now.subtract(const Duration(minutes: 19)),
      ),
      AppNotification(
        id: 'n-2',
        userId: userId,
        kind: NotificationKind.newJobPosted,
        title: 'New job posted',
        body: 'Online Calculus tutor required in Baneshwor',
        refType: 'job',
        refId: 'fake-job-2',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      AppNotification(
        id: 'n-3',
        userId: userId,
        kind: NotificationKind.identityVerificationApproved,
        title: 'Identity Verification Approved',
        body: 'You\'ve received 50 coins.',
        readAt: now.subtract(const Duration(hours: 4)),
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'n-4',
        userId: userId,
        kind: NotificationKind.coinCredited,
        title: 'Welcome bonus',
        body: '+1000 coins credited on signup.',
        readAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<List<AppNotification>> list(String userId, {int limit = 100}) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    _seedIfEmpty(userId);
    final list = _byUser[userId] ?? const <AppNotification>[];
    return list.take(limit).toList();
  }

  @override
  Future<Set<NotificationKind>> enabledKinds() async =>
      NotificationKind.values.toSet();

  @override
  Future<void> markRead(String notificationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    for (final list in _byUser.values) {
      final idx = list.indexWhere((n) => n.id == notificationId);
      if (idx == -1) continue;
      list[idx] = list[idx].copyWith(markRead: true);
      return;
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final list = _byUser[userId];
    if (list == null) return;
    for (int i = 0; i < list.length; i++) {
      if (!list[i].isRead) list[i] = list[i].copyWith(markRead: true);
    }
  }

  @override
  Stream<AppNotification> watchInserts(String userId) => _inserts.stream;

  /// Test / demo seam — push a new notification into the feed.
  void inject(AppNotification n) {
    _byUser.putIfAbsent(n.userId, () => []).insert(0, n);
    _inserts.add(n);
  }
}
