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

/// Re-orders the current tutor list/carousel without re-querying.
class MapSortChanged extends MapEvent {
  const MapSortChanged(this.sort);
  final MapSort sort;
  @override
  List<Object?> get props => [sort];
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

/// Fetch the device's current location and recenter the map on it.
class MapRecenterRequested extends MapEvent {
  const MapRecenterRequested();
}

/// Long-press on the map: drop a custom search centre at (lat, lng) and look
/// for tutors around it — e.g. "near my school instead of home"
/// (student_UI.md §4.3.5).
class MapSearchHere extends MapEvent {
  const MapSearchHere({required this.lat, required this.lng});
  final double lat;
  final double lng;
  @override
  List<Object?> get props => [lat, lng];
}

class _MapSearchTick extends MapEvent {
  const _MapSearchTick();
}
