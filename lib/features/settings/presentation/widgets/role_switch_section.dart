import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/domain/models/user_role.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';

/// Settings section that lets a signed-in user switch the account between the
/// tutor and student dashboards. The same email can act as both roles; tapping
/// switches the active role and the router guard routes to that role's home
/// (or its onboarding the first time). Reused by both settings pages.
class RoleSwitchSection extends StatefulWidget {
  const RoleSwitchSection({super.key});

  @override
  State<RoleSwitchSection> createState() => _RoleSwitchSectionState();
}

class _RoleSwitchSectionState extends State<RoleSwitchSection> {
  bool _busy = false;

  Future<void> _switch(UserRole target) async {
    setState(() => _busy = true);
    try {
      await sl<AuthRepository>().switchActiveRole(target);
      if (!mounted) return;
      context.go(AppRoutes.routeForRole(target));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final activeRole = context.select<AuthBloc, UserRole?>(
      (b) => b.state.user?.activeRole,
    );
    if (activeRole == null) return const SizedBox.shrink();

    final target = activeRole == UserRole.tutor
        ? UserRole.student
        : UserRole.tutor;
    final label = target == UserRole.tutor
        ? l10n.switchToTutorView
        : l10n.switchToStudentView;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.accountSection,
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.cardBorder,
          ),
          child: ListTile(
            leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
            title: Text(label),
            subtitle: Text(l10n.switchRoleSubtitle),
            trailing: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _busy ? null : () => _switch(target),
          ),
        ),
      ],
    );
  }
}
