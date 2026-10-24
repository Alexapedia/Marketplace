part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
  });
  final RequestStatus status;
  final List<NotificationModel> items;
  final String error;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  bool get hasUnread => items.any((e) => !e.isRead);

  @override
  List<Object> get props => [status, items, error, page, hasMore, loadingMore];
  NotificationsState copyWith({
    RequestStatus? status,
    List<NotificationModel>? items,
    String? error,
    int? page,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}
