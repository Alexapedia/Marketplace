part of 'custom_order_details_cubit.dart';

class CustomOrderDetailsState extends Equatable {
  const CustomOrderDetailsState({
    this.status = RequestStatus.init,
    this.order,
    this.error = '',
  });
  final RequestStatus status;
  final CustomOrderModel? order;
  final String error;
  @override
  List<Object?> get props => [status, order, error];
  CustomOrderDetailsState copyWith({
    RequestStatus? status,
    CustomOrderModel? order,
    String? error,
  }) =>
      CustomOrderDetailsState(
        status: status ?? this.status,
        order: order ?? this.order,
        error: error ?? this.error,
      );
}
