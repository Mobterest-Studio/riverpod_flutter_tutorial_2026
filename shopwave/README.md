# ShopWave

A production-quality Flutter e-commerce app built with Riverpod, Dio, and go_router.
This is the Flutter client from the **12-lesson ShopWave tutorial series** — see the [root README](../README.md) for the full course overview.

---

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.x (stable) |
| Dart SDK | `^3.11.5` |
| Serverpod backend | Running on `localhost:8080` |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app (with a connected device or emulator)
flutter run
```

The backend must be running before the app starts — authentication and all data calls require it.
See [`shopwave_backend/`](../shopwave_backend/) for backend setup instructions.

---

## Dependencies

| Package | Version | Role |
|---|---|---|
| `flutter_riverpod` | `^3.3.1` | State management |
| `dio` | `^5.9.2` | HTTP client with interceptors |
| `go_router` | `^17.2.3` | Declarative navigation + auth redirect |
| `shared_preferences` | `^2.5.5` | Token persistence across sessions |
| `cached_network_image` | `^3.4.1` | Async image loading with disk cache |
| `shimmer` | `^3.0.0` | Skeleton loading states |
| `google_fonts` | `^8.1.0` | JetBrains Mono text theme |
| `intl` | `^0.20.2` | Currency and date formatting |
| `mockito` | `^5.6.4` | Test doubles for providers |

---

## Project Structure

```
lib/
├── core/
│   ├── constants.dart          # AppConstants — base URL, route keys, pref keys
│   ├── dio_client.dart         # dioProvider + authenticatedDioProvider
│   ├── error_interceptor.dart  # ErrorInterceptor + RetryInterceptor
│   └── app_error.dart          # AppError sealed class
│
├── models/
│   ├── user.dart
│   ├── product.dart
│   ├── cart_item.dart
│   └── order.dart
│
├── features/
│   ├── auth/
│   │   ├── auth_state.dart         # Sealed AuthState variants
│   │   ├── auth_provider.dart      # AuthNotifier — login, logout, session restore
│   │   └── login_screen.dart
│   │
│   ├── products/
│   │   ├── products_provider.dart
│   │   ├── products_screen.dart
│   │   ├── product_card.dart
│   │   ├── product_card_skeleton.dart
│   │   ├── product_detail_provider.dart
│   │   └── product_detail_screen.dart
│   │
│   ├── cart/
│   │   ├── cart_provider.dart      # CartNotifier + cartCountProvider + cartTotalProvider
│   │   └── cart_screen.dart
│   │
│   └── orders/
│       ├── order_summary_provider.dart  # orderSummaryProvider + isCheckoutReadyProvider
│       ├── order_provider.dart
│       ├── checkout_screen.dart
│       ├── order_success_screen.dart
│       └── order_history_screen.dart
│
├── router.dart                 # GoRouter + auth redirect + _AuthChangeNotifier
└── main.dart                   # ProviderScope + global error listener + dioProvider
```

---

## Running Tests

```bash
# Run all tests
flutter test

# Run a specific file
flutter test test/features/products/products_provider_test.dart
```

Tests use `ProviderContainer` with overrides — no real network calls, no emulators needed.

---

## Theme

Material 3 · Green color seed · JetBrains Mono text theme
