part of 'map_bloc.dart';

enum MapStatus { initial, locating, loading, ready, error }

class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.centerLat,
    this.centerLng,
    this.filters = const MapFilters(),
    this.tutors = const [],
    this.selectedTutorId,
    this.errorMessage,
  });

  final MapStatus status;
  final double? centerLat;
  final double? centerLng;
  final MapFilters filters;
  final List<MapTutor> tutors;
  final String? selectedTutorId;
  final String? errorMessage;

  MapTutor? get selectedTutor {
    if (selectedTutorId == null) return null;
    for (final t in tutors) {
      if (t.tutorId == selectedTutorId) return t;
    }
    return null;
  }

  MapState copyWith({
    MapStatus? status,
    double? centerLat,
    double? centerLng,
    MapFilters? filters,
    List<MapTutor>? tutors,
    String? selectedTutorId,
    String? errorMessage,
    bool clearError = false,
    bool clearSelection = false,
  }) {
    return MapState(
      status: status ?? this.status,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      filters: filters ?? this.filters,
      tutors: tutors ?? this.tutors,
      selectedTutorId: clearSelection ? null : (selectedTutorId ?? this.selectedTutorId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [status, centerLat, centerLng, filters, tutors, selectedTutorId, errorMessage];
}
