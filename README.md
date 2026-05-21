# ShopWave — Flutter + Riverpod Tutorial Series

> Build a complete, production-quality e-commerce app from scratch.
> 12 lessons · Feature-first architecture · Serverpod REST backend

---

## What Is This?

ShopWave is a fully functional Flutter e-commerce application built across a structured 12-lesson video tutorial series. Every lesson adds one feature or concept — nothing is skipped, nothing is assumed. By the end, you have a working app and the architectural intuition to design your own.

The series teaches **how to design with Riverpod**, not just how to use it. That distinction — between reaching for a tool and knowing when and why to reach for it — is the real goal.

---

## The App

ShopWave covers the complete e-commerce loop:

```
Browse products → View detail → Add to cart → Checkout → Order confirmed → Order history
```

| Feature | What it demonstrates |
|---|---|
| Authentication | Sealed state, token persistence, session restore on startup |
| Product catalogue | AsyncNotifierProvider, AsyncValue.when(), pull-to-refresh |
| Product detail | .family + .autoDispose, path parameters, per-ID caching |
| Shopping cart | Immutable NotifierProvider, derived providers, select() |
| Checkout | Provider composition, orderSummaryProvider, placeOrder() |
| Order history | AsyncNotifier read + write in one Notifier |
| Error handling | Dio interceptors, AppError sealed class, global snackbar |
| Testing | ProviderContainer, mock overrides, unit tests |

---

## Tech Stack

| Package | Role |
|---|---|
| `flutter_riverpod` 2.x | State management |
| `dio` | HTTP client |
| `go_router` | Navigation + route protection |
| `shared_preferences` | Token persistence |
| `cached_network_image` | Async image loading |
| `shimmer` | Skeleton loading states |
| Serverpod | REST backend (POST /login, GET /products, POST /orders …) |

---

## The 12 Lessons

### Foundation (Lessons 01–04)

**Lesson 01 — What Is State?**
The three types of state, why global state exists, and what problem Riverpod solves. Concept-only — no code.

**Lesson 02 — Project Setup & First Provider**
Scaffold the ShopWave project. Feature-first folder structure. `dioProvider`, `AppConstants`, and the first `ref.watch` call.

**Lesson 03 — Provider Types: The Full Map**
All five provider types explained with visual decision trees. `AsyncValue`, `autoDispose`, `family`, and where each fits in the ShopWave architecture.

**Lesson 04 — ref Deep Dive**
`ref.watch` vs `ref.read` vs `ref.listen` — the most important distinction in Riverpod. When each belongs in `build()` vs action methods. `ref.invalidate` and `ref.refresh`.

---

### Features (Lessons 05–10)

**Lesson 05 — Authentication**
`AuthState` sealed class with four compile-safe variants. `AuthNotifier` with `login()`, `logout()`, and startup session restore. `shared_preferences` token persistence. `LoginScreen` using all three ref patterns. go_router route protection with auth redirect.

**Lesson 06 — Products**
`ProductsNotifier` using `AsyncNotifierProvider`. `build()` fetches `GET /products` via `authenticatedDioProvider`. `AsyncValue.when()` for loading/error/data states. Pull-to-refresh with `ref.invalidate`. `ProductCard` with `CachedNetworkImage`.

**Lesson 07 — Product Detail**
The `.family` modifier — one declaration, unlimited parameterised instances. `.autoDispose` for per-navigation cleanup. `productDetailProvider(int id)` with `AutoDisposeAsyncNotifier`. Path parameters in go_router. `ProductDetailScreen` wired end-to-end.

**Lesson 08 — The Cart**
`CartItem` with `copyWith` and immutable fields. `CartNotifier` — `addItem`, `removeItem`, `updateQuantity`, `clear` — all producing new lists via spread/map/where. `cartCountProvider` with `select()` for fine-grained badge updates. `CartScreen` with quantity controls and grand total.

**Lesson 09 — Provider Composition**
The complete ShopWave dependency graph made explicit. How one login event cascades through 11 providers automatically. `ref.watch` in `build()` as a dependency declaration, not a getter. `orderSummaryProvider` combining cart + auth. `isCheckoutReadyProvider`. Testability via `ProviderContainer` overrides.

**Lesson 10 — Orders**
`Order` model with `OrderStatus` enum and price snapshots. `OrderNotifier` with `build()` for history and `placeOrder()` as an action method. `AsyncValue.guard()` wrapping POST /orders. Cart invalidation on success. `CheckoutScreen`, `OrderSuccessScreen`, `OrderHistoryScreen`.

---

### Polish (Lessons 11–12)

**Lesson 11 — Error Handling & UX Polish**
`ErrorInterceptor` classifying every `DioException` into a typed `AppError`. Sealed `AppError` variants with `userMessage`. Global error snackbar via root-level `ref.listen`. `ProductCardSkeleton` shimmer replacing spinners. Automatic logout on 401. Retry with exponential backoff for 5xx.

**Lesson 12 — Architecture Review & Testing**
Full codebase review — what worked, what has costs, honest assessment. Unit tests for `CartNotifier` (no overrides), `ProductsNotifier` (MockDio + FakeAuth), and error paths. The test pyramid for ShopWave. `riverpod_generator` preview. The five principles worth keeping. Graduation.

