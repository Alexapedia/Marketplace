part of 'check_out_cubit.dart';

class CheckOutState extends Equatable {
  const CheckOutState({
    this.status = RequestStatus.init,
    this.addresses = const [],
    this.selectedId = '',
    this.error = '',
  });
  final RequestStatus status;
  final List<AddressModel> addresses;
  final String selectedId;
  final String error;
  @override
  List<Object> get props => [status, addresses, selectedId, error];
  CheckOutState copyWith({
    RequestStatus? status,
    List<AddressModel>? addresses,
    String? selectedId,
    String? error,
  }) =>
      CheckOutState(
        status: status ?? this.status,
        addresses: addresses ?? this.addresses,
        selectedId: selectedId ?? this.selectedId,
        error: error ?? this.error,
      );
}
