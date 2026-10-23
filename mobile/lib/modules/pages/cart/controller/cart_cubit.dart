import 'package:dartz/dartz.dart' hide State;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/api_model.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../core/utils/functions/safe_emit.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> with SafeEmitMixin<CartState> {
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

  /// Applies the cart returned by a mutation, or reports the failure.
  void _apply(Either<String, ApiModel> response, {String? successMsg}) {
    response.fold(
      (l) => AppToast(l, isError: true),
      (s) {
        if (successMsg != null) AppToast(successMsg);
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
    _apply(
      await sl.get<ApiConsumer>().patch(
        EndPoints.cartItem(itemId),
        body: {'quantity': qty},
      ),
    );
  }

  Future<void> remove(String itemId) async {
    _apply(await sl.get<ApiConsumer>().delete(EndPoints.cartItem(itemId)));
  }

  Future<void> clear() async {
    _apply(await sl.get<ApiConsumer>().delete(EndPoints.cart), successMsg: 'empty_cart');
  }
}
