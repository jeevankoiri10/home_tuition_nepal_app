import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/widgets/map_error_banner.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('renders the message and a Retry action that fires the callback',
      (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MapErrorBanner(
            message: 'Could not load vacancies.',
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not load vacancies.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });
}
