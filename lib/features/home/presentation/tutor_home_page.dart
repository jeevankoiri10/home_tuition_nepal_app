import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../reviews/domain/reviews_repository.dart';
import '../../wallet/presentation/widgets/coin_balance_card.dart';

class TutorHomePage extends StatelessWidget {
  const TutorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tutor home'),
            actions: [
              const NotificationBell(),
              IconButton(
                tooltip: 'Sign out',
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
              Text('Welcome, ${user?.displayName ?? '—'}',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text('Handle: ${user?.handle ?? '—'}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
              CoinBalanceCard(
                coins: user?.coinBalance ?? 0,
                onTap: () => context.push(AppRoutes.wallet),
              ),
              const SizedBox(height: AppSpacing.lg),
              _ActionTile(
                icon: Icons.auto_awesome_outlined,
                title: 'Complete your profile',
                subtitle: 'Walk through the 7-step wizard to publish your tutor profile.',
                onTap: () => context.push(AppRoutes.tutorOnboarding),
              ),
              _ActionTile(
                icon: Icons.tune_outlined,
                title: 'Profile settings',
                subtitle: 'Edit subjects, prices, availability, About sections, credentials.',
                onTap: () => context.push(AppRoutes.tutorProfileSettings),
              ),
              _ActionTile(
                icon: Icons.assignment_outlined,
                title: 'Vacancies',
                subtitle: 'Browse open HTN-NNNNN vacancies and apply with 1 coin.',
                onTap: () => context.push(AppRoutes.vacancies),
              ),
              _ActionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Coin wallet',
                subtitle: 'See balance, transaction history, and buy coins.',
                onTap: () => context.push(AppRoutes.wallet),
              ),
              _ActionTile(
                icon: Icons.bolt_outlined,
                title: 'Boost listing (24h)',
                subtitle: 'Get a highlighted pin and a top-of-feed slot.',
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final balance =
                        await sl<ReviewsRepository>().boostFeatured(hours: 24);
                    messenger.showSnackBar(SnackBar(
                        content: Text('Listing boosted for 24h · Balance: $balance')));
                  } on ReviewsException catch (e) {
                    messenger.showSnackBar(SnackBar(
                        content: Text(e.message ?? 'Could not boost listing.')));
                  } catch (_) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Insufficient coins for boost.')));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Icon(Icons.construction_outlined),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Push notifications, in-app chat, and reviews ship in Phases 8–10.',
                        ),
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
