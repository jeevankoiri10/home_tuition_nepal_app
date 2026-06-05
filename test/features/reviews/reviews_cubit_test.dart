import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/reviews/domain/models/review.dart';
import 'package:home_tuition_nepal_app/features/reviews/domain/reviews_repository.dart';
import 'package:home_tuition_nepal_app/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:home_tuition_nepal_app/features/reviews/presentation/cubit/reviews_state.dart';

/// Minimal stub exercising only the read methods the cubit uses; the write
/// methods are never called by [ReviewsCubit].
class _StubReviewsRepository implements ReviewsRepository {
  _StubReviewsRepository({this.summary, this.reviews, this.throwOnList = false});

  final RatingSummary? summary;
  final List<Review>? reviews;
  final bool throwOnList;

  @override
  Future<RatingSummary> summaryForTutor(String tutorId) async =>
      summary ?? const RatingSummary(average: 0, count: 0);

  @override
  Future<List<Review>> listForTutor(String tutorId, {int limit = 50}) async {
    if (throwOnList) throw ReviewsException('boom', 'failed');
    return reviews ?? const [];
  }

  @override
  Future<RatingSummary> summaryForStudent(String studentId) async =>
      summary ?? const RatingSummary(average: 0, count: 0);

  @override
  Future<List<Review>> listForStudent(String studentId, {int limit = 50}) async {
    if (throwOnList) throw ReviewsException('boom', 'failed');
    return reviews ?? const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} not stubbed');
}

Review _review(int stars) => Review(
      id: 'r$stars',
      tutorId: 't1',
      studentId: 's1',
      stars: stars,
      text: 'Great',
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('ReviewsCubit', () {
    blocTest<ReviewsCubit, ReviewsState>(
      'loadForTutor emits loading then ready with summary + reviews',
      build: () => ReviewsCubit(_StubReviewsRepository(
        summary: const RatingSummary(average: 4.5, count: 2),
        reviews: [_review(5), _review(4)],
      )),
      act: (cubit) => cubit.loadForTutor('t1'),
      expect: () => [
        const ReviewsState(status: ReviewsStatus.loading),
        isA<ReviewsState>()
            .having((s) => s.status, 'status', ReviewsStatus.ready)
            .having((s) => s.summary.average, 'average', 4.5)
            .having((s) => s.summary.count, 'count', 2)
            .having((s) => s.reviews.length, 'reviews', 2),
      ],
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'ready with no reviews reports isEmpty',
      build: () => ReviewsCubit(_StubReviewsRepository()),
      act: (cubit) => cubit.loadForTutor('t1'),
      verify: (cubit) {
        expect(cubit.state.status, ReviewsStatus.ready);
        expect(cubit.state.isEmpty, isTrue);
      },
    );

    blocTest<ReviewsCubit, ReviewsState>(
      'maps a ReviewsException to the error state',
      build: () => ReviewsCubit(_StubReviewsRepository(throwOnList: true)),
      act: (cubit) => cubit.loadForStudent('s1'),
      verify: (cubit) {
        expect(cubit.state.status, ReviewsStatus.error);
        expect(cubit.state.error, 'failed');
      },
    );
  });
}
