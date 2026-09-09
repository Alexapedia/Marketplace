part of 'favorites_cubit.dart';

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
  });
  final RequestStatus status;
  final List<ProductModel> items;
  final String error;
  @override
  List<Object> get props => [status, items, error];
  FavoritesState copyWith({
    RequestStatus? status,
    List<ProductModel>? items,
    String? error,
  }) =>
      FavoritesState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}
