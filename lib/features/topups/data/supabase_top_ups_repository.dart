import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/constants/app_constants.dart';
import '../../../core/services/cloudinary_service.dart';
import '../domain/models/coin_pack.dart';
import '../domain/models/top_up.dart';
import '../domain/top_ups_repository.dart';

class SupabaseTopUpsRepository implements TopUpsRepository {
  SupabaseTopUpsRepository(this._client, this._cloudinary);
  final sb.SupabaseClient _client;
  final CloudinaryService _cloudinary;

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

  @override
  Future<TopUp> attachReceipt({
    required String topUpId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.lengthInBytes > AppConstants.topUpReceiptMaxBytes) {
      throw TopUpsException('receipt_too_large', 'Receipt must be smaller than 5 MB.');
    }
    try {
      final lower = fileName.toLowerCase();
      final ext = lower.endsWith('.pdf')
          ? 'pdf'
          : (lower.endsWith('.png') ? 'png' : 'jpg');
      // Receipts (images or PDF) are stored on Cloudinary. PDFs go in as `raw`.
      final url = await _cloudinary.uploadBytes(
        bytes: bytes,
        fileName: 'receipt.$ext',
        folder: 'topup-receipts/$topUpId',
        resourceType: ext == 'pdf' ? 'raw' : 'image',
      );
      // Stamp the URL on the top-up row via an owner-gated RPC. A direct
      // UPDATE is blocked by RLS (only admins may update coin_top_ups);
      // submit_topup_receipt lets the owner set receipt_url on their own
      // pending row. See migration 0021.
      await _client.rpc('submit_topup_receipt', params: {
        'p_top_up_id': topUpId,
        'p_receipt_url': url,
      });
      return getTopUp(topUpId);
    } on CloudinaryException catch (e) {
      throw TopUpsException('receipt_upload_failed', e.detail);
    } on sb.PostgrestException catch (e) {
      throw TopUpsException('receipt_attach_failed', e.message);
    }
  }
}
