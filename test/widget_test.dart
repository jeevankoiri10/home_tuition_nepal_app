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

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text("Don't have an account? Create one"), findsOneWidget);
  });

  testWidgets('Login page → register page', (tester) async {
    await tester.pumpWidget(const HomeTuitionNepalApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Don't have an account? Create one"));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsAtLeastNWidgets(1));
    expect(find.text("I'm a tutor"), findsOneWidget);
    expect(find.text("I'm a student"), findsOneWidget);
  });
}
