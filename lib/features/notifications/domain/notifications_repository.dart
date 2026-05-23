import 'models/app_notification.dart';

class NotificationsException implements Exception {
  NotificationsException(this.code, [this.message]);
  final String code;
  final String? message;
  @override
  String toString() => 'NotificationsException($code, $message)';
}

abstract class NotificationsRepository {
  Future<List<AppNotification>> list(String userId, {int limit = 100});
  Future<void> markRead(String notificationId);
  Future<void> markAllRead(String userId);

  /// Realtime feed of inserts/updates so the in-app screen updates live as
  /// the `notify_matching_tutors` trigger fires. Implementations may emit no
  /// events when realtime isn't configured.
  Stream<AppNotification> watchInserts(String userId);
}
