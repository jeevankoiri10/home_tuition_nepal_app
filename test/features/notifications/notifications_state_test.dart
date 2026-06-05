import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/notifications/presentation/blocs/notifications_bloc.dart';
import 'package:home_tuition_nepal_app/features/notifications/domain/models/app_notification.dart';

AppNotification _n(String id, {bool read = false}) => AppNotification(
      id: id,
      userId: 'u1',
      kind: NotificationKind.systemMessage,
      title: id,
      readAt: read ? DateTime(2026, 1, 1) : null,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('NotificationsState getters', () {
    final list = [_n('a'), _n('b', read: true), _n('c')];

    test('unreadCount counts only unread', () {
      final s = NotificationsState(notifications: list);
      expect(s.unreadCount, 2);
    });

    test('visible(all) returns everything', () {
      final s = NotificationsState(notifications: list, filter: NotificationsFilter.all);
      expect(s.visible.length, 3);
    });

    test('visible(unread) returns only unread', () {
      final s = NotificationsState(notifications: list, filter: NotificationsFilter.unread);
      expect(s.visible.map((n) => n.id), ['a', 'c']);
    });

    test('visible(read) returns only read', () {
      final s = NotificationsState(notifications: list, filter: NotificationsFilter.read);
      expect(s.visible.map((n) => n.id), ['b']);
    });
  });
}
