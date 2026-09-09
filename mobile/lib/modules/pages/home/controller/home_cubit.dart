import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      final results = await Future.wait([
        sl.get<ApiConsumer>().get(EndPoints.appConfig),
        sl.get<ApiConsumer>().get(EndPoints.categories),
        sl.get<ApiConsumer>().get(
          EndPoints.products,
          queryParameters: {'featured': true, 'limit': 10},
        ),
        sl.get<ApiConsumer>().get(
          EndPoints.products,
          queryParameters: {'newArrival': true, 'limit': 10},
        ),
        sl.get<ApiConsumer>().get(
          EndPoints.products,
          queryParameters: {'bestSeller': true, 'limit': 10},
        ),
      ]);
      AppConfigModel config = const AppConfigModel();
      results[0].fold((_) {}, (s) => config = AppConfigModel.fromJson(s.response));
      List<CategoryModel> cats = [];
      results[1].fold((_) {}, (s) {
        final data = unwrapData(s.response);
        cats = asList(data is List ? data : asMap(data)['items']).map(CategoryModel.fromJson).toList();
      });
      List<ProductModel> parse(dynamic r) {
        final data = unwrapData(r);
        return asList(data is List ? data : asMap(data)['items'] ?? asMap(data)['products'])
            .map(ProductModel.fromJson)
            .toList();
      }
      List<ProductModel> featured = [];
      List<ProductModel> arrivals = [];
      List<ProductModel> sellers = [];
      results[2].fold((_) {}, (s) => featured = parse(s.response));
      results[3].fold((_) {}, (s) => arrivals = parse(s.response));
      results[4].fold((_) {}, (s) => sellers = parse(s.response));
      emit(state.copyWith(
        status: RequestStatus.loaded,
        config: config,
        categories: cats,
        featured: featured,
        newArrivals: arrivals,
        bestSellers: sellers,
      ));
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failed, error: 'error_generic'.tr()));
    }
  }
}
