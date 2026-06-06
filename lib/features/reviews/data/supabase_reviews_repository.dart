import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/review.dart';
import '../domain/reviews_repository.dart';

class SupabaseReviewsRepository implements ReviewsRepository {
  SupabaseReviewsRepository(this._client);
  final sb.SupabaseClient _client;

  @override
  Future<List<Review>> listForTutor(String tutorId, {int limit = 50}) async {
    try {
      final rows = await _client
          .from('reviews')
          .select()
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>().map(Review.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw ReviewsException('list_failed', e.message);
    }
  }

  @override
  Future<TutorRatingSummary> summaryForTutor(String tutorId) async {
    try {
      final row = await _client
          .from('tutors')
          .select('rating, rating_count')
          .eq('id', tutorId)
          .maybeSingle();
      if (row == null) return const TutorRatingSummary(average: 0, count: 0);
      return TutorRatingSummary(
        average: ((row['rating'] as num?) ?? 0).toDouble(),
        count: (row['rating_count'] as int?) ?? 0,
      );
    } on sb.PostgrestException catch (e) {
      throw ReviewsException('summary_failed', e.message);
    }
  }

  @override
  Future<Review> submit({
    required String tutorId,
    required int stars,
    String? text,
  }) async {
    try {
      final id = await _client.rpc('submit_review', params: {
        'p_tutor_id': tutorId,
        'p_stars': stars,
        'p_text': text,
      }) as String;
      final row = await _client.from('reviews').select().eq('id', id).single();
      return Review.fromRow(row);
    } on sb.PostgrestException catch (e) {
      final m = e.message;
      if (m.contains('gate_not_met')) throw ReviewsException('gate_not_met', m);
      if (m.contains('phone_in_review')) throw ReviewsException('phone_in_review', m);
      throw ReviewsException('submit_failed', m);
    }
  }

  @override
  Future<List<Review>> listForStudent(String studentId, {int limit = 50}) async {
    try {
      final rows = await _client
          .from('student_reviews')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>().map(Review.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw ReviewsException('list_student_failed', e.message);
    }
  }

  @override
  Future<RatingSummary> summaryForStudent(String studentId) async {
    try {
      final row = await _client
          .from('profiles')
          .select('student_rating, student_rating_count')
          .eq('id', studentId)
          .maybeSingle();
      if (row == null) return const RatingSummary(average: 0, count: 0);
      return RatingSummary(
        average: ((row['student_rating'] as num?) ?? 0).toDouble(),
        count: (row['student_rating_count'] as int?) ?? 0,
      );
    } on sb.PostgrestException catch (e) {
      throw ReviewsException('student_summary_failed', e.message);
    }
  }

  @override
  Future<Review> submitStudentReview({
    required String studentId,
    required int stars,
    String? text,
  }) async {
    try {
      final id = await _client.rpc('submit_student_review', params: {
        'p_student_id': studentId,
        'p_stars': stars,
        'p_text': text,
      }) as String;
      final row = await _client.from('student_reviews').select().eq('id', id).single();
      return Review.fromRow(row);
    } on sb.PostgrestException catch (e) {
      final m = e.message;
      if (m.contains('gate_not_met')) throw ReviewsException('gate_not_met', m);
      if (m.contains('phone_in_review')) throw ReviewsException('phone_in_review', m);
      throw ReviewsException('submit_student_failed', m);
    }
  }

  @override
  Future<int> boostFeatured({int hours = 24}) async {
    try {
      final res = await _client.rpc('boost_tutor_featured', params: {'p_hours': hours});
      return (res as num).toInt();
    } on sb.PostgrestException catch (e) {
      throw ReviewsException('boost_failed', e.message);
    }
  }

  @override
  Future<int> promoteJob({required String jobId, int hours = 24}) async {
    try {
      final res =
          await _client.rpc('promote_job', params: {'p_job_id': jobId, 'p_hours': hours});
      return (res as num).toInt();
    } on sb.PostgrestException catch (e) {
      throw ReviewsException('promote_failed', e.message);
    }
  }
}
