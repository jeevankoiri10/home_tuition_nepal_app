import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/app_notification.dart';
import '../blocs/notifications_bloc.dart';
import '../notification_deep_link.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  void _onTap(BuildContext context, AppNotification n) {
    context.read<NotificationsBloc>().add(NotificationsRead(n.id));
    // Resolve the deep-link target (shared with push); falls back to this
    // notification's own detail page when the ref can't be resolved.
    context.push(resolveNotificationDeepLink(n));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final visible = state.visible;
        return Scaffold(
          appBar: BrandAppBar(
            title: Text(l10n.notificationsTitle),
            actions: [
              if (state.unreadCount > 0)
                IconButton(
                  tooltip: l10n.notificationsMarkAllRead,
                  icon: const Icon(Icons.done_all),
                  onPressed: () =>
                      context.read<NotificationsBloc>().add(const NotificationsAllRead()),
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: _TabBar(
                  filter: state.filter,
                  unread: state.unreadCount,
                  total: state.notifications.length,
                  onChanged: (f) => context
                      .read<NotificationsBloc>()
                      .add(NotificationsFilterChanged(f)),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? _EmptyState(filter: state.filter, status: state.status)
                    : RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<NotificationsBloc>()
                              .add(const NotificationsRefreshed());
                          await Future<void>.delayed(const Duration(milliseconds: 250));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: visible.length,
                          itemBuilder: (_, i) => NotificationCard(
                            notification: visible[i],
                            onTap: () => _onTap(context, visible[i]),
                          ),
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

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.filter,
    required this.unread,
    required this.total,
    required this.onChanged,
  });

  final NotificationsFilter filter;
  final int unread;
  final int total;
  final ValueChanged<NotificationsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<NotificationsFilter>(
      segments: [
        ButtonSegment(
          value: NotificationsFilter.all,
          label: Text(total > 0 ? l10n.notificationsTabAllCount(total) : l10n.notificationsTabAll),
        ),
        ButtonSegment(
          value: NotificationsFilter.unread,
          label: Text(unread > 0
              ? l10n.notificationsTabUnreadCount(unread)
              : l10n.notificationsTabUnread),
        ),
        ButtonSegment(
          value: NotificationsFilter.read,
          label: Text(l10n.notificationsTabRead),
        ),
      ],
      selected: {filter},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, required this.status});
  final NotificationsFilter filter;
  final NotificationsStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == NotificationsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context);
    final msg = switch (filter) {
      NotificationsFilter.all => l10n.notificationsEmpty,
      NotificationsFilter.unread => l10n.notificationsEmptyUnread,
      NotificationsFilter.read => l10n.notificationsEmptyRead,
    };
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
