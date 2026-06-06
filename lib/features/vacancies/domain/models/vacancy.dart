import 'package:equatable/equatable.dart';

import '../../../student_requests/domain/models/request_enums.dart';

/// Public-readable vacancy seen by tutors in the Vacancies feed.
/// Mirrors the `vacancies` row (Phase 6 schema) when status='open'.
class Vacancy extends Equatable {
  const Vacancy({
    required this.id,
    this.code,
    required this.title,
    required this.areaLabel,
    this.grade,
    this.subjects = const [],
    this.numStudents = 1,
    this.durationText,
    this.frequency = 'per_month',
    this.salaryMinNpr,
    this.salaryMaxNpr,
    this.salaryPeriod = 'month',
    this.genderPref = GenderPref.any,
    this.mode = JobMode.inPerson,
    this.notes,
    this.lat,
    this.lng,
    this.distanceKm,
    required this.createdAt,
  });

  final String id;
  final String? code;
  final String title;
  final String areaLabel;
  final String? grade;
  final List<String> subjects;
  final int numStudents;
  final String? durationText;
  final String frequency;
  final num? salaryMinNpr;
  final num? salaryMaxNpr;
  final String salaryPeriod;
  final GenderPref genderPref;
  final JobMode mode;
  final String? notes;

  /// Location of the vacancy (from `vacancies.geog`). Null when the admin
  /// hasn't pinned it. `distanceKm` is set only by the geo-search path.
  final double? lat;
  final double? lng;
  final double? distanceKm;

  final DateTime createdAt;

  bool get hasLocation => lat != null && lng != null;

  String? formatDistance() {
    final d = distanceKm;
    if (d == null) return null;
    if (d < 1) return '${(d * 1000).round()} m';
    return '${d.toStringAsFixed(1)} km';
  }

  /// Returns a copy stamped with [distanceKm] — used by the geo-search path.
  Vacancy copyWithDistance(double distanceKm) => Vacancy(
        id: id,
        code: code,
        title: title,
        areaLabel: areaLabel,
        grade: grade,
        subjects: subjects,
        numStudents: numStudents,
        durationText: durationText,
        frequency: frequency,
        salaryMinNpr: salaryMinNpr,
        salaryMaxNpr: salaryMaxNpr,
        salaryPeriod: salaryPeriod,
        genderPref: genderPref,
        mode: mode,
        notes: notes,
        lat: lat,
        lng: lng,
        distanceKm: distanceKm,
        createdAt: createdAt,
      );

  String formatSalary() {
    if (salaryMinNpr == null) return '—';
    final min = _formatNpr(salaryMinNpr!);
    if (salaryMaxNpr != null && salaryMaxNpr != salaryMinNpr) {
      return 'Rs. $min–${_formatNpr(salaryMaxNpr!)}/$salaryPeriod';
    }
    return 'Rs. $min/$salaryPeriod';
  }

  static Vacancy fromRow(Map<String, dynamic> row) => Vacancy(
        id: row['id'] as String,
        code: row['code'] as String?,
        title: (row['title'] as String?) ?? 'Vacancy',
        areaLabel: (row['area_label'] as String?) ?? '',
        grade: row['grade'] as String?,
        subjects:
            ((row['subjects'] as List?) ?? const []).map((v) => v as String).toList(),
        numStudents: (row['num_students'] as int?) ?? 1,
        durationText: row['duration_text'] as String?,
        frequency: (row['frequency'] as String?) ?? 'per_month',
        salaryMinNpr: row['salary_min_npr'] as num?,
        salaryMaxNpr: row['salary_max_npr'] as num?,
        salaryPeriod: (row['salary_period'] as String?) ?? 'month',
        genderPref: GenderPref.fromString(row['gender_pref'] as String?),
        mode: JobMode.fromString(row['mode'] as String?),
        notes: row['notes'] as String?,
        lat: (row['lat'] as num?)?.toDouble(),
        lng: (row['lng'] as num?)?.toDouble(),
        distanceKm: (row['distance_km'] as num?)?.toDouble(),
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
      );

  static String _formatNpr(num n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        areaLabel,
        grade,
        subjects,
        numStudents,
        durationText,
        frequency,
        salaryMinNpr,
        salaryMaxNpr,
        salaryPeriod,
        genderPref,
        mode,
        notes,
        lat,
        lng,
        distanceKm,
        createdAt,
      ];
}
