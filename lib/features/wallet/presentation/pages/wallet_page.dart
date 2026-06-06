import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/safe_back_scope.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/models/ledger_entry.dart';
import '../blocs/wallet_bloc.dart';
import '../widgets/coin_balance_card.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.read<AuthBloc>().state.user;
    final fallback = user == null
        ? AppRoutes.login
        : AppRoutes.routeForRole(user.role);
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        return SafeBackScope(
          fallbackLocation: fallback,
          child: Scaffold(
            appBar: BrandAppBar(title: Text(l10n.walletTitle)),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(const WalletRefreshRequested());
                await Future<void>.delayed(const Duration(milliseconds: 200));
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  CoinBalanceCard(coins: state.balance),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: l10n.walletBuyCoins,
                    onPressed: () => context.push(AppRoutes.buyCoins),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.walletTransactionHistory,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.status == WalletStatus.loading && state.entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                      child: Center(
                        child: Text(l10n.walletNoTransactions,
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                    )
                  else
                    _LedgerTable(entries: state.entries),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LedgerTable extends StatelessWidget {
  const _LedgerTable({required this.entries});
  final List<LedgerEntry> entries;

  static final _date = DateFormat('MMM d');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const headerStyle = TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xs),
              child: Row(
                children: [
                  SizedBox(width: 56, child: Text(l10n.ledgerColDate, style: headerStyle)),
                  Expanded(child: Text(l10n.ledgerColDetails, style: headerStyle)),
                  SizedBox(
                    width: 64,
                    child: Text(l10n.ledgerColCoins,
                        textAlign: TextAlign.right, style: headerStyle),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (int i = 0; i < entries.length; i++) ...[
              _LedgerRow(entry: entries[i], formatter: _date),
              if (i != entries.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.formatter});
  final LedgerEntry entry;
  final DateFormat formatter;

  @override
  Widget build(BuildContext context) {
    final color = entry.isCredit
        ? const Color(0xFF2E7D32)
        : (entry.isDebit ? const Color(0xFFD32F2F) : AppColors.textSecondary);
    final sign = entry.isCredit ? '+' : '';
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(formatter.format(entry.createdAt),
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.description ?? entry.reason.label),
                Text(entry.reason.label,
                    style:
                        const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$sign${entry.delta}',
              textAlign: TextAlign.right,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
