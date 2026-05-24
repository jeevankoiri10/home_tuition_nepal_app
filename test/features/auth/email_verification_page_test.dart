import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/auth/data/fake_auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/auth_repository.dart';
import 'package:home_tuition_nepal_app/features/auth/domain/models/user_role.dart';
import 'package:home_tuition_nepal_app/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:home_tuition_nepal_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';

/// Bootstraps EmailVerificationPage with a real AuthBloc driven through its
/// public API: register() puts the bloc into awaitingEmailVerification with
/// the user's email populated, which is what the page reads.
Future<AuthBloc> _pumpVerifyPage(WidgetTester tester) async {
  final bloc = AuthBloc(FakeAuthRepository());
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AuthBloc>.value(
      value: bloc,
      child: const EmailVerificationPage(),
    ),
  ));
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
  // The fake repo's register sleeps 400ms, then sendEmailVerification sleeps
  // another 300ms. Pump ~900ms total so both complete and the bloc emits
  // awaitingEmailVerification. Don't pumpAndSettle — the page arms a 5s
  // polling Timer.periodic that never settles.
  await tester.pump(const Duration(milliseconds: 900));
  return bloc;
}

void main() {
  group('EmailVerificationPage', () {
    testWidgets('renders the user email in the instruction', (tester) async {
      final bloc = await _pumpVerifyPage(tester);
      expect(find.textContaining('sita@example.com'), findsOneWidget);
      addTearDown(bloc.close);
    });

    testWidgets('shows the Verify and Resend buttons by default',
        (tester) async {
      final bloc = await _pumpVerifyPage(tester);
      expect(find.text("I've verified"), findsOneWidget);
      expect(find.text('Resend email'), findsOneWidget);
      addTearDown(bloc.close);
    });

    testWidgets('tapping Resend kicks the button into a 60s cooldown',
        (tester) async {
      final bloc = await _pumpVerifyPage(tester);
      await tester.tap(find.text('Resend email'));
      // Pump enough frames for setState + the first cooldown tick to land,
      // but not enough to let the 5s poll fire.
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Resend in 60s'), findsOneWidget);

      // After ~3 seconds the countdown should have ticked down.
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Resend in 60s'), findsNothing);
      expect(find.textContaining('Resend in'), findsOneWidget);

      addTearDown(bloc.close);
    });
  });
}
