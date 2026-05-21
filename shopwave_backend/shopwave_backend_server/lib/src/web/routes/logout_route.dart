import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthServices;

class LogoutRoute extends Route {
  LogoutRoute() : super(methods: {Method.post});

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final authHeader = request.headers.authorization;

    if (authHeader is! BearerAuthorizationHeader) {
      return Response.unauthorized(
        body: Body.fromString(
          jsonEncode({'error': 'Missing or invalid Authorization header'}),
          mimeType: MimeType.json,
        ),
      );
    }

    final authInfo = await AuthServices.instance.tokenManager.validateToken(
      session,
      authHeader.token,
    );

    if (authInfo == null) {
      return Response.unauthorized(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid or expired token'}),
          mimeType: MimeType.json,
        ),
      );
    }

    await AuthServices.instance.tokenManager.revokeToken(
      session,
      tokenId: authInfo.authId,
    );

    return Response.ok(
      body: Body.fromString(
        jsonEncode({'message': 'Logged out successfully'}),
        mimeType: MimeType.json,
      ),
    );
  }
}
