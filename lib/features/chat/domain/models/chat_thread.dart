import 'package:equatable/equatable.dart';

class ChatThread extends Equatable {
  const ChatThread({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.openedVia,
    this.lastMessageAt,
    required this.createdAt,
    this.counterpartyMaskedName,
  });

  final String id;
  final String studentId;
  final String tutorId;
  final String openedVia; // 'contact_unlock' | 'admin_assignment'
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final String? counterpartyMaskedName;

  /// Returns the other party id given the viewer.
  String counterpartyFor(String viewerId) =>
      viewerId == studentId ? tutorId : studentId;

  static ChatThread fromRow(Map<String, dynamic> row, {String? maskedName}) =>
      ChatThread(
        id: row['id'] as String,
        studentId: row['student_id'] as String,
        tutorId: row['tutor_id'] as String,
        openedVia: (row['opened_via'] as String?) ?? 'contact_unlock',
        lastMessageAt: row['last_message_at'] == null
            ? null
            : DateTime.parse(row['last_message_at'] as String),
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
        counterpartyMaskedName: maskedName,
      );

  @override
  List<Object?> get props => [
    id,
    studentId,
    tutorId,
    openedVia,
    lastMessageAt,
    createdAt,
  ];
}
