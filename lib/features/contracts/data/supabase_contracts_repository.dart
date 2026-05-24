import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/contracts_repository.dart';
import '../domain/models/contract.dart';

class SupabaseContractsRepository implements ContractsRepository {
  SupabaseContractsRepository(this._client);

  final sb.SupabaseClient _client;

  @override
  Future<Contract?> latestForThread(String threadId) async {
    try {
      final row = await _client
          .from('contracts')
          .select()
          .eq('thread_id', threadId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return row == null ? null : Contract.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw ContractsException('latest_failed', e.message);
    }
  }

  @override
  Future<Contract> propose({
    required String threadId,
    required String studentId,
    required String tutorId,
    required String proposedBy,
    required String subject,
    num? rateNpr,
    required ContractRatePeriod ratePeriod,
    String? scheduleText,
  }) async {
    try {
      final row = await _client
          .from('contracts')
          .insert({
            'thread_id': threadId,
            'student_id': studentId,
            'tutor_id': tutorId,
            'proposed_by': proposedBy,
            'subject': subject,
            'rate_npr': rateNpr,
            'rate_period': ratePeriod.value,
            'schedule_text': scheduleText,
            'status': 'proposed',
          })
          .select()
          .single();
      return Contract.fromRow(row);
    } on sb.PostgrestException catch (e) {
      throw ContractsException('propose_failed', e.message);
    }
  }

  @override
  Future<void> accept(String contractId) => _rpc('accept_contract', contractId);

  @override
  Future<void> decline(String contractId) => _rpc('decline_contract', contractId);

  @override
  Future<void> end(String contractId) => _rpc('end_contract', contractId);

  @override
  Future<void> cancel(String contractId) => _rpc('cancel_contract', contractId);

  Future<void> _rpc(String name, String contractId) async {
    try {
      await _client.rpc(name, params: {'p_contract_id': contractId});
    } on sb.PostgrestException catch (e) {
      throw ContractsException(name, e.message);
    }
  }
}
