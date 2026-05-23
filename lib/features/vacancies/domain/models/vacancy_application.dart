import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  pending('pending', 'Pending'),
  shortlisted('shortlisted', 'Shortlisted'),
  rejected('rejected', 'Rejected'),
  hired('hired', 'Hired');

  const ApplicationStatus(this.value, this.label);
  final String value;
  final String label;

  static ApplicationStatus fromString(String? raw) =>
      ApplicationStatus.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => ApplicationStatus.pending,
      );
}

class VacancyApplication extends Equatable {
  const VacancyApplication({
    required this.id,
    required this.vacancyId,
    required this.tutorId,
    this.coverNote,
    this.expectedRate,
    this.cvStoragePath,
    this.status = ApplicationStatus.pending,
    this.coinsSpent = 0,
    required this.createdAt,
  });

  final String id;
  final String vacancyId;
  final String tutorId;
  final String? coverNote;
  final num? expectedRate;
  final String? cvStoragePath;
  final ApplicationStatus status;
  final int coinsSpent;
  final DateTime createdAt;

  static VacancyApplication fromRow(Map<String, dynamic> row) => VacancyApplication(
        id: row['id'] as String,
        vacancyId: row['vacancy_id'] as String,
        tutorId: row['tutor_id'] as String,
        coverNote: row['cover_note'] as String?,
        expectedRate: row['expected_rate'] as num?,
        cvStoragePath: row['cv_storage_path'] as String?,
        status: ApplicationStatus.fromString(row['status'] as String?),
        coinsSpent: (row['coins_spent'] as int?) ?? 0,
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
      );

  @override
  List<Object?> get props =>
      [id, vacancyId, tutorId, coverNote, expectedRate, cvStoragePath, status, coinsSpent];
}
