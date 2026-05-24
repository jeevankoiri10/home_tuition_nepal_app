import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/top_up.dart';

/// Bottom sheet that lets the user pick eSewa / Khalti / IME Pay before the
/// SDK is launched. Each option returns the chosen `PaymentProvider`.
class ProviderPickerSheet extends StatelessWidget {
  const ProviderPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.payWithTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.payProviderHint,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final p in PaymentProvider.values) _ProviderTile(provider: p),
          ],
        ),
      ),
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({required this.provider});
  final PaymentProvider provider;

  IconData get _icon {
    switch (provider) {
      case PaymentProvider.esewa:
        return Icons.account_balance_wallet;
      case PaymentProvider.khalti:
        return Icons.payments;
      case PaymentProvider.imePay:
        return Icons.phone_iphone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_icon, color: AppColors.primary, size: 28),
        title: Text(provider.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pop(provider),
      ),
    );
  }
}
