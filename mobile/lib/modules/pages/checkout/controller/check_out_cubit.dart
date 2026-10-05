import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/address_models.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';

part 'checkout_state.dart';

class CheckOutCubit extends Cubit<CheckOutState> {
  CheckOutCubit() : super(const CheckOutState());

  final notes = TextEditingController();

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
            addresses: list,
            selectedId: selected,
          ),
        );
      },
    );
  }

  void select(String id) {
    emit(state.copyWith(selectedId: id));
  }

  Future<void> submit(BuildContext context) async {
    if (state.selectedId.isEmpty) {
      AppToast('no_addresses_hint', isError: true);
      if (context.mounted) {
        await context.pushNamed(AppRouterKeys.addressForm);
        await load();
      }
      return;
    }
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.orders,
      body: {
        'addressId': state.selectedId,
        'notes': notes.text.trim(),
        'paymentMethod': 'COD',
        'channel': 'mobile',
      },
    );
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed, error: l));
      },
      (s) {
        AppToast('order_placed');
        emit(state.copyWith(status: RequestStatus.loaded));
        sl.get<AppControllerCubit>().getCountOfCartItems();
        if (context.mounted) {
          final order = OrderModel.fromJson(unwrapData(s.response));
          context.goNamed(AppRouterKeys.orderDetails, extra: order.id);
        }
      },
    );
  }

  @override
  Future<void> close() {
    notes.dispose();
    return super.close();
  }
}
