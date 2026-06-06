import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/widgets/coin_chip.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('CoinChip', () {
    testWidgets('renders the balance and a coin icon', (tester) async {
      await tester.pumpWidget(_host(const CoinChip(balance: 42)));

      expect(find.text('42'), findsOneWidget);
      expect(find.byIcon(Icons.monetization_on_outlined), findsOneWidget);
    });

    testWidgets('invokes onTap when pressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(CoinChip(balance: 7, onTap: () => taps++)),
      );

      await tester.tap(find.byType(CoinChip));
      expect(taps, 1);
    });

    testWidgets('is non-interactive when onTap is null', (tester) async {
      await tester.pumpWidget(_host(const CoinChip(balance: 0)));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('wraps in a Tooltip when tooltip is provided', (tester) async {
      await tester.pumpWidget(
        _host(const CoinChip(balance: 5, tooltip: 'Your coins')),
      );

      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, 'Your coins');
    });
  });
}
