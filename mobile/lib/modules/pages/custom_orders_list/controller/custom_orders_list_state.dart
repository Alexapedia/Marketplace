part of 'custom_orders_list_cubit.dart';

class CustomOrdersListState extends Equatable {
  const CustomOrdersListState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
  });
  final RequestStatus status;
  final List<CustomOrderModel> items;
  final String error;
  @override
  List<Object?> get props => [status, items, error];
  CustomOrdersListState copyWith({
    RequestStatus? status,
    List<CustomOrderModel>? items,
    String? error,
  }) =>
      CustomOrdersListState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}
