import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/profile_enums.dart';
import '../../domain/models/tutor_availability.dart';
import '../enum_labels.dart';

/// 3 time-bands (rows) × 7 days (columns) toggle grid. Tap a cell to toggle,
/// tap a row label to toggle the whole row. The data model is in
/// [TutorAvailability]; this widget only handles presentation.
class AvailabilityGrid extends StatelessWidget {
  const AvailabilityGrid({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TutorAvailability value;
  final ValueChanged<TutorAvailability> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Table(
      defaultColumnWidth: const FlexColumnWidth(),
      columnWidths: const {0: FlexColumnWidth(1.4)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _headerRow(l10n),
        for (final band in TimeBand.values) _bandRow(l10n, band),
      ],
    );
  }

  TableRow _headerRow(AppLocalizations l10n) {
    return TableRow(
      children: [
        const SizedBox(height: 36),
        for (final day in Weekday.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Center(
              child: Text(
                day.localizedShort(l10n),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  TableRow _bandRow(AppLocalizations l10n, TimeBand band) {
    final allOn = Weekday.values.every((d) => value.isAvailable(band, d));
    return TableRow(
      children: [
        InkWell(
          onTap: () => onChanged(value.toggleRow(band, value: !allOn)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              band.localized(l10n),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        for (final day in Weekday.values)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Center(
              child: Checkbox(
                value: value.isAvailable(band, day),
                onChanged: (_) => onChanged(value.toggle(band, day)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
      ],
    );
  }
}
