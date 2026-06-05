import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:home_tuition_nepal_app/features/chat/presentation/widgets/open_messages_button.dart';
import 'package:home_tuition_nepal_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('OpenMessagesButton navigates to the chat list', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: Center(child: OpenMessagesButton()),
          ),
        ),
        GoRoute(
          path: '/chats',
          builder: (_, _) => const Scaffold(body: Text('CHAT_LIST')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));

    expect(find.text('CHAT_LIST'), findsNothing);
    await tester.tap(find.byType(OpenMessagesButton));
    await tester.pumpAndSettle();
    expect(find.text('CHAT_LIST'), findsOneWidget);
  });
}
