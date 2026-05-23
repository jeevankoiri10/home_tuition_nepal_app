import 'package:equatable/equatable.dart';

import 'request_enums.dart';

/// A vacancy created by the student that an admin will later normalize and
/// publish (with an `HTN-NNNNN` code). For students this is the "Request a
/// Tutor" output; admins manage published vacancies in the admin panel.
class VacancyRequest extends Equatable {
  const VacancyRequest({
    this.id,
    this.code,
    required this.linkedStudent,
    required this.title,
    required this.areaLabel,
    this.numStudents = 1,
    this.grade,
    this.subjects = const [],
    this.durationText,
    this.frequency = 'per_month',
    this.salaryMinNpr,
    this.salaryMaxNpr,
    this.salaryPeriod = 'month',
    this.genderPref = GenderPref.any,
    this.mode = JobMode.inPerson,
    this.notes,
    this.status = VacancyStatus.pendingAdminReview,
    DateTime? createdAt,
  }) : createdAt = createdAt;

  final String? id;
  final String? code;
  final String linkedStudent;
  final String title;
  final String areaLabel;
  final int numStudents;
  final String? grade;
  final List<String> subjects;
  final String? durationText;
  final String frequency;
  final num? salaryMinNpr;
  final num? salaryMaxNpr;
  final String salaryPeriod;
  final GenderPref genderPref;
  final JobMode mode;
  final String? notes;
  final VacancyStatus status;
  final DateTime? createdAt;

  String formatSalary() {
    if (salaryMinNpr == null) return '—';
    final min = _formatNpr(salaryMinNpr!);
    if (salaryMaxNpr != null && salaryMaxNpr != salaryMinNpr) {
      return 'Rs. $min–${_formatNpr(salaryMaxNpr!)}/$salaryPeriod';
    }
    return 'Rs. $min/$salaryPeriod';
  }

  Map<String, dynamic> toInsertRow() => {
        'linked_student': linkedStudent,
        'title': title,
        'area_label': areaLabel,
        'num_students': numStudents,
        'grade': grade,
        'subjects': subjects,
        'duration_text': durationText,
        'frequency': frequency,
        'salary_min_npr': salaryMinNpr,
        'salary_max_npr': salaryMaxNpr,
        'salary_period': salaryPeriod,
        'gender_pref': genderPref.value,
        'mode': mode.value,
        'notes': notes,
        'status': status.value,
      };

  static VacancyRequest fromRow(Map<String, dynamic> row) => VacancyRequest(
        id: row['id'] as String?,
        code: row['code'] as String?,
        linkedStudent: row['linked_student'] as String,
        title: (row['title'] as String?) ?? 'Vacancy',
        areaLabel: (row['area_label'] as String?) ?? '',
        numStudents: (row['num_students'] as int?) ?? 1,
        grade: row['grade'] as String?,
        subjects:
            ((row['subjects'] as List?) ?? const []).map((v) => v as String).toList(),
        durationText: row['duration_text'] as String?,
        frequency: (row['frequency'] as String?) ?? 'per_month',
        salaryMinNpr: row['salary_min_npr'] as num?,
        salaryMaxNpr: row['salary_max_npr'] as num?,
        salaryPeriod: (row['salary_period'] as String?) ?? 'month',
        genderPref: GenderPref.fromString(row['gender_pref'] as String?),
        mode: JobMode.fromString(row['mode'] as String?),
        notes: row['notes'] as String?,
        status: VacancyStatus.fromString(row['status'] as String?),
        createdAt:
            row['created_at'] == null ? null : DateTime.tryParse(row['created_at'] as String),
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
        linkedStudent,
        title,
        areaLabel,
        numStudents,
        grade,
        subjects,
        durationText,
        frequency,
        salaryMinNpr,
        salaryMaxNpr,
        salaryPeriod,
        genderPref,
        mode,
        notes,
        status,
      ];
}
