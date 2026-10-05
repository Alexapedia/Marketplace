part of 'address_form_cubit.dart';

class AddressFormState extends Equatable {
  const AddressFormState({
    this.status = RequestStatus.init,
    this.lat = 30.0444,
    this.lng = 31.2357,
    this.isDefault = false,
    this.saved = false,
  });

  factory AddressFormState.from(AddressModel? initial) {
    return AddressFormState(
      lat: initial?.lat ?? 30.0444,
      lng: initial?.lng ?? 31.2357,
      isDefault: initial?.isDefault ?? false,
    );
  }

  final RequestStatus status;
  final double lat;
  final double lng;
  final bool isDefault;
  final bool saved;

  @override
  List<Object?> get props => [status, lat, lng, isDefault, saved];

  AddressFormState copyWith({
    RequestStatus? status,
    double? lat,
    double? lng,
    bool? isDefault,
    bool? saved,
  }) =>
      AddressFormState(
        status: status ?? this.status,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        isDefault: isDefault ?? this.isDefault,
        saved: saved ?? this.saved,
      );
}
