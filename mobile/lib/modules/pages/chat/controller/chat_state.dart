part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = RequestStatus.init,
    this.messages = const [],
    this.orderId = '',
    this.error = '',
    this.socketReady = false,
  });
  final RequestStatus status;
  final List<ChatMessageModel> messages;
  final String orderId;
  final String error;
  final bool socketReady;
  @override
  List<Object> get props => [status, messages, orderId, error, socketReady];
  ChatState copyWith({
    RequestStatus? status,
    List<ChatMessageModel>? messages,
    String? orderId,
    String? error,
    bool? socketReady,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        orderId: orderId ?? this.orderId,
        error: error ?? this.error,
        socketReady: socketReady ?? this.socketReady,
      );
}
