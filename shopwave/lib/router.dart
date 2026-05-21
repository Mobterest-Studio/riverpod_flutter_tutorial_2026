import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shopwave/features/auth/auth_provider.dart';
import 'package:shopwave/features/auth/auth_state.dart';
import 'package:shopwave/features/auth/login_screen.dart';
import 'package:shopwave/features/cart/cart_screen.dart';
import 'package:shopwave/features/orders/checkout_screen.dart';
import 'package:shopwave/features/orders/order_history_screen.dart';
import 'package:shopwave/features/orders/order_success_screen.dart';
import 'package:shopwave/features/products/products_screen.dart';
import 'package:shopwave/features/products/product_detail_screen.dart';
import 'package:shopwave/features/profile/profile_screen.dart';

//routes that don't require authentication
final _publicRoutes = ['/login'];

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isPublicRoute = _publicRoutes.contains(state.matchedLocation);
      if (authState is! AuthStateAuthenticated) {
        return isPublicRoute ? null : '/login';
      }
      if (isPublicRoute) return '/products';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final productId = int.tryParse(idString ?? '');

          return ProductDetailScreen(productId: productId ?? 0);
        },
      ),

      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),

      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      GoRoute(
        path: '/order-success/:id',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderSuccessScreen(orderId: orderId);
        },
      ),

      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}
