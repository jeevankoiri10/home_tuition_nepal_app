import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/review.dart';
import '../../domain/reviews_repository.dart';
import 'reviews_state.dart';

/// Loads the read-only reviews view for a tutor or a student. Load-only, so a
/// Cubit (no events) — mirrors the locale/theme cubits.
class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit(this._repository) : super(const ReviewsState());

  final ReviewsRepository _repository;

  Future<void> loadForTutor(String tutorId) => _load(
        () => _repository.summaryForTutor(tutorId),
        () => _repository.listForTutor(tutorId),
      );

  Future<void> loadForStudent(String studentId) => _load(
        () => _repository.summaryForStudent(studentId),
        () => _repository.listForStudent(studentId),
      );

  Future<void> _load(
    Future<RatingSummary> Function() loadSummary,
    Future<List<Review>> Function() loadReviews,
  ) async {
    emit(state.copyWith(status: ReviewsStatus.loading));
    try {
      final summary = await loadSummary();
      final reviews = await loadReviews();
      emit(state.copyWith(
        status: ReviewsStatus.ready,
        summary: summary,
        reviews: reviews,
      ));
    } on ReviewsException catch (e) {
      emit(state.copyWith(status: ReviewsStatus.error, error: e.message));
    }
  }
}
