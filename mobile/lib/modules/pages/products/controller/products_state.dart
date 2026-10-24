part of 'products_cubit.dart';

class ProductsState extends Equatable {
  const ProductsState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.ads = const [],
    this.query = '',
    this.error = '',
    this.page = 1,
    this.hasMore = false,
    this.loadingMore = false,
    this.sort = '',
    this.minPrice,
    this.maxPrice,
  });
  final RequestStatus status;
  final List<ProductModel> items;
  final List<BannerModel> ads;
  final String query;
  final String error;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  /// API sort key: '', '-createdAt', 'price', '-price', '-ratingAvg'.
  final String sort;
  final double? minPrice;
  final double? maxPrice;

  bool get hasFilters => sort.isNotEmpty || minPrice != null || maxPrice != null;

  @override
  List<Object?> get props =>
      [status, items, ads, query, error, page, hasMore, loadingMore, sort, minPrice, maxPrice];

  ProductsState copyWith({
    RequestStatus? status,
    List<ProductModel>? items,
    List<BannerModel>? ads,
    String? query,
    String? error,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? sort,
    double? Function()? minPrice,
    double? Function()? maxPrice,
  }) =>
      ProductsState(
        status: status ?? this.status,
        items: items ?? this.items,
        ads: ads ?? this.ads,
        query: query ?? this.query,
        error: error ?? this.error,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        sort: sort ?? this.sort,
        minPrice: minPrice != null ? minPrice() : this.minPrice,
        maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      );
}
