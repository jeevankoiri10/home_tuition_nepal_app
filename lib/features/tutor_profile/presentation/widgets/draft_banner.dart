import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "Your profile is in draft mode. Complete all steps to publish and go live.
/// 80% profile completed" — see tutor_UI.md §4.7a.
class DraftBanner extends StatelessWidget {
  const DraftBanner({
    super.key,
    required this.completion,
    required this.isPublished,
  });

  final int completion;
  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final published = isPublished;
    final color = published ? const Color(0xFF2E7D32) : const Color(0xFFED6C02);
    final bg = published ? const Color(0xFFE8F5E9) : const Color(0xFFFFF4E5);
    final icon = published ? Icons.check_circle_outline : Icons.warning_amber_outlined;
    final message = published ? l10n.draftBannerPublished : l10n.draftBannerDraft;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.cardBorder,
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(message, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
              ),
              Text('$completion%', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
