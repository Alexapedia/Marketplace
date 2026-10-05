import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/models/review_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    try {
      final result = await sl.get<ApiConsumer>().get(EndPoints.home);
      result.fold(
        (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
        (s) {
          final data = asMap(unwrapData(s.response));
          emit(
            state.copyWith(
              status: RequestStatus.loaded,
              config: AppConfigModel.fromJson(asMap(data['config'])),
              ads: _banners(data['ads']),
              categories: _categories(data['categories']),
              featured: _products(data['featured']),
              newArrivals: _products(data['newArrivals']),
              bestSellers: _products(data['bestSellers']),
              highlights: _reviews(data['highlights']),
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(status: RequestStatus.failed, error: 'error_generic'.tr()));
    }
  }

  List<BannerModel> _banners(dynamic raw) {
    final data = unwrapData(raw);
    return asList(data is List ? data : asMap(data)['items'])
        .map(BannerModel.fromJson)
        .toList();
  }

  List<CategoryModel> _categories(dynamic raw) {
    final data = unwrapData(raw);
    return asList(data is List ? data : asMap(data)['items'])
        .map(CategoryModel.fromJson)
        .toList();
  }

  List<ProductModel> _products(dynamic raw) {
    final data = unwrapData(raw);
    return asList(
      data is List ? data : asMap(data)['items'] ?? asMap(data)['products'],
    ).map(ProductModel.fromJson).toList();
  }

  List<ReviewModel> _reviews(dynamic raw) {
    final data = unwrapData(raw);
    return asList(data is List ? data : asMap(data)['items'])
        .map(ReviewModel.fromJson)
        .toList();
  }
}
