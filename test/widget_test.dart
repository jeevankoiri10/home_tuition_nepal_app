import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_tuition_nepal_app/app/app.dart';
import 'package:home_tuition_nepal_app/app/di.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await setupDependencies();
  });

  testWidgets('Splash screen renders language picker on first launch', (tester) async {
    await tester.pumpWidget(const HomeTuitionNepalApp());
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('नेपाली'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('Selecting English routes to the login page', (tester) async {
    await tester.pumpWidget(const HomeTuitionNepalApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // The login page no longer shows a "Welcome back" heading (the brand app
    // bar carries the name) or a register link — registration now happens via
    // the "Continue with Google" role toggle. Assert stable login-only signals.
    expect(find.text('Sign in to find tutors in your locality.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Continue with Google expands to the role options', (tester) async {
    await tester.pumpWidget(const HomeTuitionNepalApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // The old "Create one" register link was replaced by a Notion-style
    // disclosure: tapping "Continue with Google" reveals the student/tutor
    // choices that drive onboarding for a brand-new account.
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google as a student'), findsOneWidget);
    expect(find.text('Continue with Google as a tutor'), findsOneWidget);
  });
}
