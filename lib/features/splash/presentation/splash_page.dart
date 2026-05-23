import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../app/router.dart';
import '../../../core/blocs/locale_cubit.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRoute());
  }

  void _maybeAutoRoute() {
    if (_routed) return;
    final localeCubit = context.read<LocaleCubit>();
    if (!localeCubit.hasUserSelection) return;
    // Locale already chosen on a previous launch — skip the picker.
    final auth = context.read<AuthBloc>().state;
    if (auth.status == AuthStatus.authenticated && auth.user != null) {
      _routed = true;
      context.go(AppRoutes.routeForRole(auth.user!.role));
    } else if (auth.status == AuthStatus.awaitingOtp) {
      _routed = true;
      context.go(AppRoutes.otp);
    } else {
      _routed = true;
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (_, _) => _maybeAutoRoute(),
      child: const _SplashContent(),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  Future<void> _select(BuildContext context, String code) async {
    await sl<LocaleCubit>().set(Locale(code));
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const _BrandHeader(),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                l10n.languagePickerTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.lg),
              _LanguageButton(
                label: l10n.languageNepali,
                onTap: () => _select(context, AppConstants.localeNe),
              ),
              const SizedBox(height: AppSpacing.md),
              _LanguageButton(
                label: l10n.languageEnglish,
                onTap: () => _select(context, AppConstants.localeEn),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            gradient: AppColors.brandGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school_outlined, color: Colors.white, size: 56),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.appName, style: textTheme.displayMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.publisher, style: textTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.appTagline, style: textTheme.titleMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.inputBorder),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
