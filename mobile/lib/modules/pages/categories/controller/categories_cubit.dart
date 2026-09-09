import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(const CategoriesState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.categories);
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(data is List ? data : asMap(data)['items'])
            .map(CategoryModel.fromJson)
            .toList();
        emit(state.copyWith(status: RequestStatus.loaded, items: list));
      },
    );
  }
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(const ProductsState());

  Future<void> load({
    String? categoryId,
    String? search,
    bool? featured,
    bool? newArrival,
    bool? bestSeller,
    String? sort,
  }) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(
      EndPoints.products,
      queryParameters: {
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
        if (search != null && search.isNotEmpty) 'search': search,
        if (featured == true) 'featured': true,
        if (newArrival == true) 'newArrival': true,
        if (bestSeller == true) 'bestSeller': true,
        if (sort != null) 'sort': sort,
        'limit': 40,
      },
    );
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(
          data is List ? data : asMap(data)['items'] ?? asMap(data)['products'],
        ).map(ProductModel.fromJson).toList();
        emit(state.copyWith(status: RequestStatus.loaded, items: list));
      },
    );
  }
}

class ProductsState extends Equatable {
  const ProductsState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
  });
  final RequestStatus status;
  final List<ProductModel> items;
  final String error;
  @override
  List<Object> get props => [status, items, error];
  ProductsState copyWith({
    RequestStatus? status,
    List<ProductModel>? items,
    String? error,
  }) =>
      ProductsState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}
