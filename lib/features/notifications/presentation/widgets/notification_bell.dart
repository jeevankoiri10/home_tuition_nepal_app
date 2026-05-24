import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../blocs/notifications_bloc.dart';

/// Bell icon with an unread-count badge. Drop into any AppBar's actions list.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.iconColor = Colors.white});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unread = state.unreadCount;
        return Semantics(
          // Bell + badge compose visually; collapse them into one node so
          // screen readers don't read "Notifications" + "5" as two
          // separate items.
          excludeSemantics: true,
          button: true,
          label: l10n.notificationBellSemantics(unread),
          onTap: () => context.push(AppRoutes.notifications),
          child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: l10n.notificationsTitle,
              icon: Icon(Icons.notifications_outlined, color: iconColor),
              onPressed: () => context.push(AppRoutes.notifications),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        );
      },
    );
  }
}
