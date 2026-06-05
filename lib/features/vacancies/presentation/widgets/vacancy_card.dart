import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/subject_chips.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/vacancy.dart';

/// Card used in the Vacancies feed. Mirrors the structured layout seen on
/// competitor broker posts (Gurukul / Tuition Guru / Tuition Serve): code +
/// title + location + grade + subjects + salary + duration + gender pref.
class VacancyCard extends StatelessWidget {
  const VacancyCard({
    super.key,
    required this.vacancy,
    required this.alreadyApplied,
    required this.connectCost,
    required this.onTap,
    required this.onApply,
  });

  final Vacancy vacancy;
  final bool alreadyApplied;

  /// Coins this application will cost — shown on the apply button so the tutor
  /// sees the price before opening the apply sheet. Computed via `ConnectCost`.
  final int connectCost;
  final VoidCallback onTap;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.vacancyCardSemantics(
        vacancy.code ?? '',
        vacancy.title,
        vacancy.areaLabel,
        vacancy.formatSalary(),
        alreadyApplied ? l10n.vacancyAlreadyAppliedSuffix : '',
      ),
      child: Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.cardBorder,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(vacancy.code ?? '—',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                const Spacer(),
                Text(_ago(l10n, vacancy.createdAt),
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Text(vacancy.title, style: tt.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Row(children: [
                const Icon(Icons.place_outlined, size: 14),
                const SizedBox(width: 2),
                Flexible(child: Text(vacancy.areaLabel, style: tt.bodySmall)),
              ]),
              const SizedBox(height: AppSpacing.xs),
              if (vacancy.grade != null)
                Text(l10n.vacancyGradePrefix(vacancy.grade!), style: tt.bodySmall),
              if (vacancy.subjects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                SubjectChips(subjects: vacancy.subjects),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                Text(vacancy.formatSalary(),
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (vacancy.durationText != null)
                  Text(vacancy.durationText!, style: tt.bodySmall),
              ]),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: alreadyApplied
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.check, size: 16),
                        label: Text(l10n.vacancyAppliedLabel),
                      )
                    : FilledButton.icon(
                        onPressed: onApply,
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: Text(l10n.applyButtonLabel(connectCost)),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  static String _ago(AppLocalizations l10n, DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return l10n.relativeMinutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.relativeHoursAgo(d.inHours);
    return l10n.relativeDaysAgo(d.inDays);
  }
}
