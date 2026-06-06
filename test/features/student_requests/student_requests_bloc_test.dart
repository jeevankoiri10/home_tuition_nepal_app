import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/features/student_requests/data/fake_student_requests_repository.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/job_post.dart';
import 'package:home_tuition_nepal_app/features/student_requests/domain/models/vacancy_request.dart';
import 'package:home_tuition_nepal_app/features/student_requests/presentation/blocs/student_requests_bloc.dart';

void main() {
  group('StudentRequestsBloc submission signal', () {
    blocTest<StudentRequestsBloc, StudentRequestsState>(
      'submitting a job sets submittedJobId and lands ready',
      build: () => StudentRequestsBloc(FakeStudentRequestsRepository()),
      act: (b) => b.add(const StudentJobSubmitted(
        JobPost(studentId: 'u1', title: 'Maths tutor', budgetMinNpr: 5000),
      )),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.status, StudentRequestsStatus.ready);
        expect(b.state.submittedJobId, isNotNull);
        expect(b.state.jobs.length, 1);
      },
    );

    blocTest<StudentRequestsBloc, StudentRequestsState>(
      'requesting a vacancy sets submittedVacancyId',
      build: () => StudentRequestsBloc(FakeStudentRequestsRepository()),
      act: (b) => b.add(const StudentVacancyRequested(
        VacancyRequest(
          linkedStudent: 'u1',
          title: 'Tutor in Kapan',
          areaLabel: 'Kapan',
          subjects: ['Maths'],
        ),
      )),
      wait: const Duration(milliseconds: 400),
      verify: (b) {
        expect(b.state.submittedVacancyId, isNotNull);
        expect(b.state.vacancies.length, 1);
      },
    );

    blocTest<StudentRequestsBloc, StudentRequestsState>(
      'reload clears a prior submission signal',
      build: () => StudentRequestsBloc(FakeStudentRequestsRepository()),
      act: (b) async {
        b.add(const StudentRequestsLoaded('u1'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        b.add(const StudentJobSubmitted(JobPost(studentId: 'u1', title: 'X')));
        await Future<void>.delayed(const Duration(milliseconds: 400));
        b.add(const StudentRequestsRefreshed());
      },
      wait: const Duration(milliseconds: 800),
      verify: (b) {
        expect(b.state.submittedJobId, isNull);
      },
    );
  });
}
