import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthServices;
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:shopwave_backend_server/src/generated/user.dart';

class LoginRoute extends Route {
  LoginRoute() : super(methods: {Method.post});

  @override
  Future<Result> handleCall(Session session, Request request) async {
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

    final email = json['email'] as String?;
    final password = json['password'] as String?;

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'email and password are required'}),
          mimeType: MimeType.json,
        ),
      );
    }

    try {
      final authSuccess = await AuthServices.instance.emailIdp.login(
        session,
        email: email,
        password: password,
      );

      final user = await User.db.findFirstRow(
        session,
        where: (t) => t.email.equals(email),
      );

      if (user == null) {
        return Response.unauthorized(
          body: Body.fromString(
            jsonEncode({'error': 'User not found'}),
            mimeType: MimeType.json,
          ),
        );
      }

      return Response.ok(
        body: Body.fromString(
          jsonEncode({
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'token': authSuccess.token,
          }),
          mimeType: MimeType.json,
        ),
      );
    } on EmailAccountLoginException catch (e) {
      return Response.unauthorized(
        body: Body.fromString(
          jsonEncode({'error': e.reason.name}),
          mimeType: MimeType.json,
        ),
      );
    } catch (_) {
      return Response.internalServerError();
    }
  }
}