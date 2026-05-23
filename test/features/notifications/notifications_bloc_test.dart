import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/notifications/data/fake_notifications_repository.dart';
import 'package:home_tuition_nepal_app/features/notifications/domain/models/app_notification.dart';
import 'package:home_tuition_nepal_app/features/notifications/presentation/blocs/notifications_bloc.dart';

void main() {
  group('NotificationsBloc', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'load resolves to ready with seeded items + unread count',
      build: () => NotificationsBloc(FakeNotificationsRepository()),
      act: (b) => b.add(const NotificationsLoaded('u1')),
      wait: const Duration(milliseconds: 300),
      verify: (b) {
        expect(b.state.status, NotificationsStatus.ready);
        expect(b.state.notifications, isNotEmpty);
        // Seeded fake has 2 unread, 2 read.
        expect(b.state.unreadCount, 2);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'filter narrows visible to unread / read',
      build: () => NotificationsBloc(FakeNotificationsRepository()),
      act: (b) async {
        b.add(const NotificationsLoaded('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
        b.add(const NotificationsFilterChanged(NotificationsFilter.unread));
      },
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.filter, NotificationsFilter.unread);
        expect(b.state.visible.every((n) => !n.isRead), isTrue);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'markAllRead zeroes the unread count',
      build: () => NotificationsBloc(FakeNotificationsRepository()),
      act: (b) async {
        b.add(const NotificationsLoaded('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
        b.add(const NotificationsAllRead());
      },
      wait: const Duration(milliseconds: 400),
      verify: (b) => expect(b.state.unreadCount, 0),
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'inserted notification appears at the front of the list',
      build: () {
        final repo = FakeNotificationsRepository();
        final bloc = NotificationsBloc(repo);
        Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
          repo.inject(AppNotification(
            id: 'live-1',
            userId: 'u1',
            kind: NotificationKind.newJobPosted,
            title: 'New job posted',
            body: 'Live insert',
            createdAt: DateTime.now(),
          ));
        });
        return bloc;
      },
      act: (b) => b.add(const NotificationsLoaded('u1')),
      wait: const Duration(milliseconds: 700),
      verify: (b) {
        expect(b.state.notifications.first.id, 'live-1');
      },
    );
  });
}
