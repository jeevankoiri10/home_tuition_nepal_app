import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../tutor_profile/domain/models/profile_enums.dart';
import '../../../tutor_profile/presentation/enum_labels.dart';
import '../../domain/models/map_filters.dart';

/// Sticky horizontal chip bar driving the Map filter state.
/// Layout: Level · Mode · Verified · Available · Radius.
class MapFilterBar extends StatelessWidget {
  const MapFilterBar({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final MapFilters filters;
  final ValueChanged<MapFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            _LevelChip(filters: filters, onChanged: onChanged),
            const SizedBox(width: AppSpacing.xs),
            _ModeChip(filters: filters, onChanged: onChanged),
            const SizedBox(width: AppSpacing.xs),
            FilterChip(
              label: Text(l10n.filterVerifiedOnly),
              selected: filters.verifiedOnly,
              onSelected: (v) => onChanged(filters.copyWith(verifiedOnly: v)),
            ),
            const SizedBox(width: AppSpacing.xs),
            FilterChip(
              label: Text(l10n.filterAvailableNow),
              selected: filters.availableOnly,
              onSelected: (v) => onChanged(filters.copyWith(availableOnly: v)),
            ),
            const SizedBox(width: AppSpacing.xs),
            _RadiusChip(filters: filters, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.filters, required this.onChanged});
  final MapFilters filters;
  final ValueChanged<MapFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = filters.level?.localized(l10n) ?? l10n.filterAllLevels;
    return PopupMenuButton<StudentLevel?>(
      tooltip: l10n.filterLevelTooltip,
      onSelected: (v) => onChanged(
        v == null ? filters.copyWith(clearLevel: true) : filters.copyWith(level: v),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(l10n.filterAllLevels)),
        for (final l in StudentLevel.values)
          PopupMenuItem(value: l, child: Text(l.localized(l10n))),
      ],
      child: Chip(
        label: Text(label),
        avatar: const Icon(Icons.school_outlined, size: 18),
        deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
        onDeleted: () {}, // visual hint only; opening the menu happens via parent tap
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.filters, required this.onChanged});
  final MapFilters filters;
  final ValueChanged<MapFilters> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = filters.mode == null ? l10n.filterAnyMode : filters.mode!.localized(l10n);
    return PopupMenuButton<TeachingMode?>(
      tooltip: l10n.filterTeachingModeTooltip,
      onSelected: (v) => onChanged(
        v == null ? filters.copyWith(clearMode: true) : filters.copyWith(mode: v),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(value: null, child: Text(l10n.filterAnyMode)),
        for (final m in TeachingMode.values)
          PopupMenuItem(value: m, child: Text(m.localized(l10n))),
      ],
      child: Chip(label: Text(label), avatar: const Icon(Icons.swap_horiz_outlined, size: 18)),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.filters, required this.onChanged});
  final MapFilters filters;
  final ValueChanged<MapFilters> onChanged;

  static const _options = <double>[1, 3, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<double>(
      tooltip: l10n.filterRadiusTooltip,
      onSelected: (v) => onChanged(filters.copyWith(radiusKm: v)),
      itemBuilder: (_) => [
        for (final r in _options)
          PopupMenuItem(value: r, child: Text(l10n.filterRadiusWithinKm(r.toInt()))),
      ],
      child: Chip(
        label: Text(l10n.filterRadiusKm(filters.radiusKm.toInt())),
        avatar: const Icon(Icons.radio_button_unchecked, size: 18),
      ),
    );
  }
}
