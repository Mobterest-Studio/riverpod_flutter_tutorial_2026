// lib/features/orders/order_summary_provider.dart — new file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_state.dart';
import '../cart/cart_provider.dart';
import '../../models/cart_item.dart';

class OrderSummary {
  final String userName;
  final String userEmail;
  final List<CartItem> items;
  final double total;
  final int itemCount;

  const OrderSummary({
    required this.userName,
    required this.userEmail,
    required this.items,
    required this.total,
    required this.itemCount,
  });

  bool get isReady => items.isNotEmpty;

  @override
  String toString() =>
      'OrderSummary(user: $userName, items: ${items.length}, total: $total)';
}

final orderSummaryProvider = Provider<OrderSummary>((ref) {
  final cartItems = ref.watch(cartProvider);
  final authState = ref.watch(authProvider);

  final user = authState is AuthStateAuthenticated ? authState.user : null;

  return OrderSummary(
    userName: user?.name ?? 'Guest',
    userEmail: user?.email ?? '',
    items: cartItems,
    total: cartItems.fold(0.0, (sum, item) => sum + item.subTotal),
    itemCount: cartItems.fold(0, (sum, item) => sum + item.quantity),
  );
});

final isCheckoutReadyProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  final cartCount = ref.watch(cartCountProvider);

  return authState is AuthStateAuthenticated && cartCount > 0;
});
