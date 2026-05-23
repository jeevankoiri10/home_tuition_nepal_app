import '../domain/models/job_post.dart';
import '../domain/models/request_enums.dart';
import '../domain/models/vacancy_request.dart';
import '../domain/student_requests_repository.dart';

class FakeStudentRequestsRepository implements StudentRequestsRepository {
  final Map<String, List<JobPost>> _jobs = {};
  final Map<String, List<VacancyRequest>> _vacancies = {};
  int _counter = 0;

  @override
  Future<List<JobPost>> loadMyJobs(String studentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<JobPost>.from(_jobs[studentId] ?? const []);
  }

  @override
  Future<List<VacancyRequest>> loadMyVacancies(String studentId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<VacancyRequest>.from(_vacancies[studentId] ?? const []);
  }

  @override
  Future<JobPost> createJob(JobPost job) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final saved = job.copyWith(id: 'job-${++_counter}', status: JobStatus.open);
    _jobs.putIfAbsent(job.studentId, () => []).insert(0, saved);
    return saved;
  }

  @override
  Future<JobPost> updateJobStatus(String jobId, JobStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final list in _jobs.values) {
      final idx = list.indexWhere((j) => j.id == jobId);
      if (idx == -1) continue;
      final updated = list[idx].copyWith(status: status);
      list[idx] = updated;
      return updated;
    }
    throw StudentRequestsException('not_found', 'No job with id $jobId');
  }

  @override
  Future<JobPost> repostJob(String jobId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final list in _jobs.values) {
      final idx = list.indexWhere((j) => j.id == jobId);
      if (idx == -1) continue;
      final original = list[idx];
      final reposted = original.copyWith(
        id: 'job-${++_counter}',
        status: JobStatus.open,
      );
      list.insert(0, reposted);
      return reposted;
    }
    throw StudentRequestsException('not_found', 'No job with id $jobId');
  }

  @override
  Future<VacancyRequest> requestVacancy(VacancyRequest vacancy) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final saved = VacancyRequest(
      id: 'vac-${++_counter}',
      linkedStudent: vacancy.linkedStudent,
      title: vacancy.title,
      areaLabel: vacancy.areaLabel,
      numStudents: vacancy.numStudents,
      grade: vacancy.grade,
      subjects: vacancy.subjects,
      durationText: vacancy.durationText,
      frequency: vacancy.frequency,
      salaryMinNpr: vacancy.salaryMinNpr,
      salaryMaxNpr: vacancy.salaryMaxNpr,
      salaryPeriod: vacancy.salaryPeriod,
      genderPref: vacancy.genderPref,
      mode: vacancy.mode,
      notes: vacancy.notes,
      status: VacancyStatus.pendingAdminReview,
      createdAt: DateTime.now(),
    );
    _vacancies.putIfAbsent(vacancy.linkedStudent, () => []).insert(0, saved);
    return saved;
  }
}
