import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/student_requests/data/fake_student_requests_repository.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/job_post.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/request_enums.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/vacancy_request.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/student_requests_repository.dart';

void main() {
  late FakeStudentRequestsRepository repo;

  setUp(() => repo = FakeStudentRequestsRepository());

  group('FakeStudentRequestsRepository', () {
    test('createJob returns a row with id + open status', () async {
      final saved = await repo.createJob(const JobPost(
        studentId: 'u1',
        title: 'Maths tutor needed',
        budgetMinNpr: 5000,
      ));
      expect(saved.id, isNotNull);
      expect(saved.status, JobStatus.open);
      expect(saved.budgetMinNpr, 5000);

      final list = await repo.loadMyJobs('u1');
      expect(list.length, 1);
    });

    test('requestVacancy lands as pending_admin_review', () async {
      final saved = await repo.requestVacancy(const VacancyRequest(
        linkedStudent: 'u1',
        title: 'Tutor needed in Kapan',
        areaLabel: 'Kapan',
        subjects: ['Maths'],
      ));
      expect(saved.status, VacancyStatus.pendingAdminReview);
      expect(saved.code, isNull); // assigned only when admin publishes
    });

    test('updateJobStatus flips to closed', () async {
      final saved = await repo.createJob(const JobPost(
        studentId: 'u1',
        title: 'Test',
      ));
      final updated = await repo.updateJobStatus(saved.id!, JobStatus.closed);
      expect(updated.status, JobStatus.closed);
    });

    test('repostJob clones with new id and open status', () async {
      final original = await repo.createJob(const JobPost(
        studentId: 'u1',
        title: 'Original',
      ));
      await repo.updateJobStatus(original.id!, JobStatus.closed);
      final reposted = await repo.repostJob(original.id!);
      expect(reposted.id, isNot(equals(original.id)));
      expect(reposted.status, JobStatus.open);
      expect(reposted.title, 'Original');
    });

    test('updateJobStatus on a missing id throws', () async {
      expect(
        () => repo.updateJobStatus('nope', JobStatus.closed),
        throwsA(isA<StudentRequestsException>()),
      );
    });
  });
}
