import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/user_role.dart';

/// Shown after sign-in when the same email backs both a tutor and a student
/// profile. Two big square tiles let the user pick which role to enter the
/// app as. If only one role exists the login flow auto-routes and this page
/// is never reached (see [LoginPage]).
class LoginRoleChooserPage extends StatelessWidget {
  const LoginRoleChooserPage({super.key});

  Future<void> _pick(BuildContext context, UserRole role) async {
    // Set the chosen role active so the rest of the app (home, guard) follows
    // it; the guard will route to that role's home or its onboarding.
    try {
      await sl<AuthRepository>().switchActiveRole(role);
    } catch (_) {
      /* fall through to plain routing; guard still applies */
    }
    if (context.mounted) context.go(AppRoutes.routeForRole(role));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: BrandAppBar(
        title: Text(l10n.loginChooserTitle),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loginChooserSubtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _RoleTile(
                    icon: Icons.co_present_outlined,
                    label: l10n.loginChooserAsTutor,
                    onTap: () => _pick(context, UserRole.tutor),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _RoleTile(
                    icon: Icons.school_outlined,
                    label: l10n.loginChooserAsStudent,
                    onTap: () => _pick(context, UserRole.student),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
        child: InkWell(
          borderRadius: AppRadii.cardBorder,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 56, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