---

## The Provider Graph

```
TIER 0 — INFRASTRUCTURE (no dependencies)
  dioProvider                   Provider<Dio>
  authProvider                  NotifierProvider<AuthNotifier, AuthState>
  cartProvider                  NotifierProvider<CartNotifier, List<CartItem>>

TIER 1 — AUTH BRIDGE (watches dio + auth)
  authenticatedDioProvider      Provider<Dio>

TIER 2 — BUSINESS LOGIC (watch authenticatedDio)
  productsProvider              AsyncNotifierProvider<ProductsNotifier, List<Product>>
  orderProvider                 AsyncNotifierProvider<OrderNotifier, List<Order>>
  productDetailProvider         AsyncNotifierProvider.autoDispose.family<..., Product, int>

TIER 2b — CROSS-CONCERNS (watch auth + cart)
  orderSummaryProvider          Provider<OrderSummary>
  isCheckoutReadyProvider       Provider<bool>

TIER 3 — DERIVED (watch single upstream)
  cartCountProvider             Provider<int>
  cartTotalProvider             Provider<double>
```

Dependencies flow in one direction — top to bottom. Circular dependencies are always a design signal, never a Riverpod limitation.

---

## Folder Structure

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
│   │   ├── auth_state.dart         # sealed AuthState
│   │   ├── auth_provider.dart      # AuthNotifier + authProvider
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
└── main.dart                   # ProviderScope + global error listener
```

---

## Five Principles Worth Keeping

These apply to every Riverpod project, not just ShopWave.

1. **`ref.watch` in `build()` · `ref.read` in methods** — watch creates a live dependency; read takes a one-time snapshot. Mixing them is the most common source of subtle bugs.

2. **Always assign a new list, never mutate** — Riverpod uses `==` equality to detect state changes. A mutated list is the same object — Riverpod sees no change, widgets don't rebuild.

3. **Dependencies flow in one direction** — infrastructure provides to business logic, business logic provides to derived. Circular dependencies cause `ProviderException` and always indicate a missing third provider.

4. **Each provider owns one concern** — `authenticatedDioProvider` knows about auth. `CartNotifier` knows about cart state. Neither knows about the other. Single responsibility is what makes the graph composable.

5. **Errors should be structured, not raw** — `AppError.userMessage` is what users read. `SocketException: Failed host lookup` is what developers debug. Don't confuse the two audiences.

---

## Running the Project

```bash
# Clone the repo
git clone https://github.com/your-org/shopwave.git
cd shopwave

# Install dependencies
flutter pub get

# Start Serverpod backend (requires Docker)
cd backend
dart bin/main.dart

# Run the Flutter app
cd ../
flutter run
```

> Each lesson has its own branch — `lesson/01-what-is-state` through `lesson/12-review-and-testing` — so you can check out any point in the build.

```bash
# Jump to a specific lesson
git checkout lesson/05-authentication
```

---

## What Each Lesson Produces

| Lesson | Branch | Key files added |
|---|---|---|
| 01 | `lesson/01-what-is-state` | Project scaffold only |
| 02 | `lesson/02-project-setup` | `dio_client.dart`, `constants.dart`, `home_screen.dart` |
| 03 | `lesson/03-provider-types` | Concept — no new files |
| 04 | `lesson/04-ref-deep-dive` | Concept — no new files |
| 05 | `lesson/05-authentication` | `auth_state.dart`, `auth_provider.dart`, `login_screen.dart`, `router.dart` |
| 06 | `lesson/06-products` | `product.dart`, `products_provider.dart`, `products_screen.dart`, `product_card.dart` |
| 07 | `lesson/07-product-detail` | `product_detail_provider.dart`, `product_detail_screen.dart` |
| 08 | `lesson/08-cart` | `cart_item.dart`, `cart_provider.dart`, `cart_screen.dart` |
| 09 | `lesson/09-composition` | `order_summary_provider.dart` |
| 10 | `lesson/10-orders` | `order.dart`, `order_provider.dart`, `checkout_screen.dart`, `order_success_screen.dart`, `order_history_screen.dart` |
| 11 | `lesson/11-error-handling` | `app_error.dart`, `error_interceptor.dart`, `product_card_skeleton.dart` |
| 12 | `lesson/12-review-testing` | `test/` directory |

---

## Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/features/cart/cart_notifier_test.dart
```

Tests use `ProviderContainer` with overrides — no real network calls, no emulators required. `CartNotifier` tests need zero overrides. `ProductsNotifier` tests use `MockDio` and `FakeAuthNotifier`.

---

## Serverpod API Reference

| Method | Endpoint | Auth required | Used in |
|---|---|---|---|
| POST | `/login` | No | Lesson 05 |
| GET | `/me` | Yes | Lesson 05 (session restore) |
| GET | `/products` | Yes | Lesson 06 |
| GET | `/products/:id` | Yes | Lesson 07 |
| POST | `/orders` | Yes | Lesson 10 |
| GET | `/orders` | Yes | Lesson 10 |

---

## Questions & Issues

Questions about a specific lesson — drop them in the comments of that video.
Bugs in the code — open an issue on GitHub with the lesson number and the line in question.

---

*Built lesson by lesson. Designed to be understood, not just copied.*
