import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/vacancy.dart';

/// Card used in the Vacancies feed. Mirrors the structured layout seen on
/// competitor broker posts (Gurukul / Tuition Guru / Tuition Serve): code +
/// title + location + grade + subjects + salary + duration + gender pref.
class VacancyCard extends StatelessWidget {
  const VacancyCard({
    super.key,
    required this.vacancy,
    required this.alreadyApplied,
    required this.onTap,
    required this.onApply,
  });

  final Vacancy vacancy;
  final bool alreadyApplied;
  final VoidCallback onTap;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
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
                Text(_ago(vacancy.createdAt),
                    style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Text(vacancy.title, style: tt.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Row(children: [
                const Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Flexible(child: Text(vacancy.areaLabel, style: tt.bodySmall)),
              ]),
              const SizedBox(height: AppSpacing.xs),
              if (vacancy.grade != null)
                Text('Grade: ${vacancy.grade!}', style: tt.bodySmall),
              if (vacancy.subjects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final s in vacancy.subjects)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(s, style: tt.bodySmall),
                      ),
                  ],
                ),
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
                        label: const Text('Applied'),
                      )
                    : FilledButton.icon(
                        onPressed: onApply,
                        icon: const Icon(Icons.send_outlined, size: 16),
                        label: const Text('Apply'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}
