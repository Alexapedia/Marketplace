part of 'orders_cubit.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
  });
  final RequestStatus status;
  final List<OrderModel> items;
  final String error;
  @override
  List<Object?> get props => [status, items, error];
  OrdersState copyWith({
    RequestStatus? status,
    List<OrderModel>? items,
    String? error,
  }) =>
      OrdersState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}
