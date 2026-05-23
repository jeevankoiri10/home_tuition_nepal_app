import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/job_post.dart';
import '../domain/models/request_enums.dart';
import '../domain/models/vacancy_request.dart';
import '../domain/student_requests_repository.dart';

class SupabaseStudentRequestsRepository implements StudentRequestsRepository {
  SupabaseStudentRequestsRepository(this._client);
  final sb.SupabaseClient _client;

  @override
  Future<List<JobPost>> loadMyJobs(String studentId) async {
    try {
      final rows = await _client
          .from('jobs')
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      return (rows as List).cast<Map<String, dynamic>>().map(JobPost.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw StudentRequestsException('jobs_load_failed', e.message);
    }
  }

  @override
  Future<List<VacancyRequest>> loadMyVacancies(String studentId) async {
    try {
      final rows = await _client
          .from('vacancies')
          .select()
          .eq('linked_student', studentId)
          .order('created_at', ascending: false);
      return (rows as List).cast<Map<String, dynamic>>().map(VacancyRequest.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw StudentRequestsException('vacancies_load_failed', e.message);
    }
  }

  @override
  Future<JobPost> createJob(JobPost job) async {
    try {
      final row = await _client.from('jobs').insert(job.toInsertRow()).select().single();
      return JobPost.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw StudentRequestsException('job_create_failed', e.message);
    }
  }

  @override
  Future<JobPost> updateJobStatus(String jobId, JobStatus status) async {
    try {
      final row = await _client
          .from('jobs')
          .update({'status': status.value})
          .eq('id', jobId)
          .select()
          .single();
      return JobPost.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw StudentRequestsException('job_update_failed', e.message);
    }
  }

  @override
  Future<JobPost> repostJob(String jobId) async {
    // Repost = clone the row with status='open' and a new id.
    try {
      final original = await _client.from('jobs').select().eq('id', jobId).single();
      final clone = Map<String, dynamic>.from(original)
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at')
        ..['status'] = 'open';
      final row = await _client.from('jobs').insert(clone).select().single();
      return JobPost.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw StudentRequestsException('job_repost_failed', e.message);
    }
  }

  @override
  Future<VacancyRequest> requestVacancy(VacancyRequest vacancy) async {
    try {
      final row =
          await _client.from('vacancies').insert(vacancy.toInsertRow()).select().single();
      return VacancyRequest.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw StudentRequestsException('vacancy_request_failed', e.message);
    }
  }
}
