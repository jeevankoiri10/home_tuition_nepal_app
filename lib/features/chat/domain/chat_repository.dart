import 'models/chat_message.dart';
import 'models/chat_thread.dart';

class ChatException implements Exception {
  ChatException(this.code, [this.message]);
  final String code;
  final String? message;

  bool get isGateNotMet => code == 'gate_not_met';
  bool get isPhoneInMessage => code == 'phone_in_message';

  @override
  String toString() => 'ChatException($code, $message)';
}

abstract class ChatRepository {
  /// Opens (or finds) the chat thread between the caller and `counterpartyId`.
  /// Throws `ChatException('gate_not_met')` if neither party has unlocked the
  /// other or been admin-assigned to a vacancy.
  Future<ChatThread> openOrGetThread(String counterpartyId);

  Future<List<ChatThread>> listMyThreads(String userId);

  Future<List<ChatMessage>> loadHistory(String threadId, {int limit = 200});

  Future<ChatMessage> sendMessage({required String threadId, required String body});

  Future<void> markRead(String threadId);

  Stream<ChatMessage> watchInserts(String threadId);
}
