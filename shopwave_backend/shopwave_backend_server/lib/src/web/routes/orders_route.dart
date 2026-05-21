import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart' hide Order;
import 'package:serverpod_auth_idp_server/core.dart' show AuthServices;
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:shopwave_backend_server/src/generated/order.dart';
import 'package:shopwave_backend_server/src/generated/order_item.dart';
import 'package:shopwave_backend_server/src/generated/order_status.dart';
import 'package:shopwave_backend_server/src/generated/user.dart';

const _idParam = IntPathParam(#id);

class OrdersRoute extends Route {
  OrdersRoute() : super(methods: {Method.get, Method.post});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final user = await _resolveUser(session, request);
    if (user == null) {
      return Response.unauthorized(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid or missing token'}),
          mimeType: MimeType.json,
        ),
      );
    }

    if (request.method == Method.get) {
      return _getOrders(session, user);
    }
    return _createOrder(session, request, user);
  }

  Future<Result> _getOrders(Session session, User user) async {
    final orders = await Order.db.find(
      session,
      where: (t) => t.userId.equals(user.id!),
    );

    final orderJsonList = await Future.wait(orders.map((order) async {
      final items = (await Future.wait(
        order.items.map((id) => OrderItem.db.findById(session, id)),
      )).whereType<OrderItem>().toList();

      return {
        'id': order.id,
        'status': order.status.name,
        'items': items.map((i) => i.toJson()).toList(),
        'total': order.total,
        'createdAt': order.createdAt.toIso8601String(),
      };
    }));

    return Response.ok(
      body: Body.fromString(
        jsonEncode(orderJsonList),
        mimeType: MimeType.json,
      ),
    );
  }

  Future<Result> _createOrder(
    Session session,
    Request request,
    User user,
  ) async {
    final String bodyText;
    try {
      bodyText = await request.readAsString();
    } catch (_) {
      return Response.badRequest(
        body: Body.fromString('Could not read request body'),
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(bodyText) as Map<String, dynamic>;
    } catch (_) {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid JSON body'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final rawItems = json['items'] as List?;
    final total = (json['total'] as num?)?.toDouble();

    if (rawItems == null || rawItems.isEmpty || total == null) {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'items and total are required'}),
          mimeType: MimeType.json,
        ),
      );
    }

    try {
      final orderItems = await OrderItem.db.insert(
        session,
        rawItems.map((item) {
          final i = item as Map<String, dynamic>;
          return OrderItem(
            productIdId: i['productId'] as int,
            productName: i['productName'] as String,
            quantity: i['quantity'] as int,
            priceAtPurchase: (i['priceAtPurchase'] as num).toDouble(),
          );
        }).toList(),
      );

      final order = await Order.db.insertRow(
        session,
        Order(
          userId: user.id!,
          status: OrderStatus.pending,
          items: orderItems.map((i) => i.id!).toList(),
          total: total,
          createdAt: DateTime.now().toUtc(),
        ),
      );

      return Response.ok(
        body: Body.fromString(
          jsonEncode({
            'id': order.id,
            'status': order.status.name,
            'items': orderItems.map((i) => i.toJson()).toList(),
            'total': order.total,
            'createdAt': order.createdAt.toIso8601String(),
          }),
          mimeType: MimeType.json,
        ),
      );
    } catch (_) {
      return Response.internalServerError();
    }
  }
}

class OrderRoute extends Route {
  OrderRoute() : super(methods: {Method.get}, path: '/:id');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final user = await _resolveUser(session, request);
    if (user == null) {
      return Response.unauthorized(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid or missing token'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final int id;
    try {
      id = request.pathParameters.get(_idParam);
    } catch (_) {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid order id'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final order = await Order.db.findFirstRow(
      session,
      where: (t) => t.id.equals(id) & t.userId.equals(user.id!),
    );

    if (order == null) {
      return Response.notFound(
        body: Body.fromString(
          jsonEncode({'error': 'Order not found'}),
          mimeType: MimeType.json,
        ),
      );
    }

    return Response.ok(
      body: Body.fromString(
        jsonEncode(order.toJson()),
        mimeType: MimeType.json,
      ),
    );
  }
}

/// Resolves the authenticated [User] from the Bearer token in the request.
/// Returns null if the token is missing, invalid, or no matching user exists.
Future<User?> _resolveUser(Session session, Request request) async {
  final authHeader = request.headers.authorization;
  if (authHeader is! BearerAuthorizationHeader) return null;

  final authInfo = await AuthServices.instance.tokenManager.validateToken(
    session,
    authHeader.token,
  );
  if (authInfo == null) return null;

  final emailAccount = await EmailAccount.db.findFirstRow(
    session,
    where: (t) => t.authUserId.equals(
      UuidValue.fromString(authInfo.userIdentifier),
    ),
  );
  if (emailAccount == null) return null;

  return User.db.findFirstRow(
    session,
    where: (t) => t.email.equals(emailAccount.email),
  );
}
