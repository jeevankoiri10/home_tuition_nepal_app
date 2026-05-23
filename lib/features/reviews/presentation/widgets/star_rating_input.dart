import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// Tap-to-set 1–5 star input. Used by the Submit Review sheet.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          iconSize: size,
          padding: EdgeInsets.zero,
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? const Color(0xFFFFB300) : null,
          ),
          onPressed: () => onChanged(i + 1),
        );
      }),
    );
  }
}

/// Read-only star strip + count (used on tutor cards / profile headers).
class StarRatingBadge extends StatelessWidget {
  const StarRatingBadge({super.key, required this.average, required this.count});

  final double average;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return Text(AppLocalizations.of(context).notRated,
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
        const SizedBox(width: 2),
        Text('${average.toStringAsFixed(1)} · $count',
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
