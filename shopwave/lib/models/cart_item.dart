import 'package:shopwave/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith(int? quantity) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  double get subTotal => product.price * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          product.id == other.product.id &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(product.id, quantity);

  @override
  String toString() =>
      'CartItem(product: ${product.name}, quantity: $quantity, subtotal: $subTotal )';
}
