// lib/features/orders/checkout_screen.dart — full file

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopwave/features/orders/order_summary_provider.dart';

import '../../models/order.dart';
import 'order_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Data sources ──────────────────────────────────────────
    final summary = ref.watch(orderSummaryProvider);
    final isReady = ref.watch(isCheckoutReadyProvider);
    final orderState = ref.watch(orderProvider);
    final isLoading = orderState.isLoading;

    // ── Side effects: navigation and error snackbar ───────────
    ref.listen<AsyncValue<List<Order>>>(orderProvider, (previous, next) {
      // Detect transition from loading to data (new order placed)
      if (previous?.isLoading == true && next.hasValue) {
        final orders = next.value!;
        if (orders.isNotEmpty) {
          // Navigate to success screen with the newest order's id
          context.push('/order-success/${orders.first.id}');
        }
      }

      // Show snackbar on error
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${next.error}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── User greeting ─────────────────────────
                  Text(
                    'Hi, ${summary.userName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review your order before confirming.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // ── Order items ───────────────────────────
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            '${summary.itemCount} items in your order',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Divider(height: 1),

                        // Item rows
                        ...summary.items.map(
                          (item) => ListTile(
                            dense: true,
                            title: Text(item.product.name),
                            subtitle: Text('×${item.quantity}'),
                            trailing: Text(
                              '\$${item.subTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const Divider(height: 1),

                        // Total row
                        ListTile(
                          title: const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            '\$${summary.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Place Order button ────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.6),
                ),
                onPressed: isLoading || !isReady
                    ? null // disabled while loading or cart empty
                    : () =>
                          ref.read(orderProvider.notifier).placeOrder(summary),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Place Order — \$${summary.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
