part of 'order_details_cubit.dart';

class OrderDetailsState extends Equatable {
  const OrderDetailsState({
    this.status = RequestStatus.init,
    this.current,
    this.error = '',
  });
  final RequestStatus status;
  final OrderModel? current;
  final String error;
  @override
  List<Object?> get props => [status, current, error];
  OrderDetailsState copyWith({
    RequestStatus? status,
    OrderModel? current,
    String? error,
  }) =>
      OrderDetailsState(
        status: status ?? this.status,
        current: current ?? this.current,
        error: error ?? this.error,
      );
}
