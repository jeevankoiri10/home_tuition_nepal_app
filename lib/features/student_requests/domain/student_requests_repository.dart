import 'models/job_post.dart';
import 'models/request_enums.dart';
import 'models/vacancy_request.dart';

class StudentRequestsException implements Exception {
  StudentRequestsException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'StudentRequestsException($code, $message)';
}

abstract class StudentRequestsRepository {
  Future<List<JobPost>> loadMyJobs(String studentId);
  Future<List<VacancyRequest>> loadMyVacancies(String studentId);

  Future<JobPost> createJob(JobPost job);
  Future<JobPost> updateJobStatus(String jobId, JobStatus status);
  Future<JobPost> repostJob(String jobId);

  Future<VacancyRequest> requestVacancy(VacancyRequest vacancy);
}
