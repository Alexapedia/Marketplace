part of 'custom_order_cubit.dart';

class CustomOrderState extends Equatable {
  const CustomOrderState({
    this.status = RequestStatus.init,
    this.submitStatus = RequestStatus.init,
    this.categories = const [],
    this.fields = const [],
    this.categoryId = '',
    this.images = const [],
    this.answers = const {},
    this.error = '',
  });
  final RequestStatus status;
  final RequestStatus submitStatus;
  final List<CategoryModel> categories;
  final List<CustomFieldModel> fields;
  final String categoryId;
  final List<String> images;
  final Map<String, dynamic> answers;
  final String error;

  @override
  List<Object> get props => [
        status,
        submitStatus,
        categories,
        fields,
        categoryId,
        images,
        answers,
        error,
      ];

  CustomOrderState copyWith({
    RequestStatus? status,
    RequestStatus? submitStatus,
    List<CategoryModel>? categories,
    List<CustomFieldModel>? fields,
    String? categoryId,
    List<String>? images,
    Map<String, dynamic>? answers,
    String? error,
  }) =>
      CustomOrderState(
        status: status ?? this.status,
        submitStatus: submitStatus ?? this.submitStatus,
        categories: categories ?? this.categories,
        fields: fields ?? this.fields,
        categoryId: categoryId ?? this.categoryId,
        images: images ?? this.images,
        answers: answers ?? this.answers,
        error: error ?? this.error,
      );
}

