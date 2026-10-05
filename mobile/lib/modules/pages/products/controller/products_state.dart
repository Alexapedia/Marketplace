part of 'products_cubit.dart';

class ProductsState extends Equatable {
  const ProductsState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.ads = const [],
    this.query = '',
    this.error = '',
  });
  final RequestStatus status;
  final List<ProductModel> items;
  final List<BannerModel> ads;
  final String query;
  final String error;
  @override
  List<Object> get props => [status, items, ads, query, error];
  ProductsState copyWith({
    RequestStatus? status,
    List<ProductModel>? items,
    List<BannerModel>? ads,
    String? query,
    String? error,
  }) =>
      ProductsState(
        status: status ?? this.status,
        items: items ?? this.items,
        ads: ads ?? this.ads,
        query: query ?? this.query,
        error: error ?? this.error,
      );
}
