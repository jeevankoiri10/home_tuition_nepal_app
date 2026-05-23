import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/map_repository.dart';
import '../domain/models/map_filters.dart';
import '../domain/models/map_tutor.dart';

class SupabaseMapRepository implements MapRepository {
  SupabaseMapRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<List<MapTutor>> search({
    required double lat,
    required double lng,
    required MapFilters filters,
  }) async {
    try {
      final rows = await _client.rpc(
        'search_tutors_in_viewport',
        params: {
          'p_lat': lat,
          'p_lng': lng,
          'p_radius_km': filters.radiusKm,
          'p_level': filters.level?.value,
          'p_subject': filters.subjectQuery,
          'p_mode': filters.mode?.value,
          'p_verified_only': filters.verifiedOnly,
          'p_available_only': filters.availableOnly,
          'p_max_results': 50,
        },
      ) as List<dynamic>;
      return rows
          .cast<Map<String, dynamic>>()
          .map(MapTutor.fromRow)
          .toList();
    } on sb.PostgrestException catch (e) {
      throw MapRepositoryException('search_failed', e.message);
    }
  }
}
