import 'package:flutter/material.dart';

import '../../../app/di.dart';
import '../../../core/services/platform_settings_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../reviews/domain/reviews_repository.dart';

/// Confirm-then-promote flow for a student's own job post. Shows the coin cost,
/// then calls the server-authoritative `promote_job` RPC via [ReviewsRepository]
/// and reports the outcome via a SnackBar. Shared by My Posts and Post Detail so
/// the spend-coins UX stays identical on both surfaces.
Future<void> showPromoteJobDialog(
  BuildContext context, {
  required String jobId,
}) async {
  final l10n = AppLocalizations.of(context);
  final cost = sl<PlatformSettingsService>().getInt('promoted_job_cost', 20);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.promoteJobConfirmTitle),
      content: Text(l10n.promoteJobConfirmBody(cost)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.promoteJobConfirmCta),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  try {
    final balance = await sl<ReviewsRepository>().promoteJob(jobId: jobId);
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.promoteJobSuccessSnack(balance))));
  } on ReviewsException catch (e) {
    messenger.showSnackBar(
        SnackBar(content: Text(e.message ?? l10n.promoteJobFailedSnack)));
  } catch (_) {
    messenger.showSnackBar(
        SnackBar(content: Text(l10n.promoteJobInsufficientSnack)));
  }
}
