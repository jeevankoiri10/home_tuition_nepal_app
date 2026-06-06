import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/chat_repository.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_thread.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._repo) : super(const ChatState()) {
    on<ChatOpened>(_onOpen);
    on<ChatMessageSent>(_onSend);
    on<ChatMessagesMarkedRead>(_onMarkRead);
    on<_ChatMessageReceived>(_onReceived);
    on<ChatSendErrorCleared>(
      (_, emit) => emit(state.copyWith(clearSendError: true)),
    );
  }

  final ChatRepository _repo;
  StreamSubscription<ChatMessage>? _sub;

  Future<void> _onOpen(ChatOpened e, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.opening, clearError: true));
    try {
      final thread = await _repo.openOrGetThread(e.counterpartyId);
      emit(state.copyWith(status: ChatStatus.loading, thread: thread));
      final history = await _repo.loadHistory(thread.id);
      emit(state.copyWith(status: ChatStatus.ready, messages: history));
      _sub?.cancel();
      _sub = _repo
          .watchInserts(thread.id)
          .listen((m) => add(_ChatMessageReceived(m)));
      // Mark incoming as read on open.
      try {
        await _repo.markRead(thread.id);
      } catch (_) {
        /* non-fatal */
      }
    } on ChatException catch (err) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: err.isGateNotMet
              ? 'Unlock the tutor first to start chatting.'
              : (err.message ?? err.code),
        ),
      );
    }
  }

  Future<void> _onSend(ChatMessageSent e, Emitter<ChatState> emit) async {
    final thread = state.thread;
    if (thread == null) return;
    try {
      final sent = await _repo.sendMessage(threadId: thread.id, body: e.body);
      // Optimistically append (realtime may also deliver the same row; we
      // de-dupe in _onReceived).
      if (!state.messages.any((m) => m.id == sent.id)) {
        emit(state.copyWith(messages: [...state.messages, sent]));
      }
    } on ChatException catch (err) {
      emit(
        state.copyWith(
          sendError: err.isPhoneInMessage
              ? 'Remove phone numbers or contact details from your message.'
              : (err.message ?? err.code),
        ),
      );
    }
  }

  Future<void> _onMarkRead(_, Emitter<ChatState> emit) async {
    final t = state.thread;
    if (t == null) return;
    try {
      await _repo.markRead(t.id);
    } catch (_) {
      /* non-fatal */
    }
  }

  void _onReceived(_ChatMessageReceived e, Emitter<ChatState> emit) {
    if (state.messages.any((m) => m.id == e.m.id)) return;
    emit(state.copyWith(messages: [...state.messages, e.m]));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
