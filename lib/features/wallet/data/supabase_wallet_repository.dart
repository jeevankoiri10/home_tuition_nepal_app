import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/ledger_entry.dart';
import '../domain/wallet_repository.dart';

class SupabaseWalletRepository implements WalletRepository {
  SupabaseWalletRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<int> loadBalance(String userId) async {
    try {
      final row = await _client
          .from('profiles')
          .select('coin_balance')
          .eq('id', userId)
          .single();
      return (row['coin_balance'] as int?) ?? 0;
    } on sb.PostgrestException catch (e) {
      throw WalletException('balance_load_failed', e.message);
    }
  }

  @override
  Future<List<LedgerEntry>> loadHistory(String userId, {int limit = 50}) async {
    try {
      final rows = await _client
          .from('wallet_ledger')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List)
          .cast<Map<String, dynamic>>()
          .map(LedgerEntry.fromRow)
          .toList();
    } on sb.PostgrestException catch (e) {
      throw WalletException('history_load_failed', e.message);
    }
  }

  @override
  Future<bool> hasUnlocked({required String studentId, required String tutorId}) async {
    try {
      final rows = await _client
          .from('wallet_ledger')
          .select('id')
          .eq('user_id', studentId)
          .eq('reason', 'unlock')
          .eq('ref_id', tutorId)
          .limit(1);
      return (rows as List).isNotEmpty;
    } on sb.PostgrestException catch (e) {
      throw WalletException('has_unlocked_failed', e.message);
    }
  }

  @override
  Future<int> unlockContact({required String studentId, required String tutorId}) {
    return _callIntRpc('unlock_contact', {'p_tutor_id': tutorId});
  }

  @override
  Future<int> applyToVacancy({required String tutorId, required String vacancyId}) {
    return _callIntRpc('apply_to_vacancy', {'p_vacancy_id': vacancyId});
  }

  @override
  Future<int> bidOnJob({required String tutorId, required String jobId}) {
    return _callIntRpc('spend_coins_and_bid', {'p_job_id': jobId});
  }

  Future<int> _callIntRpc(String name, Map<String, dynamic> params) async {
    try {
      final res = await _client.rpc(name, params: params);
      return (res as num).toInt();
    } on sb.PostgrestException catch (e) {
      final msg = e.message;
      if (msg.contains('insufficient_coins')) {
        throw WalletException('insufficient_coins', msg);
      }
      throw WalletException(name, msg);
    }
  }
}
