part of 'chat_bloc.dart';

enum ChatStatus { initial, opening, loading, ready, error }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.thread,
    this.messages = const [],
    this.errorMessage,
    this.sendError,
  });

  final ChatStatus status;
  final ChatThread? thread;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final String? sendError;

  ChatState copyWith({
    ChatStatus? status,
    ChatThread? thread,
    List<ChatMessage>? messages,
    String? errorMessage,
    String? sendError,
    bool clearError = false,
    bool clearSendError = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sendError: clearSendError ? null : (sendError ?? this.sendError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    thread,
    messages,
    errorMessage,
    sendError,
  ];
}
