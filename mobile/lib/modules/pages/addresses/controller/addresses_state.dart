part of 'addresses_cubit.dart';

class AddressesState extends Equatable {
  const AddressesState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.selectedId = '',
    this.error = '',
    this.saving = false,
  });

  final RequestStatus status;
  final List<AddressModel> items;
  final String selectedId;
  final String error;
  final bool saving;

  AddressModel? get selected =>
      items.where((e) => e.id == selectedId).firstOrNull ??
      items.where((e) => e.isDefault).firstOrNull;

  @override
  List<Object?> get props => [status, items, selectedId, error, saving];

  AddressesState copyWith({
    RequestStatus? status,
    List<AddressModel>? items,
    String? selectedId,
    String? error,
    bool? saving,
  }) =>
      AddressesState(
        status: status ?? this.status,
        items: items ?? this.items,
        selectedId: selectedId ?? this.selectedId,
        error: error ?? this.error,
        saving: saving ?? this.saving,
      );
}
