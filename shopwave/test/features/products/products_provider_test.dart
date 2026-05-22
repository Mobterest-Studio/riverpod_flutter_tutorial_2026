import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shopwave/core/dio_client.dart';
import 'package:shopwave/features/auth/auth_provider.dart';
import 'package:shopwave/features/auth/auth_state.dart';
import 'package:shopwave/features/cart/cart_provider.dart';
import 'package:shopwave/features/products/products_provider.dart';
import 'package:shopwave/models/product.dart';
import 'package:shopwave/models/user.dart';

// A simplified test showing the override pattern
void main() {
  group('ProductsNotifier', () {
    late ProviderContainer container;
    late FakeDio fakeDio;

    setUp(() {
      fakeDio = FakeDio();

      container = ProviderContainer(
        overrides: [
          // Override the base Dio with a fake
          dioProvider.overrideWithValue(fakeDio),

          // Override auth to return an authenticated state
          authProvider.overrideWith(() => FakeAuthNotifier()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('loads products from server', () async {
      // Arrange: stub fake Dio to return test data
      fakeDio.stubGet(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/products'),
          data: [
            {
              'id': '1',
              'name': 'Test Product',
              'price': 29.99,
              'description': 'Test',
              'image_url': '',
              'category': 'Test',
            },
          ],
          statusCode: 200,
        ),
      );

      // Act: read the provider (triggers build())
      final products = await container.read(productsProvider.future);

      // Assert: real parsing logic ran on fake data
      expect(products.length, equals(1));
      expect(products.first.name, equals('Test Product'));
      expect(products.first.price, equals(29.99));
    });

    test('handles network error', () async {
      fakeDio.stubGet(
        (_) => throw DioException(
          requestOptions: RequestOptions(path: '/products'),
        ),
      );

      // The provider should transition to AsyncError
      final result = await container
          .read(productsProvider.future)
          .then((_) => 'data')
          .catchError((_) => 'error');

      expect(result, equals('error'));
    });
  });
}

// Hand-written fake avoids Mockito's null-safety issue where unstubbed
// non-nullable return types crash during when() setup.
class FakeDio implements Dio {
  // authenticatedDioProvider reads dio.options.headers to set the auth token
  @override
  BaseOptions options = BaseOptions();

  late Future<Response<dynamic>> Function(String path) _onGet;

  void stubGet(Future<Response<dynamic>> Function(String path) handler) {
    _onGet = handler;
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async => (await _onGet(path)) as Response<T>;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    '${invocation.memberName} not stubbed in FakeDio',
  );
}

const testProduct = Product(
  id: '1',
  name: 'Test Product',
  description: 'A test product',
  price: 29.99,
  imageUrl: '',
  category: 'Test',
);

// ── FakeAuthNotifier for testing ─────────────────────────────
class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    // Return a pre-authenticated state for tests
    return AuthStateAuthenticated(
      User(
        id: 'test-user',
        name: 'Test User',
        email: 'test@example.com',
        token: 'fake-test-token',
      ),
    );
  }
}

// ── CartNotifier tests (no network needed) ───────────────────
void cartTests() {
  group('CartNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(); // no overrides needed — no deps
    });

    tearDown(() => container.dispose());

    test('starts empty', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('addItem adds to cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(testProduct);

      final cart = container.read(cartProvider);
      expect(cart.length, equals(1));
      expect(cart.first.product.id, equals(testProduct.id));
      expect(cart.first.quantity, equals(1));
    });

    test('addItem increments quantity for duplicate', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(testProduct);
      notifier.addItem(testProduct); // same product again

      final cart = container.read(cartProvider);
      expect(cart.length, equals(1)); // still one line item
      expect(cart.first.quantity, equals(2)); // quantity incremented
    });

    test('clear empties cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(testProduct);
      notifier.clear();

      expect(container.read(cartProvider), isEmpty);
    });
  });
}
