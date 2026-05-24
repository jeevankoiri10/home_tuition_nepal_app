import 'package:equatable/equatable.dart';

/// Lifecycle of a chat-started engagement (Upwork-style):
/// proposed → active → completed, with declined/cancelled as dead ends.
enum ContractStatus {
  proposed('proposed'),
  active('active'),
  completed('completed'),
  declined('declined'),
  cancelled('cancelled');

  const ContractStatus(this.value);
  final String value;

  static ContractStatus fromString(String? raw) => ContractStatus.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => ContractStatus.proposed,
      );

  bool get isOpen => this == ContractStatus.proposed || this == ContractStatus.active;
}

enum ContractRatePeriod {
  month('month'),
  week('week'),
  session('session'),
  hour('hour');

  const ContractRatePeriod(this.value);
  final String value;

  static ContractRatePeriod fromString(String? raw) => ContractRatePeriod.values.firstWhere(
        (p) => p.value == raw,
        orElse: () => ContractRatePeriod.month,
      );
}

class Contract extends Equatable {
  const Contract({
    required this.id,
    required this.threadId,
    required this.studentId,
    required this.tutorId,
    required this.proposedBy,
    required this.subject,
    this.rateNpr,
    this.ratePeriod = ContractRatePeriod.month,
    this.scheduleText,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  final String id;
  final String? threadId;
  final String studentId;
  final String tutorId;
  final String proposedBy;
  final String subject;
  final num? rateNpr;
  final ContractRatePeriod ratePeriod;
  final String? scheduleText;
  final ContractStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  bool proposedByMe(String viewerId) => proposedBy == viewerId;

  /// The counterparty (not the proposer) is the one who accepts/declines.
  bool awaitingMyResponse(String viewerId) =>
      status == ContractStatus.proposed && proposedBy != viewerId;

  String formatRate() {
    if (rateNpr == null) return '—';
    return 'Rs. ${rateNpr!.toStringAsFixed(0)} / ${ratePeriod.value}';
  }

  static Contract fromRow(Map<String, dynamic> row) => Contract(
        id: row['id'] as String,
        threadId: row['thread_id'] as String?,
        studentId: row['student_id'] as String,
        tutorId: row['tutor_id'] as String,
        proposedBy: row['proposed_by'] as String,
        subject: (row['subject'] as String?) ?? '',
        rateNpr: row['rate_npr'] as num?,
        ratePeriod: ContractRatePeriod.fromString(row['rate_period'] as String?),
        scheduleText: row['schedule_text'] as String?,
        status: ContractStatus.fromString(row['status'] as String?),
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
        startedAt: row['started_at'] == null
            ? null
            : DateTime.parse(row['started_at'] as String),
        endedAt: row['ended_at'] == null
            ? null
            : DateTime.parse(row['ended_at'] as String),
      );

  @override
  List<Object?> get props =>
      [id, threadId, studentId, tutorId, proposedBy, subject, rateNpr, ratePeriod, status];
}
