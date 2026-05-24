import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/profile_enums.dart';
import '../enum_labels.dart';

class TeachingModeSelector extends StatelessWidget {
  const TeachingModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TeachingMode value;
  final ValueChanged<TeachingMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TeachingMode.values
          .map(
            (mode) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: _ModeCard(
                  mode: mode,
                  selected: mode == value,
                  onTap: () => onChanged(mode),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.selected, required this.onTap});

  final TeachingMode mode;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (mode) {
      case TeachingMode.online:
        return Icons.computer_outlined;
      case TeachingMode.offline:
        return Icons.home_outlined;
      case TeachingMode.both:
        return Icons.swap_horiz_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
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
            Icon(_icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(mode.localized(AppLocalizations.of(context)),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
