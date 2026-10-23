import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/models/pagination_meta.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/safe_emit.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> with SafeEmitMixin<ProductsState> {
  ProductsCubit({
    this.categoryId,
    this.featured = false,
    this.newArrival = false,
    this.bestSeller = false,
    String? search,
  }) : super(const ProductsState()) {
    searchController.text = search ?? '';
  }

  static const pageSize = 20;

  final String? categoryId;
  final bool featured;
  final bool newArrival;
  final bool bestSeller;
  final searchController = TextEditingController();
  Timer? _debounce;
  int _requestId = 0;

  Map<String, dynamic> _query(String q, int page) => {
        if (categoryId != null && categoryId!.isNotEmpty) 'categoryId': categoryId,
        if (q.isNotEmpty) 'search': q,
        if (featured) 'featured': true,
        if (newArrival) 'newArrival': true,
        if (bestSeller) 'bestSeller': true,
        if (state.sort.isNotEmpty) 'sort': state.sort,
        if (state.minPrice != null) 'minPrice': state.minPrice,
        if (state.maxPrice != null) 'maxPrice': state.maxPrice,
        'page': page,
        'limit': pageSize,
      };

  List<ProductModel> _parseItems(dynamic response) {
    final data = unwrapData(response);
    return asList(
      data is List ? data : asMap(data)['items'] ?? asMap(data)['products'],
    ).map(ProductModel.fromJson).toList();
  }

  bool _hasMore(dynamic response, int page, int received) {
    final meta = asMap(response)['meta'];
    if (meta != null) {
      final m = PaginationMeta.fromJson(meta);
      return m.page < m.totalPages;
    }
    return received >= pageSize;
  }

  Future<void> load({String? search}) async {
    final q = search ?? searchController.text;
    final request = ++_requestId;
    emit(state.copyWith(status: RequestStatus.loading, query: q, page: 1, hasMore: false));
    final results = await Future.wait([
      sl.get<ApiConsumer>().get(EndPoints.products, queryParameters: _query(q, 1)),
      sl.get<ApiConsumer>().get(EndPoints.ads, queryParameters: {'placement': 'products'}),
    ]);
    if (request != _requestId || isClosed) return; // a newer search superseded this one
    List<ProductModel> list = [];
    var hasMore = false;
    List<BannerModel> ads = [];
    var failed = false;
    results[0].fold(
      (l) {
        failed = true;
        emit(state.copyWith(status: RequestStatus.failed, error: l));
      },
      (s) {
        list = _parseItems(s.response);
        hasMore = _hasMore(s.response, 1, list.length);
      },
    );
    if (failed) return;
    results[1].fold((_) {}, (s) {
      final data = unwrapData(s.response);
      ads = asList(data is List ? data : asMap(data)['items']).map(BannerModel.fromJson).toList();
    });
    emit(state.copyWith(
      status: RequestStatus.loaded,
      items: list,
      ads: ads,
      page: 1,
      hasMore: hasMore,
    ));
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.status != RequestStatus.loaded) return;
    final request = _requestId;
    final next = state.page + 1;
    emit(state.copyWith(loadingMore: true));
    final response = await sl.get<ApiConsumer>().get(
      EndPoints.products,
      queryParameters: _query(state.query, next),
    );
    if (request != _requestId || isClosed) return;
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(loadingMore: false));
      },
      (s) {
        final more = _parseItems(s.response);
        emit(state.copyWith(
          items: [...state.items, ...more],
          page: next,
          hasMore: _hasMore(s.response, next, more.length),
          loadingMore: false,
        ));
      },
    );
  }

  void applyFilters({required String sort, double? minPrice, double? maxPrice}) {
    emit(state.copyWith(sort: sort, minPrice: () => minPrice, maxPrice: () => maxPrice));
    load();
  }

  void clearFilters() => applyFilters(sort: '');

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
