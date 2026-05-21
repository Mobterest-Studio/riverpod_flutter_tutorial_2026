import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:shopwave_backend_server/src/generated/product.dart';

const _idParam = IntPathParam(#id);

class ProductsRoute extends Route {
  ProductsRoute() : super(methods: {Method.get});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final products = await Product.db.find(session);

    return Response.ok(
      body: Body.fromString(
        jsonEncode(products.map((p) => p.toJson()).toList()),
        mimeType: MimeType.json,
      ),
    );
  }
}

class ProductRoute extends Route {
  ProductRoute() : super(methods: {Method.get}, path: '/:id');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final int id;
    try {
      id = request.pathParameters.get(_idParam);
    } catch (_) {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid product id'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final product = await Product.db.findById(session, id);

    if (product == null) {
      return Response.notFound(
        body: Body.fromString(
          jsonEncode({'error': 'Product not found'}),
          mimeType: MimeType.json,
        ),
      );
    }

    return Response.ok(
      body: Body.fromString(
        jsonEncode(product.toJson()),
        mimeType: MimeType.json,
      ),
    );
  }
}
