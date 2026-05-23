part of 'student_requests_bloc.dart';

enum StudentRequestsStatus { initial, loading, ready, submitting, error }

class StudentRequestsState extends Equatable {
  const StudentRequestsState({
    this.status = StudentRequestsStatus.initial,
    this.jobs = const [],
    this.vacancies = const [],
    this.errorMessage,
  });

  final StudentRequestsStatus status;
  final List<JobPost> jobs;
  final List<VacancyRequest> vacancies;
  final String? errorMessage;

  StudentRequestsState copyWith({
    StudentRequestsStatus? status,
    List<JobPost>? jobs,
    List<VacancyRequest>? vacancies,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentRequestsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      vacancies: vacancies ?? this.vacancies,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, jobs, vacancies, errorMessage];
}
