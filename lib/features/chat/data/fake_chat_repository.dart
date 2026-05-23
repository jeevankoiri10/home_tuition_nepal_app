import 'dart:async';

import '../../../core/utils/phone_ban_regex.dart';
import '../../wallet/domain/wallet_repository.dart';
import '../domain/chat_repository.dart';
import '../domain/models/chat_message.dart';
import '../domain/models/chat_thread.dart';

/// In-memory chat for local dev. Mirrors the SQL gates:
///   - openOrGetThread requires a prior unlock (idempotent in-memory)
///   - sendMessage enforces the phone-ban regex client-side
class FakeChatRepository implements ChatRepository {
  FakeChatRepository(this._wallet);

  final WalletRepository _wallet;
  // ignore: unused_field — wallet is used indirectly via the unlock check
  // when this repo decides whether the gate is met.

  final Map<String, ChatThread> _threadsById = {};
  final Map<String, List<ChatMessage>> _messagesByThread = {};
  final Map<String, StreamController<ChatMessage>> _streamsByThread = {};

  String _pairKey(String studentId, String tutorId) => '$studentId|$tutorId';

  Future<bool> _hasUnlocked(String studentId, String tutorId) async {
    // The FakeWallet records unlocks via ledger entries — we can probe by
    // pretending to unlock and catching the idempotent return. But cleaner:
    // we re-call unlockContact knowing the fake repo is idempotent. To avoid
    // accidental debits the demo treats "already unlocked" as gate-met.
    try {
      await _wallet.unlockContact(studentId: studentId, tutorId: tutorId);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ChatThread> openOrGetThread(String counterpartyId) async {
    // The fake repo assumes the caller is the demo student id used by
    // FakeAuthRepository. Production goes through Supabase RPC with auth.uid().
    const demoStudent = 'fake-login';
    final key = _pairKey(demoStudent, counterpartyId);
    final existing = _threadsById[key];
    if (existing != null) return existing;

    final ok = await _hasUnlocked(demoStudent, counterpartyId);
    if (!ok) {
      throw ChatException('gate_not_met', 'Unlock the tutor first to start a chat.');
    }

    final thread = ChatThread(
      id: 'thread-${_threadsById.length}',
      studentId: demoStudent,
      tutorId: counterpartyId,
      openedVia: 'contact_unlock',
      createdAt: DateTime.now(),
    );
    _threadsById[key] = thread;
    _messagesByThread[thread.id] = [];
    return thread;
  }

  @override
  Future<List<ChatThread>> listMyThreads(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _threadsById.values
        .where((t) => t.studentId == userId || t.tutorId == userId)
        .toList();
  }

  @override
  Future<List<ChatMessage>> loadHistory(String threadId, {int limit = 200}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<ChatMessage>.from(_messagesByThread[threadId] ?? const []);
  }

  @override
  Future<ChatMessage> sendMessage({required String threadId, required String body}) async {
    if (body.trim().isEmpty) throw ChatException('empty_message', 'Message is empty.');
    if (PhoneBanRegex.isViolation(body)) {
      throw ChatException('phone_in_message', 'Remove phone numbers or contact details.');
    }
    final thread = _threadsById.values.firstWhere(
      (t) => t.id == threadId,
      orElse: () => throw ChatException('thread_not_found_or_forbidden', 'Thread not found.'),
    );
    final senderId = thread.studentId; // demo: outgoing always from the student
    final msg = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      threadId: threadId,
      senderId: senderId,
      body: body.trim(),
      sentAt: DateTime.now(),
    );
    _messagesByThread.putIfAbsent(threadId, () => []).add(msg);
    _streamsByThread[threadId]?.add(msg);

    // Demo: auto-echo from the tutor 1 second later so the UI gets a reply
    // bubble to render.
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      final reply = ChatMessage(
        id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
        threadId: threadId,
        senderId: thread.tutorId,
        body: 'Got it — I\'ll get back to you shortly.',
        sentAt: DateTime.now(),
      );
      _messagesByThread[threadId]?.add(reply);
      _streamsByThread[threadId]?.add(reply);
    });

    return msg;
  }

  @override
  Future<void> markRead(String threadId) async {
    final list = _messagesByThread[threadId];
    if (list == null) return;
    for (int i = 0; i < list.length; i++) {
      final m = list[i];
      if (m.senderId != 'fake-login' && m.readAt == null) {
        list[i] = m.copyWith(readAt: DateTime.now());
      }
    }
  }

  @override
  Stream<ChatMessage> watchInserts(String threadId) {
    final ctl = _streamsByThread.putIfAbsent(
      threadId,
      () => StreamController<ChatMessage>.broadcast(),
    );
    return ctl.stream;
  }
}
