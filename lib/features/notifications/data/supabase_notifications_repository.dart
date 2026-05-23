import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/app_notification.dart';
import '../domain/notifications_repository.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);
  final sb.SupabaseClient _client;

  @override
  Future<List<AppNotification>> list(String userId, {int limit = 100}) async {
    try {
      final rows = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromRow)
          .toList();
    } on sb.PostgrestException catch (e) {
      throw NotificationsException('list_failed', e.message);
    }
  }

  @override
  Future<void> markRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', notificationId);
    } on sb.PostgrestException catch (e) {
      throw NotificationsException('mark_read_failed', e.message);
    }
  }

  @override
  Future<void> markAllRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('user_id', userId)
          .isFilter('read_at', null);
    } on sb.PostgrestException catch (e) {
      throw NotificationsException('mark_all_read_failed', e.message);
    }
  }

  @override
  Stream<AppNotification> watchInserts(String userId) {
    // Supabase Realtime channel on the notifications table filtered by user_id.
    // Falls back to a single replay of the initial list if the channel never
    // emits — the caller already has the initial list from list().
    final controller = StreamController<AppNotification>.broadcast();
    final channel = _client.channel('public:notifications:$userId');
    channel.onPostgresChanges(
      event: sb.PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: sb.PostgresChangeFilter(
        type: sb.PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        try {
          controller.add(AppNotification.fromRow(payload.newRecord));
        } catch (_) {/* swallow malformed rows */}
      },
    );
    channel.subscribe();
    controller.onCancel = () => _client.removeChannel(channel);
    return controller.stream;
  }
}
