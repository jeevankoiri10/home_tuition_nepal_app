import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/map_tutor.dart';

/// Card shown in the carousel (bottom sheet) and in the full list view.
/// Compact horizontally so several can sit in the carousel; expands fluidly
/// when shown in the list.
class TutorMapCard extends StatelessWidget {
  const TutorMapCard({
    super.key,
    required this.tutor,
    required this.selected,
    required this.onTap,
    required this.onContact,
    this.listMode = false,
  });

  final MapTutor tutor;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onContact;
  final bool listMode;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardBorder,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadii.cardBorder,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _Avatar(verified: tutor.verified),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tutor.maskedName,
                              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tutor.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: AppColors.primary),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              '${tutor.areaLabel} · ${tutor.formatDistance()}',
                              style: tt.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _RatingBadge(rating: tutor.rating, count: tutor.ratingCount),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (tutor.topSubjects.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final s in tutor.topSubjects)
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
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (tutor.formatFromPrice() != null)
                  Text(tutor.formatFromPrice()!,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (tutor.available)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Available',
                        style: TextStyle(color: Color(0xFF2E7D32), fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(borderRadius: AppRadii.inputBorder),
                ),
                icon: const Icon(Icons.lock_outline, size: 14),
                label: const Text('Contact'),
                onPressed: onContact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        border: Border.all(
          color: verified ? const Color(0xFFFFD54F) : Colors.transparent,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person_outline, color: AppColors.primary),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.count});
  final num rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const Text('Not rated',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: Color(0xFFFFB300), size: 14),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
