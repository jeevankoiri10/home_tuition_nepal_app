import 'package:equatable/equatable.dart';

import '../../domain/models/review.dart';

enum ReviewsStatus { initial, loading, ready, error }

/// Read-only view state for a person's (tutor or student) reviews: the rolled-up
/// [summary] plus the most recent [reviews].
class ReviewsState extends Equatable {
  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.summary = const RatingSummary(average: 0, count: 0),
    this.reviews = const [],
    this.error,
  });

  final ReviewsStatus status;
  final RatingSummary summary;
  final List<Review> reviews;
  final String? error;

  bool get isLoading => status == ReviewsStatus.loading;
  bool get isEmpty => status == ReviewsStatus.ready && reviews.isEmpty;

  ReviewsState copyWith({
    ReviewsStatus? status,
    RatingSummary? summary,
    List<Review>? reviews,
    String? error,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      reviews: reviews ?? this.reviews,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, summary, reviews, error];
}
