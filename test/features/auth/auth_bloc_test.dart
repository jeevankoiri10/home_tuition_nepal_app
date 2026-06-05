import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/auth/data/fake_auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_profile.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';
import 'package:home_tuition_nepal_app/features/auth/presentation/blocs/auth_bloc.dart';

void main() {
  group('AuthBloc — registration → email verification → authenticated', () {
    blocTest<AuthBloc, AuthState>(
      'student registration ends in awaitingEmailVerification',
      build: () => AuthBloc(FakeAuthRepository()),
      seed: () => const AuthState(),
      act: (bloc) => bloc.add(AuthRegisterRequested(const RegistrationInput(
        firstName: 'Sita',
        lastName: 'Khanal',
        email: 'sita@example.com',
        phone: '9812345678',
        password: 'password1',
        role: UserRole.student,
        tosAccepted: true,
        codeOfConductAccepted: false,
      ))),
      wait: const Duration(milliseconds: 900),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.awaitingEmailVerification);
        expect(bloc.state.user, isNotNull);
        expect(bloc.state.user!.role, UserRole.student);
        expect(bloc.state.user!.emailVerified, isFalse);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'tutor without CoC acceptance errors',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(AuthRegisterRequested(const RegistrationInput(
        firstName: 'Ramesh',
        lastName: 'Shrestha',
        email: 'ramesh@example.com',
        phone: '9812345678',
        password: 'password1',
        role: UserRole.tutor,
        tosAccepted: true,
        codeOfConductAccepted: false,
      ))),
      wait: const Duration(milliseconds: 600),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.error);
        expect(bloc.state.errorCode, 'coc_required');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'email verification refresh transitions to authenticated',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) async {
        bloc.add(AuthRegisterRequested(const RegistrationInput(
          firstName: 'Sita',
          lastName: 'Khanal',
          email: 'sita@example.com',
          phone: '9812345678',
          password: 'password1',
          role: UserRole.student,
          tosAccepted: true,
          codeOfConductAccepted: false,
        )));
        await Future<void>.delayed(const Duration(milliseconds: 800));
        bloc.add(const AuthEmailVerificationRefreshRequested());
      },
      wait: const Duration(milliseconds: 1500),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user!.emailVerified, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'resend keeps state in awaitingEmailVerification and does not error',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) async {
        bloc.add(AuthRegisterRequested(const RegistrationInput(
          firstName: 'Sita',
          lastName: 'Khanal',
          email: 'sita@example.com',
          phone: '9812345678',
          password: 'password1',
          role: UserRole.student,
          tosAccepted: true,
          codeOfConductAccepted: false,
        )));
        await Future<void>.delayed(const Duration(milliseconds: 800));
        bloc.add(const AuthEmailVerificationResendRequested());
      },
      wait: const Duration(milliseconds: 1500),
      verify: (bloc) {
        // Resend does not change status — only calls the repo's send.
        expect(bloc.state.status, AuthStatus.awaitingEmailVerification);
        expect(bloc.state.errorCode, isNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'login with an unverified email lands in awaitingEmailVerification',
      build: () => AuthBloc(_UnverifiedLoginRepo()),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'sita@example.com',
        password: 'password1',
      )),
      wait: const Duration(milliseconds: 900),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.awaitingEmailVerification);
        expect(bloc.state.user, isNotNull);
        expect(bloc.state.user!.emailVerified, isFalse);
      },
    );
  });

  group('AuthBloc — login, Google, sign-out', () {
    blocTest<AuthBloc, AuthState>(
      'login with a verified account becomes authenticated',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'sita@example.com',
        password: 'password1',
      )),
      wait: const Duration(milliseconds: 900),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user!.emailVerified, isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'login with bad credentials surfaces invalid_credentials',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'sita@example.com',
        password: 'short', // < 8 chars → FakeAuthRepository rejects it
      )),
      wait: const Duration(milliseconds: 900),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.error);
        expect(bloc.state.errorCode, 'invalid_credentials');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'Google sign-in authenticates straight away but before onboarding',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested(UserRole.tutor)),
      wait: const Duration(milliseconds: 900),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user!.role, UserRole.tutor);
        expect(bloc.state.user!.emailVerified, isTrue);
        expect(bloc.state.user!.onboardingComplete, isFalse,
            reason: 'the router guard routes the new account into onboarding');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'sign-out returns to unauthenticated and clears the user',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) async {
        bloc.add(const AuthLoginRequested(
          email: 'sita@example.com',
          password: 'password1',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 600));
        bloc.add(const AuthSignOutRequested());
      },
      wait: const Duration(milliseconds: 1200),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.unauthenticated);
        expect(bloc.state.user, isNull);
      },
    );
  });

  group('AuthBloc — AuthStarted resolves the cached session', () {
    blocTest<AuthBloc, AuthState>(
      'no cached user → unauthenticated',
      build: () => AuthBloc(FakeAuthRepository()),
      act: (bloc) => bloc.add(const AuthStarted()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) =>
          expect(bloc.state.status, AuthStatus.unauthenticated),
    );

    blocTest<AuthBloc, AuthState>(
      'cached verified user → authenticated',
      build: () => AuthBloc(_CachedUserRepo(emailVerified: true)),
      act: (bloc) => bloc.add(const AuthStarted()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user, isNotNull);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'cached unverified email account → awaitingEmailVerification',
      build: () => AuthBloc(_CachedUserRepo(emailVerified: false)),
      act: (bloc) => bloc.add(const AuthStarted()),
      wait: const Duration(milliseconds: 100),
      verify: (bloc) =>
          expect(bloc.state.status, AuthStatus.awaitingEmailVerification),
    );
  });
}

/// Exposes a pre-existing cached session so [AuthStarted] can resolve it without
/// a live sign-in. Mirrors the app relaunching with a surviving Supabase session.
class _CachedUserRepo extends FakeAuthRepository {
  _CachedUserRepo({required bool emailVerified}) : _emailVerified = emailVerified;

  final bool _emailVerified;

  @override
  UserProfile? get cachedUser => UserProfile(
        id: 'cached-user',
        firstName: 'Sita',
        lastName: 'Khanal',
        email: 'sita@example.com',
        phone: '+9779812345678',
        emailVerified: _emailVerified,
        role: UserRole.student,
        handle: 'Student #DEMO',
        tosAcceptedAt: DateTime.now().subtract(const Duration(days: 30)),
        coinBalance: 1000,
        onboardingComplete: true,
        studentOnboarded: true,
      );
}

/// Returns a user whose email is not yet verified from login(), so the bloc
/// has to route through awaitingEmailVerification + auto-trigger sendEmail-
/// Verification. The production [FakeAuthRepository] always returns a
/// verified user from login (it's the dev demo path), so this test-only
/// subclass mimics the Supabase repo behaviour where a user can sign in
/// before clicking the confirmation link.
///
/// AuthBloc._onLogin reads the returned user directly and emits the
/// awaitingEmailVerification status based on `user.emailVerified` — no
/// stream push is needed for the state to land.
class _UnverifiedLoginRepo extends FakeAuthRepository {
  @override
  Future<UserProfile> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return UserProfile(
      id: 'fake-login',
      firstName: 'Demo',
      lastName: 'User',
      email: email,
      phone: '+9779800000000',
      emailVerified: false,
      role: UserRole.student,
      handle: 'Student #DEMO',
      tosAcceptedAt: DateTime.now().subtract(const Duration(days: 30)),
      coinBalance: 1000,
    );
  }
}
