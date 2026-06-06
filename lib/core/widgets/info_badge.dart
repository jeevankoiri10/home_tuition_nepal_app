import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Compact icon + label pill for surfacing a single at-a-glance fact about a
/// tutor (teaching mode, years of experience, price tier, …).
///
/// A recurring UI pattern (see CLAUDE.md §2) reused across the tutor card and
/// any other surface that needs to make a detail visible without opening a
/// full profile.
class InfoBadge extends StatelessWidget {
  const InfoBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;

  /// Foreground colour for the icon and text. The background is a soft tint of
  /// the same colour. Defaults to the secondary text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
