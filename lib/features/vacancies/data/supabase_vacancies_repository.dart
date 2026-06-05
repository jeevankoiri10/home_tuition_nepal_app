import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/vacancy.dart';
import '../domain/models/vacancy_application.dart';
import '../domain/vacancies_repository.dart';

class SupabaseVacanciesRepository implements VacanciesRepository {
  SupabaseVacanciesRepository(this._client);
  final sb.SupabaseClient _client;

  @override
  Future<List<Vacancy>> listOpen({String? subjectQuery, String? areaQuery}) async {
    try {
      final query = _client.from('vacancies').select().eq('status', 'open');
      // Subject + area filters applied client-side for simplicity. A server-side
      // filter (using `contains` for the subjects array + ilike for area_label)
      // could replace this when result volume justifies it.
      final rows = await query.order('created_at', ascending: false).limit(100);
      final all = (rows as List).cast<Map<String, dynamic>>().map(Vacancy.fromRow);
      return all.where((v) {
        if (subjectQuery != null && subjectQuery.isNotEmpty) {
          final q = subjectQuery.toLowerCase();
          if (!v.subjects.any((s) => s.toLowerCase().contains(q))) return false;
        }
        if (areaQuery != null && areaQuery.isNotEmpty) {
          if (!v.areaLabel.toLowerCase().contains(areaQuery.toLowerCase())) return false;
        }
        return true;
      }).toList();
    } on sb.PostgrestException catch (e) {
      throw VacanciesException('list_failed', e.message);
    }
  }

  @override
  Future<List<Vacancy>> searchNearby({
    required double lat,
    required double lng,
    double? radiusKm,
    String? subjectQuery,
  }) async {
    try {
      final rows = await _client.rpc('search_vacancies_in_viewport', params: {
        'p_lat': lat,
        'p_lng': lng,
        // null radius → no limit; pass a country-sized sentinel like the
        // tutor map search does (migration 0003).
        'p_radius_km': radiusKm ?? 99999,
        'p_subject': subjectQuery,
        'p_max_results': 100,
      }) as List<dynamic>;
      return rows.cast<Map<String, dynamic>>().map(Vacancy.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw VacanciesException('nearby_failed', e.message);
    }
  }

  @override
  Future<List<VacancyApplication>> listMyApplications(String tutorId) async {
    try {
      final rows = await _client
          .from('vacancy_applications')
          .select()
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(VacancyApplication.fromRow)
          .toList();
    } on sb.PostgrestException catch (e) {
      throw VacanciesException('my_apps_failed', e.message);
    }
  }

  @override
  Future<String> apply({
    required String vacancyId,
    required String coverNote,
    num? expectedRate,
    String? cvStoragePath,
  }) async {
    try {
      final res = await _client.rpc('tutor_apply_to_vacancy', params: {
        'p_vacancy_id': vacancyId,
        'p_cover_note': coverNote,
        'p_expected_rate': expectedRate,
        'p_cv_path': cvStoragePath,
      });
      return res as String;
    } on sb.PostgrestException catch (e) {
      final m = e.message;
      if (m.contains('already_applied')) {
        throw VacanciesException('already_applied', m);
      }
      if (m.contains('insufficient_coins')) {
        throw VacanciesException('insufficient_coins', m);
      }
      if (m.contains('not_a_tutor')) {
        throw VacanciesException('not_a_tutor', m);
      }
      if (m.contains('vacancy_not_open')) {
        throw VacanciesException('vacancy_not_open', m);
      }
      throw VacanciesException('apply_failed', m);
    }
  }
}
