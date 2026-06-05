import 'package:flutter/material.dart';

import '../../app/di.dart';
import '../services/presence_service.dart';

/// Small green dot that reflects whether [userId] is currently online via
/// Supabase Realtime Presence. Renders nothing when the user is offline, so it
/// can be dropped into a Stack/Row without reserving space.
class PresenceDot extends StatelessWidget {
  const PresenceDot({super.key, required this.userId, this.size = 12});

  final String userId;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: sl<PresenceService>().online,
      builder: (context, online, _) {
        if (!online.contains(userId)) return const SizedBox.shrink();
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF22C55E),
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      },
    );
  }
}
