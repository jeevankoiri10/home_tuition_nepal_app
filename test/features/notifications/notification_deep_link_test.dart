import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/app/router.dart';
import 'package:home_tuition_nepal_app/features/notifications/domain/models/app_notification.dart';
import 'package:home_tuition_nepal_app/features/notifications/presentation/notification_deep_link.dart';

AppNotification _n({String? refType, String? refId, String id = 'n1'}) => AppNotification(
      id: id,
      userId: 'u1',
      kind: NotificationKind.systemMessage,
      title: 'T',
      refType: refType,
      refId: refId,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('resolveNotificationDeepLink', () {
    test('job ref → post detail', () {
      expect(resolveNotificationDeepLink(_n(refType: 'job', refId: 'j1')),
          AppRoutes.postDetail.replaceAll(':id', 'j1'));
    });

    test('vacancy ref → vacancy detail', () {
      expect(resolveNotificationDeepLink(_n(refType: 'vacancy', refId: 'v1')),
          AppRoutes.vacancyDetail.replaceAll(':id', 'v1'));
    });

    test('tutor ref → map', () {
      expect(resolveNotificationDeepLink(_n(refType: 'tutor')), AppRoutes.map);
    });

    test('unresolvable ref falls back to this notice’s detail page', () {
      expect(resolveNotificationDeepLink(_n(id: 'abc')),
          AppRoutes.noticeDetail.replaceAll(':id', 'abc'));
      // job with no refId is unresolvable → notice detail of the notification.
      expect(resolveNotificationDeepLink(_n(refType: 'job', id: 'xyz')),
          AppRoutes.noticeDetail.replaceAll(':id', 'xyz'));
    });
  });
}
