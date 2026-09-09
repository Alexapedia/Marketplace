part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
  });
  final RequestStatus status;
  final List<NotificationModel> items;
  final String error;
  @override
  List<Object> get props => [status, items, error];
  NotificationsState copyWith({
    RequestStatus? status,
    List<NotificationModel>? items,
    String? error,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}
