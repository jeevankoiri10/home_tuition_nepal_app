import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/review.dart';
import '../cubit/reviews_cubit.dart';
import '../cubit/reviews_state.dart';
import 'star_rating_input.dart';

/// Read-only modal listing a profile's reviews with a rating-summary header.
/// Open it via [showForTutor] / [showForStudent]; it owns its own
/// [ReviewsCubit] for the lifetime of the sheet.
class ReviewsSheet extends StatelessWidget {
  const ReviewsSheet._();

  static Future<void> showForTutor(
    BuildContext context, {
    required String tutorId,
  }) {
    return _show(context, (cubit) => cubit.loadForTutor(tutorId));
  }

  static Future<void> showForStudent(
    BuildContext context, {
    required String studentId,
  }) {
    return _show(context, (cubit) => cubit.loadForStudent(studentId));
  }

  static Future<void> _show(
    BuildContext context,
    void Function(ReviewsCubit cubit) load,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider<ReviewsCubit>(
        create: (_) {
          final cubit = sl<ReviewsCubit>();
          load(cubit);
          return cubit;
        },
        child: const ReviewsSheet._(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return BlocBuilder<ReviewsCubit, ReviewsState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                  child: Text(l10n.reviewsTitle,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(child: _Body(state: state, controller: scrollController)),
              ],
            );
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller});

  final ReviewsState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading || state.status == ReviewsStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ReviewsStatus.error) {
      return _Centered(text: l10n.reviewsLoadError);
    }
    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      itemCount: state.reviews.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _SummaryHeader(summary: state.summary);
        }
        return _ReviewTile(review: state.reviews[index - 1]);
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.summary});

  final RatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          Text(
            summary.count == 0 ? '—' : summary.average.toStringAsFixed(1),
            style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StarRatingDisplay(rating: summary.average, size: 18),
              const SizedBox(height: 2),
              Text(l10n.reviewsCount(summary.count),
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final date = MaterialLocalizations.of(context).formatShortDate(review.createdAt);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StarRatingDisplay(rating: review.stars.toDouble()),
              Text(date,
                  style: tt.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          if (review.text != null && review.text!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(review.text!, style: tt.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
