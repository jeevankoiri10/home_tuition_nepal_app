import 'package:equatable/equatable.dart';

/// Closed set of notification kinds matching `notifications.kind` in SQL.
enum NotificationKind {
  newJobPosted('new_job_posted', 'New job posted'),
  applicationShortlisted('application_shortlisted', 'Application shortlisted'),
  applicationHired('application_hired', 'You were hired'),
  contactRevealed('contact_revealed', 'Contact revealed'),
  identityVerificationApproved('identity_verification_approved', 'Identity Verification Approved'),
  identityVerificationRejected('identity_verification_rejected', 'Verification needs attention'),
  coinCredited('coin_credited', 'Coins credited'),
  coinDebited('coin_debited', 'Coins debited'),
  newReview('new_review', 'New review'),
  systemMessage('system', 'Notice');

  const NotificationKind(this.value, this.fallbackLabel);
  final String value;
  final String fallbackLabel;

  static NotificationKind fromString(String? raw) => NotificationKind.values.firstWhere(
        (k) => k.value == raw,
        orElse: () => NotificationKind.systemMessage,
      );
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    this.body,
    this.refType,
    this.refId,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationKind kind;
  final String title;
  final String? body;
  final String? refType;
  final String? refId;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  AppNotification copyWith({DateTime? readAt, bool markRead = false}) {
    return AppNotification(
      id: id,
      userId: userId,
      kind: kind,
      title: title,
      body: body,
      refType: refType,
      refId: refId,
      readAt: markRead ? (readAt ?? DateTime.now()) : (readAt ?? this.readAt),
      createdAt: createdAt,
    );
  }

  static AppNotification fromRow(Map<String, dynamic> row) => AppNotification(
        id: row['id'] as String,
        userId: row['user_id'] as String,
        kind: NotificationKind.fromString(row['kind'] as String?),
        title: (row['title'] as String?) ?? '',
        body: row['body'] as String?,
        refType: row['ref_type'] as String?,
        refId: row['ref_id'] as String?,
        readAt: row['read_at'] == null ? null : DateTime.parse(row['read_at'] as String),
        createdAt: row['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(row['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, userId, kind, title, body, refType, refId, readAt, createdAt];
}
