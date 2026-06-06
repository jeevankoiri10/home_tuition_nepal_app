import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';

/// Non-intrusive error banner shown over a map when a search fails. Keeps the
/// map and any previously-loaded pins visible underneath (the inDrive view is
/// never replaced by a blank error page) and offers a one-tap Retry.
///
/// Shared by the student tutor-map and the tutor vacancy-map so both surfaces
/// report failures identically. Pass the feature-appropriate [message]
/// (e.g. "Couldn't load nearby tutors" vs "Could not load vacancies").
class MapErrorBanner extends StatelessWidget {
  const MapErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AppColors.danger, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
          ],
        ),
      ),
    );
  }
}
