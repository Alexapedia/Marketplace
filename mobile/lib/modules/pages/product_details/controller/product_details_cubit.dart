import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit() : super(const ProductDetailsState());

  Future<void> load(String id) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.product(id));
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final product = ProductModel.fromJson(unwrapData(s.response));
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            product: product,
            quantity: 1,
            selectedSize: product.sizes.isNotEmpty ? product.sizes.first : null,
          ),
        );
      },
    );
  }

  void setSize(String size) => emit(state.copyWith(selectedSize: size));
  void setQty(int q) => emit(state.copyWith(quantity: q.clamp(1, 99)));

  Future<void> toggleFav() async {
    final p = state.product;
    if (p == null) return;
    final isFav = p.isFavorite;
    emit(state.copyWith(product: p.copyWith(isFavorite: !isFav)));
    if (isFav) {
      await sl.get<ApiConsumer>().delete(EndPoints.favorite(p.id));
    } else {
      await sl.get<ApiConsumer>().post(EndPoints.favorite(p.id), body: {});
    }
  }
}
