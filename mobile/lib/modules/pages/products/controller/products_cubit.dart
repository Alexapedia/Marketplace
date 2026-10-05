import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({
    this.categoryId,
    this.featured = false,
    this.newArrival = false,
    this.bestSeller = false,
    String? search,
  }) : super(const ProductsState()) {
    searchController.text = search ?? '';
  }

  final String? categoryId;
  final bool featured;
  final bool newArrival;
  final bool bestSeller;
  final searchController = TextEditingController();
  Timer? _debounce;

  Future<void> load({String? search}) async {
    final q = search ?? searchController.text;
    emit(state.copyWith(status: RequestStatus.loading, query: q));
    final results = await Future.wait([
      sl.get<ApiConsumer>().get(
        EndPoints.products,
        queryParameters: {
          if (categoryId != null && categoryId!.isNotEmpty) 'categoryId': categoryId,
          if (q.isNotEmpty) 'search': q,
          if (featured) 'featured': true,
          if (newArrival) 'newArrival': true,
          if (bestSeller) 'bestSeller': true,
          'limit': 40,
        },
      ),
      sl.get<ApiConsumer>().get(EndPoints.ads, queryParameters: {'placement': 'products'}),
    ]);
    List<ProductModel> list = [];
    List<BannerModel> ads = [];
    results[0].fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        list = asList(
          data is List ? data : asMap(data)['items'] ?? asMap(data)['products'],
        ).map(ProductModel.fromJson).toList();
      },
    );
    if (state.status == RequestStatus.failed) return;
    results[1].fold((_) {}, (s) {
      final data = unwrapData(s.response);
      ads = asList(data is List ? data : asMap(data)['items'])
          .map(BannerModel.fromJson)
          .toList();
    });
    emit(state.copyWith(status: RequestStatus.loaded, items: list, ads: ads));
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => load(search: value));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    searchController.dispose();
    return super.close();
  }
}
