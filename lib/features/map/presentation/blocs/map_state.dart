part of 'map_bloc.dart';

enum MapStatus { initial, locating, loading, ready, error }

class MapState extends Equatable {
  const MapState({
    this.status = MapStatus.initial,
    this.centerLat,
    this.centerLng,
    this.filters = const MapFilters(),
    this.sort = MapSort.distance,
    this.tutors = const [],
    this.selectedTutorId,
    this.errorMessage,
    this.recentering = false,
    this.recenterSeq = 0,
  });

  final MapStatus status;
  final double? centerLat;
  final double? centerLng;
  final MapFilters filters;
  final MapSort sort;
  final List<MapTutor> tutors;
  final String? selectedTutorId;
  final String? errorMessage;

  /// True while fetching the device location for a recenter (drives the FAB spinner).
  final bool recentering;

  /// Increments on each completed recenter so the page moves the camera once.
  final int recenterSeq;

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
    MapSort? sort,
    List<MapTutor>? tutors,
    String? selectedTutorId,
    String? errorMessage,
    bool clearError = false,
    bool clearSelection = false,
    bool? recentering,
    int? recenterSeq,
  }) {
    return MapState(
      status: status ?? this.status,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      filters: filters ?? this.filters,
      sort: sort ?? this.sort,
      tutors: tutors ?? this.tutors,
      selectedTutorId: clearSelection ? null : (selectedTutorId ?? this.selectedTutorId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recentering: recentering ?? this.recentering,
      recenterSeq: recenterSeq ?? this.recenterSeq,
    );
  }

  @override
  List<Object?> get props => [
        status,
        centerLat,
        centerLng,
        filters,
        sort,
        tutors,
        selectedTutorId,
        errorMessage,
        recentering,
        recenterSeq,
      ];
}
