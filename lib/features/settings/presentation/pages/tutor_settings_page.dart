import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../../core/widgets/masked_avatar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/theme_mode_toggle.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/models/user_profile.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../tutor_profile/presentation/blocs/tutor_profile_bloc.dart';
import '../../../tutor_profile/presentation/pages/tutor_profile_settings_page.dart';
import '../../../tutor_profile/presentation/widgets/draft_banner.dart';
import '../widgets/role_switch_section.dart';

/// Landing page for the tutor's Settings tab. Shows who is signed in, a
/// snapshot of profile completion, and the two primary actions a tutor needs
/// here: open the profile editor and log out. The editor itself lives in
/// [TutorProfileSettingsPage] and is reached via the "Update profile" button.
class TutorSettingsPage extends StatelessWidget {
  const TutorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        return Scaffold(
          appBar: BrandAppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (user != null) _ProfileHeader(user: user),
              const SizedBox(height: AppSpacing.lg),
              const _EditProfileButton(),
              const SizedBox(height: AppSpacing.lg),
              _LanguageSection(),
              const SizedBox(height: AppSpacing.lg),
              _ThemeSection(),
              const SizedBox(height: AppSpacing.lg),
              const RoleSwitchSection(),
              const SizedBox(height: AppSpacing.xl),
              const _LogoutButton(),
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
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tutorSettingsProfileSection,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.cardBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    MaskedAvatar(name: user.firstName, radius: 32),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: tt.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.handle}',
                            style: tt.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: tt.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Completion snapshot mirrors the banner shown inside the
                // editor, so the tutor sees their publish status here too.
                BlocBuilder<TutorProfileBloc, TutorProfileState>(
                  builder: (context, state) {
                    final profile = state.profile;
                    if (profile == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: DraftBanner(
                        completion: profile.profileCompletion,
                        isPublished: profile.isPublished,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PrimaryButton(
      label: l10n.tutorSettingsEditProfileCta,
      onPressed: () {
        // Reuse the same TutorProfileBloc instance the Settings tab already
        // holds so edits made in the editor reflect here on return without a
        // reload (and we don't spin up a second loader against the repo).
        final bloc = context.read<TutorProfileBloc>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider<TutorProfileBloc>.value(
              value: bloc,
              child: const TutorProfileSettingsPage(),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsLanguageSection,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.cardBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(l10n.settingsLanguageHint),
              trailing: const LanguageToggle(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsThemeSection,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.cardBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.settingsThemeHint, style: tt.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: ThemeModeToggle(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

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
