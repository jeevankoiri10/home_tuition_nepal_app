import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/chat_repository.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/chat_thread.dart';

class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository(this._client);
  final sb.SupabaseClient _client;

  @override
  Future<ChatThread> openOrGetThread(String counterpartyId) async {
    try {
      final id = await _client.rpc('open_or_get_thread', params: {
        'p_counterparty': counterpartyId,
      }) as String;
      final row =
          await _client.from('chat_threads').select().eq('id', id).single();
      return ChatThread.fromRow(row);
    } on sb.PostgrestException catch (e) {
      final m = e.message;
      if (m.contains('gate_not_met')) {
        throw ChatException('gate_not_met', m);
      }
      throw ChatException('open_thread_failed', m);
    }
  }

  @override
  Future<List<ChatThread>> listMyThreads(String userId) async {
    try {
      final rows = await _client
          .from('chat_threads')
          .select()
          .or('student_id.eq.$userId,tutor_id.eq.$userId')
          .order('last_message_at', ascending: false, nullsFirst: false);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map((r) => ChatThread.fromRow(r))
          .toList();
    } on sb.PostgrestException catch (e) {
      throw ChatException('list_threads_failed', e.message);
    }
  }

  @override
  Future<List<ChatMessage>> loadHistory(String threadId, {int limit = 200}) async {
    try {
      final rows = await _client
          .from('chat_messages')
          .select()
          .eq('thread_id', threadId)
          .order('sent_at', ascending: true)
          .limit(limit);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(ChatMessage.fromRow)
          .toList();
    } on sb.PostgrestException catch (e) {
      throw ChatException('history_failed', e.message);
    }
  }

  @override
  Future<ChatMessage> sendMessage({required String threadId, required String body}) async {
    try {
      final id = await _client.rpc('send_chat_message', params: {
        'p_thread_id': threadId,
        'p_body': body,
      }) as String;
      final row =
          await _client.from('chat_messages').select().eq('id', id).single();
      return ChatMessage.fromRow(row);
    } on sb.PostgrestException catch (e) {
      final m = e.message;
      if (m.contains('phone_in_message')) {
        throw ChatException('phone_in_message', m);
      }
      throw ChatException('send_failed', m);
    }
  }

  @override
  Future<void> markRead(String threadId) async {
    try {
      await _client.rpc('mark_messages_read', params: {'p_thread_id': threadId});
    } on sb.PostgrestException catch (e) {
      throw ChatException('mark_read_failed', e.message);
    }
  }

  @override
  Stream<ChatMessage> watchInserts(String threadId) {
    final controller = StreamController<ChatMessage>.broadcast();
    final channel = _client.channel('public:chat_messages:$threadId');
    channel.onPostgresChanges(
      event: sb.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'chat_messages',
      filter: sb.PostgresChangeFilter(
        type: sb.PostgresChangeFilterType.eq,
        column: 'thread_id',
        value: threadId,
      ),
      callback: (payload) {
        try {
          controller.add(ChatMessage.fromRow(payload.newRecord));
        } catch (_) {/* swallow malformed */}
      },
    );
    channel.subscribe();
    controller.onCancel = () => _client.removeChannel(channel);
    return controller.stream;
  }
}
