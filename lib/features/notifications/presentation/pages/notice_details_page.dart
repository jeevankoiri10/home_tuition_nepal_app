import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/app_notification.dart';
import '../blocs/notifications_bloc.dart';
import '../widgets/notification_card.dart';

/// Read-only detail view for a single notification ("notice"), shown when a
/// notification row is tapped and doesn't deep-link to a domain page.
class NoticeDetailsPage extends StatelessWidget {
  const NoticeDetailsPage({super.key, required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: BrandAppBar(title: Text(l10n.noticeDetailsTitle)),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final notice = state.notifications
              .where((n) => n.id == notificationId)
              .cast<AppNotification?>()
              .firstWhere((_) => true, orElse: () => null);
          if (notice == null) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  l10n.noticeDetailsNotFound,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return _NoticeBody(notice: notice);
        },
      ),
    );
  }
}

class _NoticeBody extends StatelessWidget {
  const _NoticeBody({required this.notice});

  final AppNotification notice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final formattedWhen =
        DateFormat.yMMMMd(Localizations.localeOf(context).toString())
            .add_jm()
            .format(notice.createdAt.toLocal());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NotificationCard.kindLabel(l10n, notice.kind),
            style: tt.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notice.title.isNotEmpty)
            Text(notice.title, style: tt.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          if ((notice.body ?? '').isNotEmpty)
            Text(notice.body!, style: tt.bodyLarge),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.noticeDetailsReceivedAt(formattedWhen),
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
