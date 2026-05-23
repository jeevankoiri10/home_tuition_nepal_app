part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => const [];
}

class MapStarted extends MapEvent {
  const MapStarted();
}

class MapCameraMoved extends MapEvent {
  const MapCameraMoved({required this.lat, required this.lng});
  final double lat;
  final double lng;
  @override
  List<Object?> get props => [lat, lng];
}

class MapFiltersChanged extends MapEvent {
  const MapFiltersChanged(this.filters);
  final MapFilters filters;
  @override
  List<Object?> get props => [filters];
}

class MapTutorSelected extends MapEvent {
  const MapTutorSelected(this.tutorId);
  final String? tutorId;
  @override
  List<Object?> get props => [tutorId];
}

class MapRefreshRequested extends MapEvent {
  const MapRefreshRequested();
}

class _MapSearchTick extends MapEvent {
  const _MapSearchTick();
}
