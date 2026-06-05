import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/app/router.dart';
import 'package:home_tuition_nepal_app/core/services/push_deep_link.dart';

void main() {
  group('resolvePushDeepLink', () {
    test('job ref → post detail', () {
      expect(
        resolvePushDeepLink({'ref_type': 'job', 'ref_id': 'abc'}),
        AppRoutes.postDetail.replaceAll(':id', 'abc'),
      );
    });

    test('vacancy ref → vacancy detail', () {
      expect(
        resolvePushDeepLink({'ref_type': 'vacancy', 'ref_id': 'v1'}),
        AppRoutes.vacancyDetail.replaceAll(':id', 'v1'),
      );
    });

    test('notice ref → notice detail', () {
      expect(
        resolvePushDeepLink({'ref_type': 'notice', 'ref_id': 'n1'}),
        AppRoutes.noticeDetail.replaceAll(':id', 'n1'),
      );
    });

    test('tutor ref → map', () {
      expect(resolvePushDeepLink({'ref_type': 'tutor'}), AppRoutes.map);
    });

    test('unknown / missing ref → notifications feed', () {
      expect(resolvePushDeepLink({}), AppRoutes.notifications);
      expect(resolvePushDeepLink({'ref_type': 'job'}), AppRoutes.notifications);
      expect(resolvePushDeepLink({'ref_type': 'mystery', 'ref_id': 'x'}),
          AppRoutes.notifications);
    });
  });
}
