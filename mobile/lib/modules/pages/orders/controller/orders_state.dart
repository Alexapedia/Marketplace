part of 'orders_cubit.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.status = RequestStatus.init,
    this.detailStatus = RequestStatus.init,
    this.items = const [],
    this.current,
    this.error = '',
  });
  final RequestStatus status;
  final RequestStatus detailStatus;
  final List<OrderModel> items;
  final OrderModel? current;
  final String error;
  @override
  List<Object?> get props => [status, detailStatus, items, current, error];
  OrdersState copyWith({
    RequestStatus? status,
    RequestStatus? detailStatus,
    List<OrderModel>? items,
    OrderModel? current,
    String? error,
  }) =>
      OrdersState(
        status: status ?? this.status,
        detailStatus: detailStatus ?? this.detailStatus,
        items: items ?? this.items,
        current: current ?? this.current,
        error: error ?? this.error,
      );
}
