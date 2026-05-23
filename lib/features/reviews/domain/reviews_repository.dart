import 'models/review.dart';

class ReviewsException implements Exception {
  ReviewsException(this.code, [this.message]);
  final String code;
  final String? message;

  bool get isGateNotMet => code == 'gate_not_met';
  bool get isPhoneInReview => code == 'phone_in_review';

  @override
  String toString() => 'ReviewsException($code, $message)';
}

abstract class ReviewsRepository {
  Future<List<Review>> listForTutor(String tutorId, {int limit = 50});
  Future<TutorRatingSummary> summaryForTutor(String tutorId);

  /// Submits or replaces the caller's review for `tutorId`.
  /// Throws ReviewsException('gate_not_met') if no prior unlock or assignment.
  Future<Review> submit({
    required String tutorId,
    required int stars,
    String? text,
  });

  /// Boost the caller's own tutor profile to "featured" for [hours].
  /// Returns the new coin balance.
  Future<int> boostFeatured({int hours = 24});

  /// Promote `jobId` (caller must own it) to the top of tutor feeds for [hours].
  /// Returns the new coin balance.
  Future<int> promoteJob({required String jobId, int hours = 24});
}
