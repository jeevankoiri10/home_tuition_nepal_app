import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.body,
    required this.sentAt,
    this.readAt,
  });

  final String id;
  final String threadId;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final DateTime? readAt;

  bool get isRead => readAt != null;

  ChatMessage copyWith({DateTime? readAt}) => ChatMessage(
    id: id,
    threadId: threadId,
    senderId: senderId,
    body: body,
    sentAt: sentAt,
    readAt: readAt ?? this.readAt,
  );

  static ChatMessage fromRow(Map<String, dynamic> row) => ChatMessage(
    id: row['id'] as String,
    threadId: row['thread_id'] as String,
    senderId: row['sender_id'] as String,
    body: row['body'] as String,
    sentAt: DateTime.parse(row['sent_at'] as String),
    readAt: row['read_at'] == null
        ? null
        : DateTime.parse(row['read_at'] as String),
  );

  @override
  List<Object?> get props => [id, threadId, senderId, body, sentAt, readAt];
}
