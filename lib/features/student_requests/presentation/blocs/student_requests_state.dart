part of 'student_requests_bloc.dart';

enum StudentRequestsStatus { initial, loading, ready, submitting, error }

class StudentRequestsState extends Equatable {
  const StudentRequestsState({
    this.status = StudentRequestsStatus.initial,
    this.jobs = const [],
    this.vacancies = const [],
    this.errorMessage,
    this.submittedJobId,
    this.submittedVacancyId,
  });

  final StudentRequestsStatus status;
  final List<JobPost> jobs;
  final List<VacancyRequest> vacancies;
  final String? errorMessage;

  /// Set to the new id immediately after a successful submit so the UI can
  /// confirm + pop deterministically (instead of guessing from timestamps).
  /// Cleared when a new submit starts or the list reloads.
  final String? submittedJobId;
  final String? submittedVacancyId;

  StudentRequestsState copyWith({
    StudentRequestsStatus? status,
    List<JobPost>? jobs,
    List<VacancyRequest>? vacancies,
    String? errorMessage,
    String? submittedJobId,
    String? submittedVacancyId,
    bool clearError = false,
    bool clearSubmitted = false,
  }) {
    return StudentRequestsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      vacancies: vacancies ?? this.vacancies,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submittedJobId: clearSubmitted ? null : (submittedJobId ?? this.submittedJobId),
      submittedVacancyId:
          clearSubmitted ? null : (submittedVacancyId ?? this.submittedVacancyId),
    );
  }

  @override
  List<Object?> get props =>
      [status, jobs, vacancies, errorMessage, submittedJobId, submittedVacancyId];
}
