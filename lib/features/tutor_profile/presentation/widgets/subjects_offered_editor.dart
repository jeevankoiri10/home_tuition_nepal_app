import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/profile_enums.dart';
import '../../domain/models/tutor_offering.dart';
import '../enum_labels.dart';

/// Editable table of Level / Subject / Price [period] rows.
/// Bound directly to a TutorProfile.offerings list.
class SubjectsOfferedEditor extends StatelessWidget {
  const SubjectsOfferedEditor({
    super.key,
    required this.offerings,
    required this.allowedLevels,
    required this.onChanged,
  });

  final List<TutorOffering> offerings;
  final Set<StudentLevel> allowedLevels;
  final ValueChanged<List<TutorOffering>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (offerings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(l10n.subjectsEmpty,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
        for (int i = 0; i < offerings.length; i++)
          _OfferingSection(
            key: ValueKey('${offerings[i].level.value}-${offerings[i].subject}-$i'),
            index: i,
            offering: offerings[i],
            allowedLevels: allowedLevels,
            onChanged: (next) {
              final list = List<TutorOffering>.from(offerings);
              list[i] = next;
              onChanged(list);
            },
            onRemove: () {
              final list = List<TutorOffering>.from(offerings)..removeAt(i);
              onChanged(list);
            },
          ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.addSubject),
            onPressed: allowedLevels.isEmpty
                ? null
                : () {
                    final firstLevel = allowedLevels.first;
                    onChanged([
                      ...offerings,
                      TutorOffering(
                        level: firstLevel,
                        subject: '',
                        priceMinNpr: 0,
                      ),
                    ]);
                  },
          ),
        ),
        if (allowedLevels.isEmpty)
          Text(
            l10n.subjectsRequireLevel,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
      ],
    );
  }
}

/// One subject entry rendered as a stacked-field card. Replaces the older
/// single-line row layout so each subject reads top-to-bottom (per Phase 18
/// of the tobe_done doc) and can grow without overflowing the screen.
class _OfferingSection extends StatefulWidget {
  const _OfferingSection({
    super.key,
    required this.index,
    required this.offering,
    required this.allowedLevels,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final TutorOffering offering;
  final Set<StudentLevel> allowedLevels;
  final ValueChanged<TutorOffering> onChanged;
  final VoidCallback onRemove;

  @override
  State<_OfferingSection> createState() => _OfferingSectionState();
}

class _OfferingSectionState extends State<_OfferingSection> {
  late final TextEditingController _subject;
  late final TextEditingController _min;
  late final TextEditingController _max;

  @override
  void initState() {
    super.initState();
    _subject = TextEditingController(text: widget.offering.subject);
    _min = TextEditingController(
      text: widget.offering.priceMinNpr == 0 ? '' : widget.offering.priceMinNpr.toString(),
    );
    _max = TextEditingController(
      text: widget.offering.priceMaxNpr?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _subject.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  void _emit() {
    final min = num.tryParse(_min.text.trim()) ?? 0;
    final max = num.tryParse(_max.text.trim());
    widget.onChanged(widget.offering.copyWith(
      subject: _subject.text.trim(),
      priceMinNpr: min,
      priceMaxNpr: max == null || max <= min ? null : max,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.cardBorder),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.subjectSectionHeading(widget.index + 1),
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: l10n.removeAction,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<StudentLevel>(
              initialValue: widget.allowedLevels.contains(widget.offering.level)
                  ? widget.offering.level
                  : widget.allowedLevels.first,
              decoration: InputDecoration(labelText: l10n.subjectLevelLabel),
              items: [
                for (final l in widget.allowedLevels)
                  DropdownMenuItem(
                      value: l,
                      child: Text(l.localized(l10n), overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => widget.onChanged(widget.offering.copyWith(level: v)),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _subject,
              decoration: InputDecoration(
                labelText: l10n.subjectNameLabel,
                hintText: l10n.subjectHint,
              ),
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _min,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.subjectPriceLabel,
                      hintText: l10n.priceHint,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<PricePeriod>(
                    initialValue: widget.offering.period,
                    decoration: InputDecoration(labelText: l10n.subjectPeriodLabel),
                    items: [
                      for (final p in PricePeriod.values)
                        DropdownMenuItem(
                            value: p, child: Text(p.localizedSuffix(l10n))),
                    ],
                    onChanged: (v) => widget.onChanged(
                        widget.offering.copyWith(period: v ?? PricePeriod.month)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
