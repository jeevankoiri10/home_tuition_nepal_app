part of 'student_requests_bloc.dart';

sealed class StudentRequestsEvent extends Equatable {
  const StudentRequestsEvent();
  @override
  List<Object?> get props => const [];
}

class StudentRequestsLoaded extends StudentRequestsEvent {
  const StudentRequestsLoaded(this.studentId);
  final String studentId;
  @override
  List<Object?> get props => [studentId];
}

class StudentRequestsRefreshed extends StudentRequestsEvent {
  const StudentRequestsRefreshed();
}

class StudentJobSubmitted extends StudentRequestsEvent {
  const StudentJobSubmitted(this.job);
  final JobPost job;
  @override
  List<Object?> get props => [job];
}

class StudentJobStatusChanged extends StudentRequestsEvent {
  const StudentJobStatusChanged({required this.jobId, required this.status});
  final String jobId;
  final JobStatus status;
  @override
  List<Object?> get props => [jobId, status];
}

class StudentJobReposted extends StudentRequestsEvent {
  const StudentJobReposted(this.jobId);
  final String jobId;
  @override
  List<Object?> get props => [jobId];
}

class StudentVacancyRequested extends StudentRequestsEvent {
  const StudentVacancyRequested(this.vacancy);
  final VacancyRequest vacancy;
  @override
  List<Object?> get props => [vacancy];
}
