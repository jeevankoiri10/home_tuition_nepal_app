import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
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
      case NotificationKind.tutorApplied:
        return Icons.person_add_alt_outlined;
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
      case NotificationKind.announcement:
        return Icons.campaign_outlined;
      case NotificationKind.systemMessage:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final title = notification.title.isNotEmpty
        ? notification.title
        : (notification.body ?? '');
    return Semantics(
      button: true,
      label: l10n.notificationCardSemantics(
        _kindLabel(l10n, notification.kind),
        title,
        _relative(l10n, notification.createdAt),
        notification.isRead ? '' : l10n.notificationUnreadSuffix,
      ),
      child: Card(
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
                      _kindLabel(l10n, notification.kind),
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
                  Text(_relative(l10n, notification.createdAt),
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
    ),
    );
  }

  static String kindLabel(AppLocalizations l10n, NotificationKind kind) =>
      _kindLabel(l10n, kind);

  static String _kindLabel(AppLocalizations l10n, NotificationKind kind) {
    switch (kind) {
      case NotificationKind.newJobPosted:
        return l10n.notifKindNewJobPosted;
      case NotificationKind.tutorApplied:
        return l10n.notifKindTutorApplied;
      case NotificationKind.applicationShortlisted:
        return l10n.notifKindApplicationShortlisted;
      case NotificationKind.applicationHired:
        return l10n.notifKindApplicationHired;
      case NotificationKind.contactRevealed:
        return l10n.notifKindContactRevealed;
      case NotificationKind.identityVerificationApproved:
        return l10n.notifKindIdentityApproved;
      case NotificationKind.identityVerificationRejected:
        return l10n.notifKindIdentityRejected;
      case NotificationKind.coinCredited:
        return l10n.notifKindCoinCredited;
      case NotificationKind.coinDebited:
        return l10n.notifKindCoinDebited;
      case NotificationKind.newReview:
        return l10n.notifKindNewReview;
      case NotificationKind.announcement:
        return l10n.notifKindAnnouncement;
      case NotificationKind.systemMessage:
        return l10n.notifKindSystem;
    }
  }

  static String _relative(AppLocalizations l10n, DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.relativeJustNow;
    if (d.inMinutes < 60) return l10n.relativeMinutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.relativeHoursAgo(d.inHours);
    return l10n.relativeDaysAgo(d.inDays);
  }
}
