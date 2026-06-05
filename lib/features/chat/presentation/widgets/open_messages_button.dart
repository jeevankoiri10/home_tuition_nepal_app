import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// App-bar action that opens the chat list (all of the user's conversations).
/// Reusable so every shell/app bar surfaces messages the same way.
class OpenMessagesButton extends StatelessWidget {
  const OpenMessagesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).viewMessages,
      icon: const Icon(Icons.forum_outlined),
      onPressed: () => context.push(AppRoutes.chatList),
    );
  }
}
