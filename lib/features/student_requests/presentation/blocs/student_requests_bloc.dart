import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/job_post.dart';
import '../../domain/models/request_enums.dart';
import '../../domain/models/vacancy_request.dart';
import '../../domain/student_requests_repository.dart';

part 'student_requests_event.dart';
part 'student_requests_state.dart';

class StudentRequestsBloc extends Bloc<StudentRequestsEvent, StudentRequestsState> {
  StudentRequestsBloc(this._repo) : super(const StudentRequestsState()) {
    on<StudentRequestsLoaded>(_onLoad);
    on<StudentRequestsRefreshed>(_onRefresh);
    on<StudentJobSubmitted>(_onJobSubmit);
    on<StudentJobStatusChanged>(_onJobStatus);
    on<StudentJobReposted>(_onRepost);
    on<StudentVacancyRequested>(_onVacancyRequest);
  }

  final StudentRequestsRepository _repo;
  String? _studentId;

  Future<void> _onLoad(StudentRequestsLoaded e, Emitter<StudentRequestsState> emit) async {
    _studentId = e.studentId;
    await _reload(emit);
  }

  Future<void> _onRefresh(_, Emitter<StudentRequestsState> emit) => _reload(emit);

  Future<void> _reload(Emitter<StudentRequestsState> emit) async {
    final id = _studentId;
    if (id == null) return;
    emit(state.copyWith(status: StudentRequestsStatus.loading, clearError: true));
    try {
      final jobs = await _repo.loadMyJobs(id);
      final vacancies = await _repo.loadMyVacancies(id);
      emit(state.copyWith(
          status: StudentRequestsStatus.ready, jobs: jobs, vacancies: vacancies));
    } on StudentRequestsException catch (e) {
      emit(state.copyWith(
          status: StudentRequestsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  Future<void> _onJobSubmit(
      StudentJobSubmitted event, Emitter<StudentRequestsState> emit) async {
    emit(state.copyWith(status: StudentRequestsStatus.submitting, clearError: true));
    try {
      final saved = await _repo.createJob(event.job);
      emit(state.copyWith(
        status: StudentRequestsStatus.ready,
        jobs: [saved, ...state.jobs],
      ));
    } on StudentRequestsException catch (e) {
      emit(state.copyWith(
          status: StudentRequestsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  Future<void> _onJobStatus(
      StudentJobStatusChanged event, Emitter<StudentRequestsState> emit) async {
    try {
      final updated = await _repo.updateJobStatus(event.jobId, event.status);
      emit(state.copyWith(
        jobs: state.jobs.map((j) => j.id == updated.id ? updated : j).toList(),
      ));
    } on StudentRequestsException catch (e) {
      emit(state.copyWith(
          status: StudentRequestsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  Future<void> _onRepost(
      StudentJobReposted event, Emitter<StudentRequestsState> emit) async {
    try {
      final reposted = await _repo.repostJob(event.jobId);
      emit(state.copyWith(jobs: [reposted, ...state.jobs]));
    } on StudentRequestsException catch (e) {
      emit(state.copyWith(
          status: StudentRequestsStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  Future<void> _onVacancyRequest(
      StudentVacancyRequested event, Emitter<StudentRequestsState> emit) async {
    emit(state.copyWith(status: StudentRequestsStatus.submitting, clearError: true));
    try {
      final saved = await _repo.requestVacancy(event.vacancy);
      emit(state.copyWith(
        status: StudentRequestsStatus.ready,
        vacancies: [saved, ...state.vacancies],
      ));
    } on StudentRequestsException catch (e) {
      emit(state.copyWith(
          status: StudentRequestsStatus.error, errorMessage: e.message ?? e.code));
    }
  }
}
