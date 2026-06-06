import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/theme/app_colors.dart';
import 'package:home_tuition_nepal_app/core/widgets/verified_badge.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('VerifiedBadge', () {
    testWidgets('renders the verified tick with defaults', (tester) async {
      await tester.pumpWidget(_host(const VerifiedBadge()));

      final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
      expect(icon.size, 14);
      expect(icon.color, AppColors.primary);
      expect(icon.semanticLabel, isNull);
    });

    testWidgets('honours size and color overrides', (tester) async {
      await tester.pumpWidget(
        _host(const VerifiedBadge(size: 18, color: Colors.green)),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.verified));
      expect(icon.size, 18);
      expect(icon.color, Colors.green);
    });

    testWidgets('exposes the semantic label for screen readers',
        (tester) async {
      await tester.pumpWidget(
        _host(const VerifiedBadge(semanticLabel: 'Verified tutor')),
      );

      expect(find.bySemanticsLabel('Verified tutor'), findsOneWidget);
    });
  });
}
