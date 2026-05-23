import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/models/coin_pack.dart';
import '../domain/models/top_up.dart';
import '../domain/top_ups_repository.dart';

class SupabaseTopUpsRepository implements TopUpsRepository {
  SupabaseTopUpsRepository(this._client);
  final sb.SupabaseClient _client;

  @override
  Future<List<CoinPack>> listPacks() async {
    try {
      final rows = await _client
          .from('coin_packs')
          .select()
          .eq('active', true)
          .order('sort_order', ascending: true);
      return (rows as List).cast<Map<String, dynamic>>().map(CoinPack.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw TopUpsException('list_failed', e.message);
    }
  }

  @override
  Future<TopUp> startTopUp({required CoinPack pack, required PaymentProvider provider}) async {
    try {
      final id = await _client.rpc('start_top_up', params: {
        'p_pack_id': pack.id,
        'p_provider': provider.value,
      }) as String;
      return getTopUp(id);
    } on sb.PostgrestException catch (e) {
      throw TopUpsException('start_failed', e.message);
    }
  }

  @override
  Future<void> cancelTopUp(String topUpId) async {
    try {
      await _client.rpc('cancel_top_up', params: {'p_top_up_id': topUpId});
    } on sb.PostgrestException catch (e) {
      throw TopUpsException('cancel_failed', e.message);
    }
  }

  @override
  Future<TopUp> getTopUp(String topUpId) async {
    try {
      final row = await _client.from('coin_top_ups').select().eq('id', topUpId).single();
      return TopUp.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw TopUpsException('get_failed', e.message);
    }
  }

  @override
  Future<List<TopUp>> listMine(String userId, {int limit = 25}) async {
    try {
      final rows = await _client
          .from('coin_top_ups')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (rows as List).cast<Map<String, dynamic>>().map(TopUp.fromRow).toList();
    } on sb.PostgrestException catch (e) {
      throw TopUpsException('list_mine_failed', e.message);
    }
  }

  @override
  Future<TopUp> debugSimulateSuccess(String topUpId) =>
      throw TopUpsException('not_supported',
          'Production top-ups must go through the provider webhook.');
}
