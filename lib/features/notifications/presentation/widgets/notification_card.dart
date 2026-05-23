import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/app_notification.dart';

/// One row in the Notifications feed. Layout mirrors the competitor pattern
/// (label · body · time · chat-bubble icon) but follows our masked-name &
/// no-phone invariants.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  Color get _labelColor =>
      notification.isRead ? AppColors.textSecondary : AppColors.primary;

  IconData get _icon {
    switch (notification.kind) {
      case NotificationKind.newJobPosted:
        return Icons.work_outline;
      case NotificationKind.applicationShortlisted:
        return Icons.star_outline;
      case NotificationKind.applicationHired:
      case NotificationKind.contactRevealed:
        return Icons.check_circle_outline;
      case NotificationKind.identityVerificationApproved:
        return Icons.verified_outlined;
      case NotificationKind.identityVerificationRejected:
        return Icons.report_gmailerrorred_outlined;
      case NotificationKind.coinCredited:
        return Icons.add_circle_outline;
      case NotificationKind.coinDebited:
        return Icons.remove_circle_outline;
      case NotificationKind.newReview:
        return Icons.rate_review_outlined;
      case NotificationKind.systemMessage:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardBorder,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(_icon, color: _labelColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.kind.fallbackLabel,
                      style: tt.labelMedium?.copyWith(
                        color: _labelColor,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.title.isNotEmpty
                          ? notification.title
                          : (notification.body ?? '—'),
                      style: tt.titleSmall,
                    ),
                    if (notification.body != null &&
                        notification.body != notification.title) ...[
                      const SizedBox(height: 2),
                      Text(notification.body!, style: tt.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_relative(notification.createdAt),
                      style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Icon(
                    notification.isRead
                        ? Icons.mark_chat_read_outlined
                        : Icons.chat_bubble,
                    size: 16,
                    color: notification.isRead ? AppColors.textSecondary : AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
