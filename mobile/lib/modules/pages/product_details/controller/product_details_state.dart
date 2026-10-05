part of 'product_details_cubit.dart';

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = RequestStatus.init,
    this.productId = '',
    this.product,
    this.error = '',
    this.quantity = 1,
    this.selectedSize,
    this.reviews = const ReviewsPayload(),
  });
  final RequestStatus status;
  final String productId;
  final ProductModel? product;
  final String error;
  final int quantity;
  final String? selectedSize;
  final ReviewsPayload reviews;
  @override
  List<Object?> get props => [status, productId, product, error, quantity, selectedSize, reviews];
  ProductDetailsState copyWith({
    RequestStatus? status,
    String? productId,
    ProductModel? product,
    String? error,
    int? quantity,
    String? selectedSize,
    ReviewsPayload? reviews,
  }) =>
      ProductDetailsState(
        status: status ?? this.status,
        productId: productId ?? this.productId,
        product: product ?? this.product,
        error: error ?? this.error,
        quantity: quantity ?? this.quantity,
        selectedSize: selectedSize ?? this.selectedSize,
        reviews: reviews ?? this.reviews,
      );
}
