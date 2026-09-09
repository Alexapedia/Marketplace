part of 'product_details_cubit.dart';

class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.status = RequestStatus.init,
    this.product,
    this.error = '',
    this.quantity = 1,
    this.selectedSize,
  });
  final RequestStatus status;
  final ProductModel? product;
  final String error;
  final int quantity;
  final String? selectedSize;
  @override
  List<Object?> get props => [status, product, error, quantity, selectedSize];
  ProductDetailsState copyWith({
    RequestStatus? status,
    ProductModel? product,
    String? error,
    int? quantity,
    String? selectedSize,
  }) =>
      ProductDetailsState(
        status: status ?? this.status,
        product: product ?? this.product,
        error: error ?? this.error,
        quantity: quantity ?? this.quantity,
        selectedSize: selectedSize ?? this.selectedSize,
      );
}
