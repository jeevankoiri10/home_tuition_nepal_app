import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/user_role.dart';

/// Two-card role picker shown inside the registration form.
/// **Permanent choice** — see docs/plan.md §5.1.
class RoleSelector extends StatelessWidget {
  const RoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.tutorLabel,
    required this.tutorSubtitle,
    required this.studentLabel,
    required this.studentSubtitle,
  });

  final UserRole? value;
  final ValueChanged<UserRole> onChanged;
  final String tutorLabel;
  final String tutorSubtitle;
  final String studentLabel;
  final String studentSubtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            selected: value == UserRole.tutor,
            icon: Icons.school_outlined,
            title: tutorLabel,
            subtitle: tutorSubtitle,
            onTap: () => onChanged(UserRole.tutor),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _RoleCard(
            selected: value == UserRole.student,
            icon: Icons.person_search_outlined,
            title: studentLabel,
            subtitle: studentSubtitle,
            onTap: () => onChanged(UserRole.student),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardBorder,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          borderRadius: AppRadii.cardBorder,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
