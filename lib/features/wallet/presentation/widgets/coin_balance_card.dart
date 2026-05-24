import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Gradient hero card showing the current coin balance. Reusable across the
/// tutor & student home screens and the Wallet page header.
class CoinBalanceCard extends StatelessWidget {
  const CoinBalanceCard({
    super.key,
    required this.coins,
    this.onTap,
    this.compact = false,
  });

  final int coins;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Single semantic label combining role + balance — screen readers no
    // longer announce "CURRENT BALANCE" and "1000 coins" as two unrelated
    // fragments, and decorative icons / colors stay invisible to AT.
    final card = Semantics(
      label: l10n.balanceCardSemantics(coins),
      button: onTap != null,
      excludeSemantics: true,
      child: Container(
      padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on_outlined,
              color: Colors.white, size: compact ? 28 : 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.currentBalanceLabel,
                    style: const TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 12)),
                Text(l10n.coinsSuffix(coins),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 22 : 28,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          if (onTap != null) const Icon(Icons.chevron_right, color: Colors.white70),
        ],
      ),
    ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}
