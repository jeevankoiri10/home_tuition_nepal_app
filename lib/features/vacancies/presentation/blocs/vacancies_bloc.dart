import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/vacancy.dart';
import '../../domain/models/vacancy_application.dart';
import '../../domain/vacancies_repository.dart';

part 'vacancies_event.dart';
part 'vacancies_state.dart';

class VacanciesBloc extends Bloc<VacanciesEvent, VacanciesState> {
  VacanciesBloc(this._repo) : super(const VacanciesState()) {
    on<VacanciesLoaded>(_onLoad);
    on<VacanciesRefreshed>(_onRefresh);
    on<VacanciesFiltersChanged>(_onFilters);
    on<VacancyApplied>(_onApply);
    on<VacancyApplyAcknowledged>(_onAck);
  }

  final VacanciesRepository _repo;
  String? _tutorId;

  Future<void> _onLoad(VacanciesLoaded e, Emitter<VacanciesState> emit) async {
    _tutorId = e.tutorId;
    await _reload(emit);
  }

  Future<void> _onRefresh(_, Emitter<VacanciesState> emit) => _reload(emit);

  Future<void> _onFilters(
      VacanciesFiltersChanged e, Emitter<VacanciesState> emit) async {
    emit(state.copyWith(subjectQuery: e.subject, areaQuery: e.area));
    await _reload(emit);
  }

  Future<void> _reload(Emitter<VacanciesState> emit) async {
    final id = _tutorId;
    emit(state.copyWith(status: VacanciesStatus.loading, clearError: true));
    try {
      final list = await _repo.listOpen(
        subjectQuery: state.subjectQuery,
        areaQuery: state.areaQuery,
      );
      final apps = id == null ? <VacancyApplication>[] : await _repo.listMyApplications(id);
      emit(state.copyWith(
        status: VacanciesStatus.ready,
        vacancies: list,
        myApplications: apps,
      ));
    } on VacanciesException catch (e) {
      emit(state.copyWith(
          status: VacanciesStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  Future<void> _onApply(VacancyApplied e, Emitter<VacanciesState> emit) async {
    emit(state.copyWith(applyStatus: ApplyStatus.submitting, clearApplyError: true));
    try {
      await _repo.apply(
        vacancyId: e.vacancyId,
        coverNote: e.coverNote,
        expectedRate: e.expectedRate,
        cvStoragePath: e.cvStoragePath,
      );
      emit(state.copyWith(applyStatus: ApplyStatus.success));
      await _reload(emit);
    } on VacanciesException catch (err) {
      emit(state.copyWith(
        applyStatus: ApplyStatus.error,
        applyNeedsTopUp: err.isInsufficientCoins,
        applyError: err.isAlreadyApplied
            ? 'You already applied to this vacancy.'
            : (err.isInsufficientCoins
                ? 'Not enough coins. Top up to apply.'
                : (err.message ?? err.code)),
      ));
    }
  }

  void _onAck(_, Emitter<VacanciesState> emit) {
    emit(state.copyWith(applyStatus: ApplyStatus.idle, clearApplyError: true));
  }
}
