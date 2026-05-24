import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../../core/widgets/masked_avatar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';

class StudentSettingsPage extends StatelessWidget {
  const StudentSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (user != null) _ProfileHeader(user: user),
              const SizedBox(height: AppSpacing.lg),
              _LanguageSection(),
              const SizedBox(height: AppSpacing.lg),
              if (user != null) _ReferralSection(user: user),
              const SizedBox(height: AppSpacing.xl),
              _LogoutButton(),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            MaskedAvatar(name: user.firstName, radius: 32),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName, style: tt.titleLarge),
                  const SizedBox(height: 2),
                  Text('@${user.handle}',
                      style: tt.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(user.email,
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Section(
      title: l10n.settingsLanguageSection,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.language),
        title: Text(l10n.settingsLanguageHint),
        trailing: const LanguageToggle(),
      ),
    );
  }
}

class _ReferralSection extends StatelessWidget {
  const _ReferralSection({required this.user});

  final UserProfile user;

  String get _code => user.handle.toUpperCase();

  Future<void> _copy(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsReferralCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return _Section(
      title: l10n.settingsReferralSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.settingsReferralHint(AppConstants.referralCoinReward),
            style: tt.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.settingsReferralCodeLabel,
              style: tt.labelMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadii.inputBorder,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _code,
                    style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l10n.settingsReferralCopy),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
      ),
      onPressed: () {
        context.read<AuthBloc>().add(const AuthSignOutRequested());
        context.go(AppRoutes.splash);
      },
      icon: const Icon(Icons.logout),
      label: Text(l10n.settingsLogoutLabel),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Card(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ],
    );
  }
}
