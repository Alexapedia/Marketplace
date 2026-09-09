import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.cart);
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            cart: CartModel.fromJson(s.response),
          ),
        );
        sl.get<AppControllerCubit>().getCountOfCartItems();
      },
    );
  }

  Future<void> updateQty(String itemId, int qty) async {
    if (qty < 1) {
      await remove(itemId);
      return;
    }
    await sl.get<ApiConsumer>().patch(
      EndPoints.cartItem(itemId),
      body: {'quantity': qty},
    );
    await load();
  }

  Future<void> remove(String itemId) async {
    await sl.get<ApiConsumer>().delete(EndPoints.cartItem(itemId));
    await load();
  }

  Future<void> clear() async {
    await sl.get<ApiConsumer>().delete(EndPoints.cart);
    AppToast('empty_cart');
    await load();
  }
}
