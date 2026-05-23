part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => const [];
}

/// Opens (or finds) the thread with `counterpartyId`, loads history, and
/// subscribes to realtime inserts. The viewer must already have unlocked the
/// counterparty (or been admin-assigned) — otherwise opens with an error.
class ChatOpened extends ChatEvent {
  const ChatOpened(this.counterpartyId);
  final String counterpartyId;
  @override
  List<Object?> get props => [counterpartyId];
}

class ChatMessageSent extends ChatEvent {
  const ChatMessageSent(this.body);
  final String body;
  @override
  List<Object?> get props => [body];
}

class ChatMessagesMarkedRead extends ChatEvent {
  const ChatMessagesMarkedRead();
}

class _ChatMessageReceived extends ChatEvent {
  const _ChatMessageReceived(this.m);
  final ChatMessage m;
  @override
  List<Object?> get props => [m.id];
}

class ChatSendErrorCleared extends ChatEvent {
  const ChatSendErrorCleared();
}
