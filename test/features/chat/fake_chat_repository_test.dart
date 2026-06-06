import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/chat/data/fake_chat_repository.dart';
import 'package:home_tuition_nepal_app/features/chat/domain/chat_repository.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

const _student = 'fake-login';

void main() {
  late FakeWalletRepository wallet;
  late FakeChatRepository chat;

  setUp(() {
    wallet = FakeWalletRepository(PlatformSettingsService());
    chat = FakeChatRepository(wallet);
  });

  group('FakeChatRepository', () {
    test('openOrGetThread without a prior unlock throws gate_not_met', () async {
      expect(
        () => chat.openOrGetThread('tutor-1'),
        throwsA(isA<ChatException>().having((e) => e.isGateNotMet, 'isGateNotMet', true)),
      );
    });

    test('after unlock, opening is allowed and idempotent', () async {
      await wallet.unlockContact(studentId: _student, tutorId: 'tutor-1');
      final a = await chat.openOrGetThread('tutor-1');
      final b = await chat.openOrGetThread('tutor-1');
      expect(a.id, b.id);
      expect(a.tutorId, 'tutor-1');
    });

    test('sendMessage rejects phone numbers', () async {
      await wallet.unlockContact(studentId: _student, tutorId: 'tutor-1');
      final t = await chat.openOrGetThread('tutor-1');
      expect(
        () => chat.sendMessage(threadId: t.id, body: 'call me 9812345678'),
        throwsA(isA<ChatException>().having((e) => e.isPhoneInMessage, 'isPhoneInMessage', true)),
      );
    });

    test('sendMessage rejects an empty message', () async {
      await wallet.unlockContact(studentId: _student, tutorId: 'tutor-1');
      final t = await chat.openOrGetThread('tutor-1');
      expect(
        () => chat.sendMessage(threadId: t.id, body: '   '),
        throwsA(isA<ChatException>()),
      );
    });

    test('a sent message is stored and streamed to watchInserts', () async {
      await wallet.unlockContact(studentId: _student, tutorId: 'tutor-1');
      final t = await chat.openOrGetThread('tutor-1');
      final received = <String>[];
      final sub = chat.watchInserts(t.id).listen((m) => received.add(m.body));
      final sent = await chat.sendMessage(threadId: t.id, body: 'Hello sir');
      expect(sent.body, 'Hello sir');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(received, contains('Hello sir'));
      final history = await chat.loadHistory(t.id);
      expect(history.any((m) => m.body == 'Hello sir'), isTrue);
      await sub.cancel();
    });

    test('markRead marks the incoming (tutor) auto-reply as read', () async {
      await wallet.unlockContact(studentId: _student, tutorId: 'tutor-1');
      final t = await chat.openOrGetThread('tutor-1');
      await chat.sendMessage(threadId: t.id, body: 'Hello');
      // The fake auto-echoes a tutor reply ~1s later.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await chat.markRead(t.id);
      final history = await chat.loadHistory(t.id);
      final incoming = history.where((m) => m.senderId == 'tutor-1').toList();
      expect(incoming, isNotEmpty);
      expect(incoming.every((m) => m.isRead), isTrue);
    });

    test('listMyThreads returns threads the user participates in', () async {
      await wallet.unlockContact(studentId: _student, tutorId: 'tutor-1');
      await chat.openOrGetThread('tutor-1');
      final mine = await chat.listMyThreads(_student);
      expect(mine.length, 1);
    });
  });
}
