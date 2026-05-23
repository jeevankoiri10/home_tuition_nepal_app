import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/map_repository.dart';
import '../../domain/models/map_filters.dart';
import '../../domain/models/map_tutor.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._repo, this._locator) : super(const MapState()) {
    on<MapStarted>(_onStarted);
    on<MapCameraMoved>(_onCameraMoved);
    on<MapFiltersChanged>(_onFiltersChanged);
    on<MapTutorSelected>(_onTutorSelected);
    on<MapRefreshRequested>(_onRefresh);
    on<_MapSearchTick>(_onSearchTick);
  }

  final MapRepository _repo;
  final LocationService _locator;
  Timer? _debounce;

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.locating));
    final (lat, lng) = await _locator.currentOrFallback();
    emit(state.copyWith(centerLat: lat, centerLng: lng, status: MapStatus.loading));
    await _runSearch(emit);
  }

  void _onCameraMoved(MapCameraMoved event, Emitter<MapState> emit) {
    emit(state.copyWith(centerLat: event.lat, centerLng: event.lng));
    _scheduleSearch();
  }

  void _onFiltersChanged(MapFiltersChanged event, Emitter<MapState> emit) {
    emit(state.copyWith(filters: event.filters, clearSelection: true));
    _scheduleSearch();
  }

  void _onTutorSelected(MapTutorSelected event, Emitter<MapState> emit) {
    emit(state.copyWith(
      selectedTutorId: event.tutorId,
      clearSelection: event.tutorId == null,
    ));
  }

  Future<void> _onRefresh(MapRefreshRequested event, Emitter<MapState> emit) =>
      _runSearch(emit);

  Future<void> _onSearchTick(_MapSearchTick event, Emitter<MapState> emit) =>
      _runSearch(emit);

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      add(const _MapSearchTick());
    });
  }

  Future<void> _runSearch(Emitter<MapState> emit) async {
    final lat = state.centerLat;
    final lng = state.centerLng;
    if (lat == null || lng == null) return;
    emit(state.copyWith(status: MapStatus.loading, clearError: true));
    try {
      final tutors =
          await _repo.search(lat: lat, lng: lng, filters: state.filters);
      emit(state.copyWith(status: MapStatus.ready, tutors: tutors));
    } on MapRepositoryException catch (e) {
      emit(state.copyWith(
        status: MapStatus.error,
        errorMessage: e.message ?? e.code,
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
