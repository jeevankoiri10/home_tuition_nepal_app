import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/config/env.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/safe_back_scope.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../domain/models/coin_pack.dart';
import '../../domain/models/top_up.dart';
import '../../domain/top_ups_repository.dart';
import '../widgets/esewa_payment_sheet.dart';

class CoinPacksPage extends StatefulWidget {
  const CoinPacksPage({super.key});

  @override
  State<CoinPacksPage> createState() => _CoinPacksPageState();
}

class _CoinPacksPageState extends State<CoinPacksPage> {
  late Future<List<CoinPack>> _packs;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _packs = sl<TopUpsRepository>().listPacks();
  }

  Future<void> _buy(CoinPack pack) async {
    final l10n = AppLocalizations.of(context);
    // EsewaPaymentSheet owns the full payment flow now — start_top_up,
    // QR display, receipt upload — and returns the finalized TopUp (with a
    // receipt URL) on success, or null if the user backed out.
    final topUp = await showModalBottomSheet<TopUp>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => EsewaPaymentSheet(pack: pack),
    );
    if (topUp == null || !mounted) return;

    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    // Pull the wallet bloc up-front (if scoped) so we don't touch context
    // after awaiting `debugSimulateSuccess`.
    WalletBloc? walletBloc;
    try {
      walletBloc = context.read<WalletBloc>();
    } catch (_) {/* not in scope here */}
    try {
      // In dev (no Supabase creds), no admin will ever flip the row — credit
      // the wallet right away so the demo flow stays usable.
      if (!Env.hasSupabase) {
        await sl<TopUpsRepository>().debugSimulateSuccess(topUp.id);
      }
      walletBloc?.add(const WalletBalanceChanged());
      messenger.showSnackBar(SnackBar(content: Text(l10n.esewaTopUpQueued)));
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.wallet);
      }
    } on TopUpsException catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(e.message ?? l10n.topUpFailedGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeBackScope(
      fallbackLocation: AppRoutes.wallet,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.walletBuyCoins)),
        body: FutureBuilder<List<CoinPack>>(
          future: _packs,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final packs = snap.data!;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  l10n.coinPacksIntro,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final p in packs) _PackCard(pack: p, busy: _busy, onBuy: () => _buy(p)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack, required this.busy, required this.onBuy});
  final CoinPack pack;
  final bool busy;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.monetization_on_outlined, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pack.label, style: tt.titleMedium),
                Text(
                  pack.bonusLabel() != null
                      ? l10n.coinPackSubtitleWithBonus(pack.totalCoins, pack.bonusLabel()!)
                      : l10n.coinPackSubtitle(pack.totalCoins),
                  style: tt.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(pack.formatPrice(),
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              FilledButton(
                onPressed: busy ? null : onBuy,
                child: Text(l10n.coinPackBuy),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
