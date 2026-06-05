import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/map/domain/models/map_tutor.dart';
import 'package:home_tuition_nepal_app/features/map/presentation/widgets/tutor_carousel.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';

MapTutor _tutor(String id) => MapTutor.fromRow({
      'tutor_id': id,
      'masked_name': 'Tutor $id',
      'area_label': 'Area $id',
      'lat': 27.7,
      'lng': 85.3,
      'distance_km': 1.0,
    });

Future<PageController> _pump(
  WidgetTester tester, {
  required List<MapTutor> tutors,
  required String? selectedId,
  required void Function(MapTutor, int) onCardTap,
}) async {
  final controller = PageController(viewportFraction: 0.85);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: TutorCarousel(
          tutors: tutors,
          selectedTutorId: selectedId,
          controller: controller,
          onCardTap: onCardTap,
          onContact: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  group('TutorCarousel sync', () {
    testWidgets('swiping to an unselected card fires onCardTap with that tutor',
        (tester) async {
      final tutors = [_tutor('a'), _tutor('b'), _tutor('c')];
      final taps = <String>[];
      final controller = await _pump(
        tester,
        tutors: tutors,
        selectedId: 'a',
        onCardTap: (t, _) => taps.add(t.tutorId),
      );

      controller.jumpToPage(1);
      await tester.pumpAndSettle();

      expect(taps, contains('b'));
      controller.dispose();
    });

    testWidgets('landing on the already-selected card does not echo (guard)',
        (tester) async {
      final tutors = [_tutor('a'), _tutor('b'), _tutor('c')];
      final taps = <String>[];
      // 'b' is the selected tutor; a programmatic jump to its page (as happens
      // when a pin tap animates the carousel) must NOT re-fire onCardTap.
      final controller = await _pump(
        tester,
        tutors: tutors,
        selectedId: 'b',
        onCardTap: (t, _) => taps.add(t.tutorId),
      );

      controller.jumpToPage(1); // page index of 'b'
      await tester.pumpAndSettle();

      expect(taps, isEmpty);
      controller.dispose();
    });

    testWidgets('renders one card per tutor', (tester) async {
      final tutors = [_tutor('a'), _tutor('b')];
      await _pump(
        tester,
        tutors: tutors,
        selectedId: null,
        onCardTap: (_, _) {},
      );
      expect(find.text('Tutor a'), findsOneWidget);
    });

    testWidgets('cards do not overflow at a large text scale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: TutorCarousel(
                tutors: [_tutor('a'), _tutor('b')],
                selectedTutorId: null,
                controller: PageController(viewportFraction: 0.85),
                onCardTap: (_, _) {},
                onContact: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // tester.takeException() returns any RenderFlex overflow thrown above.
      expect(tester.takeException(), isNull);
    });
  });

  group('TutorCarousel.responsiveHeight', () {
    test('returns the base height at the default text scale', () {
      expect(TutorCarousel.responsiveHeight(200, 1.0), 200);
    });

    test('grows proportionally with the text scale', () {
      expect(TutorCarousel.responsiveHeight(200, 1.3), closeTo(260, 0.0001));
    });

    test('caps growth so the carousel cannot swallow the map', () {
      expect(TutorCarousel.responsiveHeight(200, 3.0), 320); // 200 × 1.6
    });

    test('never shrinks below the base for small scales', () {
      expect(TutorCarousel.responsiveHeight(200, 0.8), 200);
    });
  });
}
