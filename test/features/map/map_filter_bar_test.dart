import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_filters.dart';
import 'package:home_tuition_nepal_app/features/map/presentation/widgets/map_filter_bar.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';

void main() {
  group('MapFilterBar subject filter', () {
    testWidgets('entering a subject and confirming sets subjectQuery',
        (tester) async {
      MapFilters? captured;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MapFilterBar(
              filters: const MapFilters(),
              onChanged: (f) => captured = f,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the subject dialog via the chip (labelled "Subject" when empty).
      await tester.tap(find.text('Subject'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Maths');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(captured?.subjectQuery, 'Maths');
    });

    testWidgets('the Clear action removes an active subject', (tester) async {
      MapFilters? captured;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MapFilterBar(
              filters: const MapFilters(subjectQuery: 'Physics'),
              onChanged: (f) => captured = f,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Active chip shows the subject name; tap it to open the dialog.
      await tester.tap(find.text('Physics'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.subjectQuery, isNull);
    });
  });
}
