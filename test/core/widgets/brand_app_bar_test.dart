import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/widgets/brand_app_bar.dart';

Widget _host(Widget home) => MaterialApp(home: home);

void main() {
  group('BrandAppBar.preferredSize', () {
    test('is the standard toolbar height with no bottom', () {
      const bar = BrandAppBar(title: Text('X'));
      expect(bar.preferredSize.height, kToolbarHeight);
    });

    test('adds the bottom widget height', () {
      const bottom = PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: SizedBox(),
      );
      const bar = BrandAppBar(title: Text('X'), bottom: bottom);
      expect(bar.preferredSize.height, kToolbarHeight + 48);
    });
  });

  group('BrandAppBar rendering', () {
    testWidgets('is a drop-in app bar showing the brand logo and the title',
        (tester) async {
      await tester.pumpWidget(_host(
        const Scaffold(appBar: BrandAppBar(title: Text('Settings'))),
      ));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // the logo
    });

    testWidgets('keeps a back button on a pushed sub-page', (tester) async {
      await tester.pumpWidget(_host(
        Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    appBar: BrandAppBar(title: Text('Detail')),
                    body: SizedBox(),
                  ),
                ),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();

      expect(find.text('Detail'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // logo still shown
    });
  });
}
