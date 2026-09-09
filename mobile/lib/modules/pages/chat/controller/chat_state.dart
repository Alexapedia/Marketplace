part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = RequestStatus.init,
    this.messages = const [],
    this.orderId = '',
    this.error = '',
  });
  final RequestStatus status;
  final List<ChatMessageModel> messages;
  final String orderId;
  final String error;
  @override
  List<Object> get props => [status, messages, orderId, error];
  ChatState copyWith({
    RequestStatus? status,
    List<ChatMessageModel>? messages,
    String? orderId,
    String? error,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        orderId: orderId ?? this.orderId,
        error: error ?? this.error,
      );
}
