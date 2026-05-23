import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';

/// Placeholder Student home — shipped in Phase 2 so the post-verification
/// redirect lands somewhere meaningful. Phase 4 replaces this with the
/// inDrive-style locality-first map view.
class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.studentHomeTitle),
            actions: [
              IconButton(
                tooltip: l10n.signOutTooltip,
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                  context.go(AppRoutes.splash);
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.homeWelcome(user?.displayName ?? '—'),
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.homeHandle(user?.handle ?? '—'),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                _BalanceCard(coins: user?.coinBalance ?? 0),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(Icons.map_outlined),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(l10n.studentMapPlaceholder),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.map),
                          child: Text(l10n.previewLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on_outlined, color: Colors.white, size: 36),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.currentBalanceLabel,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              Text(l10n.coinsSuffix(coins),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
