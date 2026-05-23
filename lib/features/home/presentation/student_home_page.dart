import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';

/// Placeholder Student home — shipped in Phase 2 so the post-verification
/// redirect lands somewhere meaningful. Phase 4 replaces this with the
/// inDrive-style locality-first map view.
class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Student home'),
            actions: [
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
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Welcome, ${user?.displayName ?? '—'}',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('Handle: ${user?.handle ?? '—'}',
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
                        const Expanded(
                          child: Text(
                            'The locality-first map (the headline feature) ships in Phase 4.',
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.map),
                          child: const Text('Preview'),
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
              const Text('CURRENT BALANCE',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              Text('$coins coins',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
