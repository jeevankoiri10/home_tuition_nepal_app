import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Canonical "verified tutor" badge (see CLAUDE.md §2). A compact tick shown
/// next to a (masked) name to signal an admin-verified identity.
///
/// Icon-only and presentational so it can sit inline beside a name on any
/// surface (map card, contact-unlock sheet, …). Pass [semanticLabel] — already
/// localized by the caller — so screen readers announce the badge.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({
    super.key,
    this.size = 14,
    this.color = AppColors.primary,
    this.semanticLabel,
  });

  final double size;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.verified,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}
