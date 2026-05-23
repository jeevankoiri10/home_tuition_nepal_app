import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Wraps a row of FilterChips. Used for languages, subjects, levels, etc.
class ChipMultiSelect<T> extends StatelessWidget {
  const ChipMultiSelect({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelOf,
  });

  final List<T> options;
  final Set<T> selected;
  final ValueChanged<Set<T>> onChanged;
  final String Function(T) labelOf;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (final opt in options)
          FilterChip(
            label: Text(labelOf(opt)),
            selected: selected.contains(opt),
            onSelected: (yes) {
              final next = Set<T>.from(selected);
              if (yes) {
                next.add(opt);
              } else {
                next.remove(opt);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
