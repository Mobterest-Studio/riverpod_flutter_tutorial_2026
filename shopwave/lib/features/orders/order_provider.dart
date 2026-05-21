// lib/features/orders/order_provider.dart — complete file

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopwave/features/orders/order_summary_provider.dart';
import '../../core/constants.dart';
import '../../core/dio_client.dart';
import '../../models/order.dart';
import '../cart/cart_provider.dart';

class OrderNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final dio = ref.watch(authenticatedDioProvider);
    final response = await dio.get(AppConstants.orderRoute);
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Order> placeOrder(OrderSummary summary) async {
    final previousOrders = state.asData?.value ?? [];
    state = const AsyncLoading();

    final payload = {
      'items': summary.items
          .map(
            (item) => {
              'productId': int.parse(item.product.id),
              'productName': item.product.name,
              'quantity': item.quantity,
              'priceAtPurchase': item.product.price,
            },
          )
          .toList(),
      'total': summary.total,
    };

    final dio = ref.read(authenticatedDioProvider);
    late Order newOrder;

    state = await AsyncValue.guard(() async {
      final response = await dio.post(AppConstants.orderRoute, data: payload);
      newOrder = Order.fromJson(response.data as Map<String, dynamic>);
      ref.invalidate(cartProvider);
      return [newOrder, ...previousOrders];
    });

    if (state.hasError) throw state.error!;
    return newOrder;
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<Order>>(
  OrderNotifier.new,
);
