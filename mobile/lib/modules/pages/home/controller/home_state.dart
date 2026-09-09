part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = RequestStatus.init,
    this.config = const AppConfigModel(),
    this.categories = const [],
    this.featured = const [],
    this.newArrivals = const [],
    this.bestSellers = const [],
    this.error = '',
  });

  final RequestStatus status;
  final AppConfigModel config;
  final List<CategoryModel> categories;
  final List<ProductModel> featured;
  final List<ProductModel> newArrivals;
  final List<ProductModel> bestSellers;
  final String error;

  @override
  List<Object?> get props =>
      [status, config, categories, featured, newArrivals, bestSellers, error];

  HomeState copyWith({
    RequestStatus? status,
    AppConfigModel? config,
    List<CategoryModel>? categories,
    List<ProductModel>? featured,
    List<ProductModel>? newArrivals,
    List<ProductModel>? bestSellers,
    String? error,
  }) =>
      HomeState(
        status: status ?? this.status,
        config: config ?? this.config,
        categories: categories ?? this.categories,
        featured: featured ?? this.featured,
        newArrivals: newArrivals ?? this.newArrivals,
        bestSellers: bestSellers ?? this.bestSellers,
        error: error ?? this.error,
      );
}
