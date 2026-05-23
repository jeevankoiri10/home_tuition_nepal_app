import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_tuition_nepal_app/core/services/platform_settings_service.dart';
import 'package:home_tuition_nepal_app/features/chat/data/fake_chat_repository.dart';
import 'package:home_tuition_nepal_app/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:home_tuition_nepal_app/features/wallet/data/fake_wallet_repository.dart';

void main() {
  group('ChatBloc with FakeChatRepository', () {
    late FakeWalletRepository wallet;
    late FakeChatRepository repo;

    setUp(() {
      wallet = FakeWalletRepository(PlatformSettingsService());
      repo = FakeChatRepository(wallet);
    });

    blocTest<ChatBloc, ChatState>(
      'opening a thread before unlock surfaces gate_not_met',
      build: () => ChatBloc(repo),
      act: (b) => b.add(const ChatOpened('tutor-x')),
      wait: const Duration(milliseconds: 600),
      verify: (b) {
        expect(b.state.status, ChatStatus.error);
        expect(b.state.errorMessage, contains('Unlock'));
      },
    );

    blocTest<ChatBloc, ChatState>(
      'after an unlock the thread opens and history loads',
      build: () => ChatBloc(repo),
      act: (b) async {
        await wallet.loadBalance('fake-login');
        await wallet.unlockContact(studentId: 'fake-login', tutorId: 'tutor-1');
        b.add(const ChatOpened('tutor-1'));
      },
      wait: const Duration(milliseconds: 800),
      verify: (b) {
        expect(b.state.status, ChatStatus.ready);
        expect(b.state.thread, isNotNull);
      },
    );

    blocTest<ChatBloc, ChatState>(
      'sending a message with a phone number is rejected client-side',
      build: () => ChatBloc(repo),
      act: (b) async {
        await wallet.unlockContact(studentId: 'fake-login', tutorId: 'tutor-2');
        b.add(const ChatOpened('tutor-2'));
        await Future<void>.delayed(const Duration(milliseconds: 600));
        b.add(const ChatMessageSent('Call me at 9812345678'));
      },
      wait: const Duration(milliseconds: 1200),
      verify: (b) {
        expect(b.state.sendError, isNotNull);
        // Bloc clears the error on the next ChatSendErrorCleared event, but
        // the listener in the page consumes it via the SnackBar.
      },
    );

    blocTest<ChatBloc, ChatState>(
      'sending a clean message appends to the message list and gets an auto-reply',
      build: () => ChatBloc(repo),
      act: (b) async {
        await wallet.unlockContact(studentId: 'fake-login', tutorId: 'tutor-3');
        b.add(const ChatOpened('tutor-3'));
        await Future<void>.delayed(const Duration(milliseconds: 600));
        b.add(const ChatMessageSent('Hi! Are you available this week?'));
      },
      wait: const Duration(milliseconds: 2200),
      verify: (b) {
        expect(b.state.messages.length, greaterThanOrEqualTo(2));
        expect(b.state.messages.last.body, contains('back to you'));
      },
    );
  });
}
