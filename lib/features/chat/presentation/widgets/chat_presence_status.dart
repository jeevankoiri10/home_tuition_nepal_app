import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/di.dart';
import '../../../../core/services/presence_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// App-bar subtitle for a chat: shows a live "Online" pill when the counterparty
/// is connected (Realtime Presence), otherwise their "last seen" time. Sized and
/// coloured for the brand app bar (white foreground).
class ChatPresenceStatus extends StatefulWidget {
  const ChatPresenceStatus({super.key, required this.userId});

  final String userId;

  @override
  State<ChatPresenceStatus> createState() => _ChatPresenceStatusState();
}

class _ChatPresenceStatusState extends State<ChatPresenceStatus> {
  late final Future<DateTime?> _lastSeen = sl<PresenceService>().lastSeenOf(
    widget.userId,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ValueListenableBuilder<Set<String>>(
      valueListenable: sl<PresenceService>().online,
      builder: (context, online, _) {
        if (online.contains(widget.userId)) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.presenceOnline,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          );
        }
        return FutureBuilder<DateTime?>(
          future: _lastSeen,
          builder: (context, snap) {
            final ts = snap.data;
            if (ts == null) return const SizedBox.shrink();
            final when = DateFormat.MMMd().add_jm().format(ts.toLocal());
            return Text(
              l10n.presenceLastSeen(when),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            );
          },
        );
      },
    );
  }
}
