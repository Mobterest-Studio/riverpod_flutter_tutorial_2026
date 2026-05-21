import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopwave/core/dio_client.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dio = ref.watch(dioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ShopWave')),
      body: Center(
        child: Column(
          children: [
            const Text('Riverpod is working!'),
            const SizedBox(height: 8),
            Text(
              'API: ${dio.options.baseUrl}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
