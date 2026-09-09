part of 'cart_cubit.dart';

class CartState extends Equatable {
  const CartState({
    this.status = RequestStatus.init,
    this.cart = const CartModel(),
    this.error = '',
  });
  final RequestStatus status;
  final CartModel cart;
  final String error;
  @override
  List<Object> get props => [status, cart, error];
  CartState copyWith({
    RequestStatus? status,
    CartModel? cart,
    String? error,
  }) =>
      CartState(
        status: status ?? this.status,
        cart: cart ?? this.cart,
        error: error ?? this.error,
      );
}
