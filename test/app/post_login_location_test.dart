import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/app/router.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';

void main() {
  group('AppRoutes.postLoginLocation', () {
    test('student-only → map', () {
      expect(AppRoutes.postLoginLocation({UserRole.student}), AppRoutes.map);
    });

    test('tutor-only → tutor home', () {
      expect(AppRoutes.postLoginLocation({UserRole.tutor}), AppRoutes.tutorHome);
    });

    test('both roles → role chooser', () {
      expect(
        AppRoutes.postLoginLocation({UserRole.tutor, UserRole.student}),
        AppRoutes.loginRoleChooser,
      );
    });

    test('empty (unexpected) → back to login', () {
      expect(AppRoutes.postLoginLocation(const {}), AppRoutes.login);
    });
  });

  group('AppRoutes.routeForRole', () {
    test('maps each role to its home', () {
      expect(AppRoutes.routeForRole(UserRole.tutor), AppRoutes.tutorHome);
      expect(AppRoutes.routeForRole(UserRole.student), AppRoutes.map);
    });
  });
}
