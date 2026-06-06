import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
            _SubjectChip(filters: filters, onChanged: onChanged),
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
            // Reset affordance — only shown once at least one filter narrows
            // the default, so the bar stays uncluttered on first load.
            if (filters.hasActiveFilters) ...[
              const SizedBox(width: AppSpacing.xs),
              ActionChip(
                avatar: const Icon(Icons.clear, size: 18),
                label: Text(l10n.filterClearAll),
                onPressed: () => onChanged(const MapFilters()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Background tint for a dropdown chip whose value differs from the default,
/// so an active filter reads as "on" at a glance. Null = default styling.
Color? _activeChipColor(bool active) =>
    active ? AppColors.primary.withValues(alpha: 0.12) : null;

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
        backgroundColor: _activeChipColor(filters.level != null),
        avatar: const Icon(Icons.school_outlined, size: 18),
        deleteIcon: const Icon(Icons.arrow_drop_down, size: 18),
        onDeleted: () {}, // visual hint only; opening the menu happens via parent tap
      ),
    );
  }
}

/// Free-text subject filter (student_UI.md §4.3.2). Tapping opens a small
/// search dialog; the entered subject is matched against each tutor's subjects
/// server-side (`subjectQuery`). Highlighted while a subject is active.
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.filters, required this.onChanged});
  final MapFilters filters;
  final ValueChanged<MapFilters> onChanged;

  Future<void> _edit(BuildContext context) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => _SubjectDialog(initial: filters.subjectQuery ?? ''),
    );
    if (result == null) return; // cancelled / dismissed — leave filters as-is
    final trimmed = result.trim();
    onChanged(trimmed.isEmpty
        ? filters.copyWith(clearSubject: true)
        : filters.copyWith(subjectQuery: trimmed));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = filters.subjectQuery;
    final active = query != null && query.isNotEmpty;
    return ActionChip(
      avatar: const Icon(Icons.menu_book_outlined, size: 18),
      label: Text(active ? query : l10n.subjectNameLabel),
      backgroundColor: _activeChipColor(active),
      onPressed: () => _edit(context),
    );
  }
}

/// Dialog that owns its own [TextEditingController] so the controller's
/// lifecycle is tied to the dialog (disposed after its exit animation),
/// avoiding use-after-dispose. Pops: the entered text (OK), `''` (Clear),
/// or null (Cancel / dismiss).
class _SubjectDialog extends StatefulWidget {
  const _SubjectDialog({required this.initial});
  final String initial;

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.subjectNameLabel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(hintText: l10n.subjectHint),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''), // clear the subject
          child: Text(l10n.actionClear),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context), // cancel — no change
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
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
      child: Chip(
        label: Text(label),
        backgroundColor: _activeChipColor(filters.mode != null),
        avatar: const Icon(Icons.swap_horiz_outlined, size: 18),
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip({required this.filters, required this.onChanged});
  final MapFilters filters;
  final ValueChanged<MapFilters> onChanged;

  // `null` is rendered as "No limit" — the default when the map first loads.
  static const _options = <double?>[null, 1, 3, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = filters.radiusKm;
    final label = radius == null
        ? l10n.filterRadiusNoLimit
        : l10n.filterRadiusKm(radius.toInt());
    return PopupMenuButton<double?>(
      tooltip: l10n.filterRadiusTooltip,
      onSelected: (v) => onChanged(
        v == null ? filters.copyWith(clearRadius: true) : filters.copyWith(radiusKm: v),
      ),
      itemBuilder: (_) => [
        for (final r in _options)
          PopupMenuItem(
            value: r,
            child: Text(r == null
                ? l10n.filterRadiusOptionNoLimit
                : l10n.filterRadiusWithinKm(r.toInt())),
          ),
      ],
      child: Chip(
        label: Text(label),
        backgroundColor: _activeChipColor(filters.radiusKm != null),
        avatar: const Icon(Icons.radio_button_unchecked, size: 18),
      ),
    );
  }
}
