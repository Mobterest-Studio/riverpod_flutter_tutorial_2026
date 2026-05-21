import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopwave/core/constants.dart';
import 'package:shopwave/core/dio_client.dart';
import 'package:shopwave/models/product.dart';

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final dio = ref.watch(authenticatedDioProvider);

    final response = await dio.get(AppConstants.productRoute);

    final data = response.data as List<dynamic>;

    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);
