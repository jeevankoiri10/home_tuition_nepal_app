import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Reusable wrap of subject/tag chips (see CLAUDE.md §2 — a recurring chip
/// pattern that must not be copy-pasted). Renders [subjects] as compact rounded
/// pills.
///
/// Returns an empty box when [subjects] is empty so callers can drop it in
/// unconditionally; callers that own surrounding spacing should still gate it.
class SubjectChips extends StatelessWidget {
  const SubjectChips({
    super.key,
    required this.subjects,
    this.spacing = 6,
  });

  final List<String> subjects;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Wrap(
      spacing: spacing,
      runSpacing: 4,
      children: [
        for (final subject in subjects)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(subject, style: textStyle),
          ),
      ],
    );
  }
}
