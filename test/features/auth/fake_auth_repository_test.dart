import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/auth/data/fake_auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';

/// Contract tests for the in-memory [FakeAuthRepository]. These pin the
/// behaviour the AuthBloc and router guards rely on (verified-vs-unverified,
/// onboarding gates, the `currentUser` stream, the no-session guards) so a
/// regression in the dev/demo backend surfaces here rather than on a device.
void main() {
  RegistrationInput studentInput({
    String email = 'sita@example.com',
    bool tosAccepted = true,
  }) =>
      RegistrationInput(
        firstName: 'Sita',
        lastName: 'Khanal',
        email: email,
        phone: '9812345678',
        password: 'password1',
        role: UserRole.student,
        tosAccepted: tosAccepted,
        codeOfConductAccepted: false,
      );

  RegistrationInput tutorInput({bool codeOfConductAccepted = true}) =>
      RegistrationInput(
        firstName: 'Ramesh',
        lastName: 'Shrestha',
        email: 'ramesh@example.com',
        phone: '9812345678',
        password: 'password1',
        role: UserRole.tutor,
        tosAccepted: true,
        codeOfConductAccepted: codeOfConductAccepted,
      );

  group('register', () {
    test('student registration provisions an unverified, pre-onboarding account',
        () async {
      final repo = FakeAuthRepository();
      final user = await repo.register(studentInput());

      expect(user.role, UserRole.student);
      expect(user.activeRole, UserRole.student);
      expect(user.emailVerified, isFalse,
          reason: 'a fresh email account must confirm its address first');
      expect(user.onboardingComplete, isFalse);
      expect(user.codeOfConductAcceptedAt, isNull,
          reason: 'students do not accept the tutor Code of Conduct');
      expect(user.email, 'sita@example.com');
      expect(user.phone, '+9779812345678', reason: 'phone is +977-normalised');
      expect(repo.cachedUser, user, reason: 'the account is cached after sign-up');
    });

    test('tutor registration records Code-of-Conduct acceptance', () async {
      final repo = FakeAuthRepository();
      final user = await repo.register(tutorInput());

      expect(user.role, UserRole.tutor);
      expect(user.codeOfConductAcceptedAt, isNotNull);
    });

    test('registration without ToS acceptance throws tos_required', () async {
      final repo = FakeAuthRepository();
      await expectLater(
        repo.register(studentInput(tosAccepted: false)),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'tos_required')),
      );
      expect(repo.cachedUser, isNull, reason: 'a rejected sign-up caches nothing');
    });

    test('tutor registration without CoC acceptance throws coc_required',
        () async {
      final repo = FakeAuthRepository();
      await expectLater(
        repo.register(tutorInput(codeOfConductAccepted: false)),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'coc_required')),
      );
    });
  });

  group('login', () {
    test('valid credentials return a verified, onboarded student', () async {
      final repo = FakeAuthRepository();
      final user = await repo.login(email: 'a@b.com', password: 'password1');

      expect(user.emailVerified, isTrue);
      expect(user.onboardingComplete, isTrue);
      expect(user.studentOnboarded, isTrue);
      expect(repo.cachedUser, user);
    });

    test('empty email is rejected as invalid_credentials', () async {
      final repo = FakeAuthRepository();
      await expectLater(
        repo.login(email: '', password: 'password1'),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'invalid_credentials')),
      );
    });

    test('a too-short password is rejected as invalid_credentials', () async {
      final repo = FakeAuthRepository();
      await expectLater(
        repo.login(email: 'a@b.com', password: 'short'),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'invalid_credentials')),
      );
    });
  });

  group('signInWithGoogle', () {
    test('is inherently verified but lands before onboarding', () async {
      final repo = FakeAuthRepository();
      final user = await repo.signInWithGoogle(role: UserRole.student);

      expect(user.emailVerified, isTrue,
          reason: 'Google identities have no email-confirmation step');
      expect(user.onboardingComplete, isFalse,
          reason: 'a brand-new Google account still needs onboarding');
      expect(user.role, UserRole.student);
      expect(user.activeRole, UserRole.student);
    });

    test('tutor role records Code-of-Conduct acceptance', () async {
      final repo = FakeAuthRepository();
      final user = await repo.signInWithGoogle(role: UserRole.tutor);

      expect(user.role, UserRole.tutor);
      expect(user.codeOfConductAcceptedAt, isNotNull);
    });
  });

  group('onboarding mutations', () {
    test('completeStudentOnboarding opens the gate and stores contact/location',
        () async {
      final repo = FakeAuthRepository();
      await repo.signInWithGoogle(role: UserRole.student);

      final user = await repo.completeStudentOnboarding(
        phone: '+9779812345678',
        whatsapp: '+9779812345678',
        lat: 27.7172,
        lng: 85.3240,
      );

      expect(user.onboardingComplete, isTrue);
      expect(user.studentOnboarded, isTrue);
      expect(user.whatsapp, '+9779812345678');
      expect(user.lat, 27.7172);
      expect(user.lng, 85.3240);
      expect(user.onboardingStep, 0, reason: 'the resume cursor is reset');
    });

    test('completeTutorOnboarding sets tutorOnboarded', () async {
      final repo = FakeAuthRepository();
      await repo.signInWithGoogle(role: UserRole.tutor);

      final user = await repo.completeTutorOnboarding();

      expect(user.onboardingComplete, isTrue);
      expect(user.tutorOnboarded, isTrue);
    });

    test('saveOnboardingStep persists the resume cursor', () async {
      final repo = FakeAuthRepository();
      await repo.signInWithGoogle(role: UserRole.tutor);

      final user = await repo.saveOnboardingStep(3);

      expect(user.onboardingStep, 3);
    });

    test('onboarding mutations without a session throw no_session', () async {
      final repo = FakeAuthRepository();
      await expectLater(
        repo.saveOnboardingStep(1),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'no_session')),
      );
      await expectLater(
        repo.completeTutorOnboarding(),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'no_session')),
      );
    });
  });

  group('multi-role', () {
    test('switchActiveRole changes the active dashboard without touching role',
        () async {
      final repo = FakeAuthRepository();
      final original = await repo.register(studentInput());
      expect(original.activeRole, UserRole.student);

      final switched = await repo.switchActiveRole(UserRole.tutor);

      expect(switched.activeRole, UserRole.tutor);
      expect(switched.role, UserRole.student,
          reason: 'the immutable primary role never changes');
    });

    test('availableRoles returns the user\'s role for a matching id', () async {
      final repo = FakeAuthRepository();
      final user = await repo.register(studentInput());

      expect(await repo.availableRoles(user.id), {UserRole.student});
    });

    test('availableRoles is empty for an unknown id', () async {
      final repo = FakeAuthRepository();
      await repo.register(studentInput());

      expect(await repo.availableRoles('someone-else'), isEmpty);
    });
  });

  group('email verification', () {
    test('refreshEmailVerification flips the verified flag', () async {
      final repo = FakeAuthRepository();
      final before = await repo.register(studentInput());
      expect(before.emailVerified, isFalse);

      final after = await repo.refreshEmailVerification();

      expect(after.emailVerified, isTrue);
    });

    test('refreshEmailVerification without a session throws no_session',
        () async {
      final repo = FakeAuthRepository();
      await expectLater(
        repo.refreshEmailVerification(),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'no_session')),
      );
    });
  });

  group('currentUser stream', () {
    test('emits the signed-in profile then null on sign-out', () async {
      final repo = FakeAuthRepository();
      // Subscribe before acting so the broadcast stream delivers both events.
      final expectation = expectLater(
        repo.currentUser,
        emitsInOrder([
          isA<Object?>().having((u) => (u as dynamic)?.role, 'role',
              UserRole.student),
          isNull,
        ]),
      );

      await repo.register(studentInput());
      await repo.signOut();

      await expectation;
      expect(repo.cachedUser, isNull, reason: 'sign-out clears the cache');
    });
  });
}
