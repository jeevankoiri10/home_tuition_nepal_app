import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/models/vacancy.dart';
import '../../domain/vacancies_repository.dart';
import '../../domain/vacancy_sort.dart';

part 'vacancy_map_event.dart';
part 'vacancy_map_state.dart';

/// Drives the tutor-facing vacancy map: locate the tutor, search open
/// vacancies near the camera centre, and re-query (debounced) as the map
/// moves. Mirrors the student MapBloc so the two map surfaces behave alike.
class VacancyMapBloc extends Bloc<VacancyMapEvent, VacancyMapState> {
  VacancyMapBloc(this._repo, this._locator) : super(const VacancyMapState()) {
    on<VacancyMapStarted>(_onStarted);
    on<VacancyMapCameraMoved>(_onCameraMoved);
    on<VacancyMapRefreshRequested>(_onRefresh);
    on<VacancyMapSelected>(_onSelected);
    on<VacancyMapSortChanged>(_onSortChanged);
    on<_VacancyMapSearchTick>(_onTick);
  }

  final VacanciesRepository _repo;
  final LocationService _locator;
  Timer? _debounce;

  Future<void> _onStarted(VacancyMapStarted e, Emitter<VacancyMapState> emit) async {
    emit(state.copyWith(status: VacancyMapStatus.locating));
    final (lat, lng) = await _locator.currentOrFallback();
    emit(state.copyWith(centerLat: lat, centerLng: lng, status: VacancyMapStatus.loading));
    await _runSearch(emit);
  }

  void _onCameraMoved(VacancyMapCameraMoved e, Emitter<VacancyMapState> emit) {
    emit(state.copyWith(centerLat: e.lat, centerLng: e.lng));
    _schedule();
  }

  void _onSelected(VacancyMapSelected e, Emitter<VacancyMapState> emit) {
    emit(state.copyWith(selectedId: e.vacancyId, clearSelection: e.vacancyId == null));
  }

  Future<void> _onRefresh(VacancyMapRefreshRequested e, Emitter<VacancyMapState> emit) =>
      _runSearch(emit);

  /// Re-order the already-loaded vacancies in place — no network round-trip.
  void _onSortChanged(VacancyMapSortChanged e, Emitter<VacancyMapState> emit) {
    emit(state.copyWith(
      sort: e.sort,
      vacancies: sortVacancies(state.vacancies, e.sort),
    ));
  }

  Future<void> _onTick(_VacancyMapSearchTick e, Emitter<VacancyMapState> emit) =>
      _runSearch(emit);

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => add(const _VacancyMapSearchTick()));
  }

  Future<void> _runSearch(Emitter<VacancyMapState> emit) async {
    final lat = state.centerLat;
    final lng = state.centerLng;
    if (lat == null || lng == null) return;
    emit(state.copyWith(status: VacancyMapStatus.loading, clearError: true));
    try {
      final vacancies = await _repo.searchNearby(lat: lat, lng: lng);
      emit(state.copyWith(
        status: VacancyMapStatus.ready,
        vacancies: sortVacancies(vacancies, state.sort),
      ));
    } on VacanciesException catch (e) {
      emit(state.copyWith(status: VacancyMapStatus.error, errorMessage: e.message ?? e.code));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
