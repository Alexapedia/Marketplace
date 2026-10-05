import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/models/address_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../addresses/controller/addresses_cubit.dart';

part 'address_form_state.dart';

class AddressFormCubit extends Cubit<AddressFormState> {
  AddressFormCubit(this.initial) : super(AddressFormState.from(initial)) {
    label = TextEditingController(text: initial?.label ?? 'Home');
    name = TextEditingController(text: initial?.fullName ?? '');
    phone = TextEditingController(text: initial?.phone ?? '');
    city = TextEditingController(text: initial?.city ?? '');
    street = TextEditingController(text: initial?.street ?? '');
    notes = TextEditingController(text: initial?.notes ?? '');
  }

  final AddressModel? initial;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController label;
  late final TextEditingController name;
  late final TextEditingController phone;
  late final TextEditingController city;
  late final TextEditingController street;
  late final TextEditingController notes;

  void setPoint(LatLng point) {
    emit(state.copyWith(lat: point.latitude, lng: point.longitude));
  }

  void setDefault(bool value) {
    emit(state.copyWith(isDefault: value));
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    emit(state.copyWith(status: RequestStatus.loading));
    final cubit = AddressesCubit();
    final ok = await cubit.save(
      AddressModel(
        id: initial?.id ?? '',
        label: label.text.trim(),
        fullName: name.text.trim(),
        phone: phone.text.trim(),
        city: city.text.trim(),
        street: street.text.trim(),
        notes: notes.text.trim(),
        lat: state.lat,
        lng: state.lng,
        isDefault: state.isDefault,
      ),
    );
    await cubit.close();
    emit(state.copyWith(
      status: RequestStatus.loaded,
      saved: ok,
    ));
  }

  @override
  Future<void> close() {
    label.dispose();
    name.dispose();
    phone.dispose();
    city.dispose();
    street.dispose();
    notes.dispose();
    return super.close();
  }
}
