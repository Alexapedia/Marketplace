import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.favorites);
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(data is List ? data : asMap(data)['items'])
            .map((e) {
              final map = asMap(e);
              if (map['productId'] is Map) {
                return ProductModel.fromJson(map['productId']);
              }
              if (map['product'] is Map) {
                return ProductModel.fromJson(map['product']);
              }
              return ProductModel.fromJson(e);
            })
            .where((p) => p.id.isNotEmpty)
            .map((p) => p.copyWith(isFavorite: true))
            .toList();
        emit(state.copyWith(status: RequestStatus.loaded, items: list));
      },
    );
  }

  Future<void> remove(String id) async {
    await sl.get<ApiConsumer>().delete(EndPoints.favorite(id));
    emit(state.copyWith(items: state.items.where((e) => e.id != id).toList()));
  }
}
