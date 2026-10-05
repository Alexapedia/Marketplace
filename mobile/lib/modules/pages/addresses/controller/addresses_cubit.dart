import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/address_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'addresses_state.dart';

class AddressesCubit extends Cubit<AddressesState> {
  AddressesCubit() : super(const AddressesState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.addresses);
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(data is List ? data : asMap(data)['items'])
            .map(AddressModel.fromJson)
            .toList();
        final selected = list.where((e) => e.isDefault).firstOrNull?.id ??
            (list.isNotEmpty ? list.first.id : '');
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            items: list,
            selectedId: selected,
          ),
        );
      },
    );
  }

  void select(String id) {
    emit(state.copyWith(selectedId: id));
  }

  Future<void> setDefault(String id) async {
    final response = await sl.get<ApiConsumer>().patch(
      EndPoints.addressDefault(id),
    );
    response.fold((l) => AppToast(l, isError: true), (_) => load());
  }

  Future<void> remove(String id) async {
    final response = await sl.get<ApiConsumer>().delete(EndPoints.address(id));
    response.fold((l) => AppToast(l, isError: true), (_) => load());
  }

  Future<bool> save(AddressModel address) async {
    emit(state.copyWith(saving: true));
    final response = address.id.isEmpty
        ? await sl.get<ApiConsumer>().post(
            EndPoints.addresses,
            body: address.toJson(),
          )
        : await sl.get<ApiConsumer>().patch(
            EndPoints.address(address.id),
            body: address.toJson(),
          );
    var ok = false;
    response.fold((l) => AppToast(l, isError: true), (_) {
      ok = true;
      AppToast('saved');
    });
    emit(state.copyWith(saving: false));
    if (ok) await load();
    return ok;
  }
}
