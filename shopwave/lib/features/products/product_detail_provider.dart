import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopwave/core/constants.dart';
import 'package:shopwave/core/dio_client.dart';
import 'package:shopwave/models/product.dart';

final productDetailProvider = FutureProvider.autoDispose.family<Product, int>((
  ref,
  id,
) async {
  final dio = ref.watch(authenticatedDioProvider);
  final response = await dio.get('${AppConstants.productRoute}/$id');
  return Product.fromJson(response.data as Map<String, dynamic>);
});
