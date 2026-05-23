import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/auth/data/fake_auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';
import 'package:home_tuition_nepal_app/features/auth/presentation/blocs/auth_bloc.dart';

void main() {
  group('AuthBloc — registration → OTP → authenticated', () {
    blocTest<AuthBloc, AuthState>(
      'student registration ends in awaitingOtp',
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
      wait: const Duration(milliseconds: 600),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.awaitingOtp);
        expect(bloc.state.user, isNotNull);
        expect(bloc.state.user!.role, UserRole.student);
        expect(bloc.state.user!.phoneVerified, isFalse);
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
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.error);
        expect(bloc.state.errorCode, 'coc_required');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'OTP 123456 transitions to authenticated',
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
        await Future<void>.delayed(const Duration(milliseconds: 500));
        bloc.add(const AuthOtpRequested(FakeAuthRepository.demoOtp));
      },
      wait: const Duration(milliseconds: 1500),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.authenticated);
        expect(bloc.state.user!.phoneVerified, isTrue);
      },
    );
  });
}
