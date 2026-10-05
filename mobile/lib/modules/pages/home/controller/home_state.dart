part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = RequestStatus.init,
    this.config = const AppConfigModel(),
    this.categories = const [],
    this.featured = const [],
    this.newArrivals = const [],
    this.bestSellers = const [],
    this.ads = const [],
    this.highlights = const [],
    this.error = '',
  });

  final RequestStatus status;
  final AppConfigModel config;
  final List<BannerModel> ads;
  final List<CategoryModel> categories;
  final List<ProductModel> featured;
  final List<ProductModel> newArrivals;
  final List<ProductModel> bestSellers;
  final List<ReviewModel> highlights;
  final String error;

  @override
  List<Object?> get props =>
      [status, config, ads, categories, featured, newArrivals, bestSellers, highlights, error];

  HomeState copyWith({
    RequestStatus? status,
    AppConfigModel? config,
    List<BannerModel>? ads,
    List<CategoryModel>? categories,
    List<ProductModel>? featured,
    List<ProductModel>? newArrivals,
    List<ProductModel>? bestSellers,
    List<ReviewModel>? highlights,
    String? error,
  }) =>
      HomeState(
        status: status ?? this.status,
        config: config ?? this.config,
        ads: ads ?? this.ads,
        categories: categories ?? this.categories,
        featured: featured ?? this.featured,
        newArrivals: newArrivals ?? this.newArrivals,
        bestSellers: bestSellers ?? this.bestSellers,
        highlights: highlights ?? this.highlights,
        error: error ?? this.error,
      );
}
