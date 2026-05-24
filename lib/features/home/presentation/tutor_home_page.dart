import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../reviews/domain/reviews_repository.dart';
import '../../wallet/presentation/blocs/wallet_bloc.dart';
import '../../wallet/presentation/widgets/coin_balance_card.dart';

class TutorHomePage extends StatelessWidget {
  const TutorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.tutorHomeTitle),
            actions: [
              const NotificationBell(),
              // Coin chip — mirrors the student map AppBar so balance is
              // always visible at the top.
              BlocBuilder<WalletBloc, WalletState>(
                builder: (_, w) => TextButton.icon(
                  onPressed: () => context.push(AppRoutes.wallet),
                  icon: const Icon(Icons.monetization_on_outlined,
                      color: Colors.white),
                  label: Text('${w.balance}',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
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
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Text(l10n.homeWelcome(user?.displayName ?? '—'),
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.homeHandle(user?.handle ?? '—'),
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              // Source from WalletBloc — server-authoritative and updated by
              // the realtime subscription. AuthBloc's user.coinBalance is only
              // accurate at sign-in time.
              BlocBuilder<WalletBloc, WalletState>(
                builder: (_, w) => CoinBalanceCard(
                  coins: w.balance,
                  onTap: () => context.push(AppRoutes.wallet),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionTile(
                icon: Icons.auto_awesome_outlined,
                title: l10n.tutorActionCompleteProfileTitle,
                subtitle: l10n.tutorActionCompleteProfileSubtitle,
                onTap: () => context.push(AppRoutes.tutorOnboarding),
              ),
              _ActionTile(
                icon: Icons.tune_outlined,
                title: l10n.tutorActionProfileSettingsTitle,
                subtitle: l10n.tutorActionProfileSettingsSubtitle,
                onTap: () => context.push(AppRoutes.tutorProfileSettings),
              ),
              _ActionTile(
                icon: Icons.forum_outlined,
                title: l10n.tutorActionChatsTitle,
                subtitle: l10n.tutorActionChatsSubtitle,
                onTap: () => context.push(AppRoutes.chatList),
              ),
              _ActionTile(
                icon: Icons.assignment_outlined,
                title: l10n.tutorActionVacanciesTitle,
                subtitle: l10n.tutorActionVacanciesSubtitle,
                onTap: () => context.push(AppRoutes.vacancies),
              ),
              _ActionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.tutorActionWalletTitle,
                subtitle: l10n.tutorActionWalletSubtitle,
                onTap: () => context.push(AppRoutes.wallet),
              ),
              _ActionTile(
                icon: Icons.bolt_outlined,
                title: l10n.tutorActionBoostTitle,
                subtitle: l10n.tutorActionBoostSubtitle,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final balance =
                        await sl<ReviewsRepository>().boostFeatured(hours: 24);
                    messenger.showSnackBar(SnackBar(
                        content: Text(l10n.tutorBoostSuccessSnack(balance))));
                  } on ReviewsException catch (e) {
                    messenger.showSnackBar(SnackBar(
                        content: Text(e.message ?? l10n.tutorBoostFailedSnack)));
                  } catch (_) {
                    messenger.showSnackBar(SnackBar(
                        content: Text(l10n.tutorBoostInsufficientSnack)));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      const Icon(Icons.construction_outlined),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(l10n.tutorPhasesNote),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
