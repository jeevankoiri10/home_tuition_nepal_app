import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/widgets/subject_chips.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SubjectChips', () {
    testWidgets('renders one chip per subject', (tester) async {
      await tester.pumpWidget(
        _host(const SubjectChips(subjects: ['Math', 'Science', 'English'])),
      );

      expect(find.text('Math'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('collapses to an empty box when there are no subjects',
        (tester) async {
      await tester.pumpWidget(_host(const SubjectChips(subjects: [])));

      expect(find.byType(Wrap), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('honours a custom spacing', (tester) async {
      await tester.pumpWidget(
        _host(const SubjectChips(subjects: ['A'], spacing: 4)),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 4);
    });
  });
}
