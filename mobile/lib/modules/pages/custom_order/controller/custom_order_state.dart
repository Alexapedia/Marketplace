part of 'custom_order_cubit.dart';

class CustomOrderState extends Equatable {
  const CustomOrderState({
    this.status = RequestStatus.init,
    this.submitStatus = RequestStatus.init,
    this.categories = const [],
    this.fields = const [],
    this.categoryId = '',
    this.images = const [],
    this.error = '',
  });
  final RequestStatus status;
  final RequestStatus submitStatus;
  final List<CategoryModel> categories;
  final List<CustomFieldModel> fields;
  final String categoryId;
  final List<String> images;
  final String error;
  @override
  List<Object> get props =>
      [status, submitStatus, categories, fields, categoryId, images, error];
  CustomOrderState copyWith({
    RequestStatus? status,
    RequestStatus? submitStatus,
    List<CategoryModel>? categories,
    List<CustomFieldModel>? fields,
    String? categoryId,
    List<String>? images,
    String? error,
  }) =>
      CustomOrderState(
        status: status ?? this.status,
        submitStatus: submitStatus ?? this.submitStatus,
        categories: categories ?? this.categories,
        fields: fields ?? this.fields,
        categoryId: categoryId ?? this.categoryId,
        images: images ?? this.images,
        error: error ?? this.error,
      );
}

class CustomOrderDetailsState extends Equatable {
  const CustomOrderDetailsState({
    this.status = RequestStatus.init,
    this.order,
    this.error = '',
  });
  final RequestStatus status;
  final CustomOrderModel? order;
  final String error;
  @override
  List<Object?> get props => [status, order, error];
  CustomOrderDetailsState copyWith({
    RequestStatus? status,
    CustomOrderModel? order,
    String? error,
  }) =>
      CustomOrderDetailsState(
        status: status ?? this.status,
        order: order ?? this.order,
        error: error ?? this.error,
      );
}
