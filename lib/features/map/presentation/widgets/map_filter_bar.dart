import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../tutor_profile/domain/models/profile_enums.dart';
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
              label: const Text('Verified only'),
              selected: filters.verifiedOnly,
              onSelected: (v) => onChanged(filters.copyWith(verifiedOnly: v)),
            ),
            const SizedBox(width: AppSpacing.xs),
            FilterChip(
              label: const Text('Available now'),
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
    final label = filters.level?.label ?? 'All levels';
    return PopupMenuButton<StudentLevel?>(
      tooltip: 'Student level',
      onSelected: (v) => onChanged(
        v == null ? filters.copyWith(clearLevel: true) : filters.copyWith(level: v),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All levels')),
        for (final l in StudentLevel.values) PopupMenuItem(value: l, child: Text(l.label)),
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
    final label = filters.mode == null ? 'Any mode' : filters.mode!.label;
    return PopupMenuButton<TeachingMode?>(
      tooltip: 'Teaching mode',
      onSelected: (v) => onChanged(
        v == null ? filters.copyWith(clearMode: true) : filters.copyWith(mode: v),
      ),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('Any mode')),
        for (final m in TeachingMode.values) PopupMenuItem(value: m, child: Text(m.label)),
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
    return PopupMenuButton<double>(
      tooltip: 'Radius',
      onSelected: (v) => onChanged(filters.copyWith(radiusKm: v)),
      itemBuilder: (_) => [
        for (final r in _options)
          PopupMenuItem(value: r, child: Text('Within ${r.toStringAsFixed(0)} km')),
      ],
      child: Chip(
        label: Text('${filters.radiusKm.toStringAsFixed(0)} km'),
        avatar: const Icon(Icons.radio_button_unchecked, size: 18),
      ),
    );
  }
}
