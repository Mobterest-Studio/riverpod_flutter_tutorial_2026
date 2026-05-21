import 'dart:async';
import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthServices;
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:shopwave_backend_server/src/generated/user.dart';

class SignUpRoute extends Route {
  SignUpRoute() : super(methods: {Method.post});

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

    final name = json['name'] as String?;
    final email = json['email'] as String?;
    final password = json['password'] as String?;

    if (name == null ||
        name.isEmpty ||
        email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'name, email and password are required'}),
          mimeType: MimeType.json,
        ),
      );
    }

    try {
      final authUser = await AuthServices.instance.authUsers.create(session);

      await AuthServices.instance.emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: authUser.id,
        email: email,
        password: password,
      );

      final user = await User.db.insertRow(
        session,
        User(name: name, email: email),
      );

      final authSuccess = await AuthServices.instance.emailIdp.login(
        session,
        email: email,
        password: password,
      );

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
    } on EmailAccountAlreadyRegisteredException {
      return Response(
        409,
        body: Body.fromString(
          jsonEncode({'error': 'Email already registered'}),
          mimeType: MimeType.json,
        ),
      );
    } on EmailAccountRequestInvalidEmailException {
      return Response.badRequest(
        body: Body.fromString(
          jsonEncode({'error': 'Invalid email address'}),
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
