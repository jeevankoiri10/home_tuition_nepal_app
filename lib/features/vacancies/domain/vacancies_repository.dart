import 'models/vacancy.dart';
import 'models/vacancy_application.dart';

class VacanciesException implements Exception {
  VacanciesException(this.code, [this.message]);
  final String code;
  final String? message;

  bool get isAlreadyApplied => code == 'already_applied';
  bool get isInsufficientCoins => code == 'insufficient_coins';

  @override
  String toString() => 'VacanciesException($code, $message)';
}

abstract class VacanciesRepository {
  Future<List<Vacancy>> listOpen({String? subjectQuery, String? areaQuery});

  /// Open vacancies near (lat, lng) for the tutor map view. Only vacancies
  /// with a pinned location are returned, each carrying `distanceKm`, sorted
  /// nearest-first. `radiusKm` null means no distance limit.
  Future<List<Vacancy>> searchNearby({
    required double lat,
    required double lng,
    double? radiusKm,
    String? subjectQuery,
  });

  Future<List<VacancyApplication>> listMyApplications(String tutorId);

  /// Atomic apply via the `tutor_apply_to_vacancy` RPC — debits coins AND
  /// inserts the application row in the same transaction. Returns the new
  /// balance via the wallet event surface, application id directly here.
  Future<String> apply({
    required String vacancyId,
    required String coverNote,
    num? expectedRate,
    String? cvStoragePath,
  });
}
