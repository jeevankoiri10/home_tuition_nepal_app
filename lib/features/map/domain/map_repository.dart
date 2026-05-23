import 'models/map_filters.dart';
import 'models/map_tutor.dart';

abstract class MapRepository {
  /// Returns tutors within `filters.radiusKm` of (lat, lng), filtered by
  /// `filters`. Excludes online-only tutors when filters.mode == offline.
  Future<List<MapTutor>> search({
    required double lat,
    required double lng,
    required MapFilters filters,
  });
}

class MapRepositoryException implements Exception {
  MapRepositoryException(this.code, [this.message]);
  final String code;
  final String? message;

  @override
  String toString() => 'MapRepositoryException($code, $message)';
}
