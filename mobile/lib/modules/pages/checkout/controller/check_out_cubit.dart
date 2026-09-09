import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';

part 'checkout_state.dart';

class CheckOutCubit extends Cubit<CheckOutState> {
  CheckOutCubit() : super(const CheckOutState());

  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  final city = TextEditingController();
  final street = TextEditingController();
  final building = TextEditingController();
  final apartment = TextEditingController();
  final country = TextEditingController();
  final notes = TextEditingController();

  Future<void> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    emit(state.copyWith(status: RequestStatus.loading));
    final address = OrderAddress(
      fullName: name.text.trim(),
      phone: phone.text.trim(),
      city: city.text.trim(),
      street: street.text.trim(),
      building: building.text.trim(),
      apartment: apartment.text.trim(),
      country: country.text.trim(),
      line: [
        street.text,
        building.text,
        apartment.text,
        city.text,
      ].where((e) => e.trim().isNotEmpty).join(', '),
    );
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.orders,
      body: {
        'address': address.toJson(),
        'notes': notes.text.trim(),
        'paymentMethod': 'COD',
      },
    );
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed));
      },
      (s) {
        AppToast('order_placed');
        emit(state.copyWith(status: RequestStatus.loaded));
        sl.get<AppControllerCubit>().getCountOfCartItems();
        if (context.mounted) {
          final order = OrderModel.fromJson(unwrapData(s.response));
          RouterHandler.navigate(
            context,
            AppRouterKeys.orderDetails,
            extra: order.id,
            routerType: RouterType.goName,
          );
        }
      },
    );
  }

  @override
  Future<void> close() {
    name.dispose();
    phone.dispose();
    city.dispose();
    street.dispose();
    building.dispose();
    apartment.dispose();
    country.dispose();
    notes.dispose();
    return super.close();
  }
}
