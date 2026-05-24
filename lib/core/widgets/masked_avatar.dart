import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular avatar that prefers an image but falls back to a single-letter
/// monogram derived from a name. Used wherever a profile picture is shown
/// (settings header, comments, list rows) so the fallback style stays
/// consistent app-wide.
class MaskedAvatar extends StatelessWidget {
  const MaskedAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
        // Initials still render if the network image fails to load.
        onBackgroundImageError: (_, _) {},
        child: const SizedBox.shrink(),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? Colors.white,
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
