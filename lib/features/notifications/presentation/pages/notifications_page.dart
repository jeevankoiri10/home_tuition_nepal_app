import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/app_notification.dart';
import '../blocs/notifications_bloc.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  void _onTap(BuildContext context, AppNotification n) {
    context.read<NotificationsBloc>().add(NotificationsRead(n.id));
    // Deep-link by ref_type.
    switch (n.refType) {
      case 'job':
        if (n.refId != null) {
          context.push(AppRoutes.postDetail.replaceAll(':id', n.refId!));
        }
        break;
      case 'vacancy':
        if (n.refId != null) {
          context.push(AppRoutes.vacancyDetail.replaceAll(':id', n.refId!));
        }
        break;
      case 'tutor':
        // Tutor detail screen not yet built; route to map.
        context.push(AppRoutes.map);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final visible = state.visible;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              if (state.unreadCount > 0)
                IconButton(
                  tooltip: 'Mark all read',
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
    return SegmentedButton<NotificationsFilter>(
      segments: [
        ButtonSegment(
            value: NotificationsFilter.all,
            label: Text('All${total > 0 ? ' ($total)' : ''}')),
        ButtonSegment(
            value: NotificationsFilter.unread,
            label: Text('Unread${unread > 0 ? ' ($unread)' : ''}')),
        const ButtonSegment(
            value: NotificationsFilter.read, label: Text('Read')),
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
    final msg = switch (filter) {
      NotificationsFilter.all => 'No notifications yet.',
      NotificationsFilter.unread => 'No unread notifications.',
      NotificationsFilter.read => 'No read notifications.',
    };
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
