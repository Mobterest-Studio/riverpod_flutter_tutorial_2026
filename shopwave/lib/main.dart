import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shopwave/core/app_error.dart';
import 'package:shopwave/core/constants.dart';
import 'package:shopwave/core/error_interceptor.dart';
import 'package:shopwave/router.dart';
import 'features/orders/order_provider.dart';
import 'features/products/products_provider.dart';

void main() {
  runApp(const ProviderScope(child: ShopWaveApp()));
}

class ShopWaveApp extends ConsumerWidget {
  const ShopWaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    _listenForErrors(ref, context);

    return MaterialApp.router(
      title: 'ShopWave',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
      ),
    );
  }

  void _listenForErrors(WidgetRef ref, BuildContext context) {
    ref.listen<AsyncValue<List<dynamic>>>(
      productsProvider,
      (previous, next) => _onError(previous, next, context),
    );

    ref.listen<AsyncValue<List<dynamic>>>(
      orderProvider,
      (previous, next) => _onError(previous, next, context),
    );
  }

  void _onError(
    AsyncValue<dynamic>? previous,
    AsyncValue<dynamic> next,
    BuildContext context,
  ) {
    if (previous?.hasError != true && next.hasError) {
      final error = next.error;
      final message = error is AppError
          ? error.userMessage
          : 'Something went wrong. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFc03838),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(RetryInterceptor(dio: dio));

  dio.interceptors.add(ErrorInterceptor(ref));

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
