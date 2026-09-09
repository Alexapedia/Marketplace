part of 'categories_cubit.dart';

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = RequestStatus.init,
    this.items = const [],
    this.error = '',
  });
  final RequestStatus status;
  final List<CategoryModel> items;
  final String error;
  @override
  List<Object> get props => [status, items, error];
  CategoriesState copyWith({
    RequestStatus? status,
    List<CategoryModel>? items,
    String? error,
  }) =>
      CategoriesState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );
}
