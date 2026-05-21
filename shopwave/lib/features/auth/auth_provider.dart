// lib/features/auth/auth_provider.dart — complete file

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopwave/features/cart/cart_provider.dart';

import '../../core/constants.dart';
import '../../core/dio_client.dart';
import '../../models/user.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthStateInitial();
  }

  // ── Startup: restore session from saved token ─────────────
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(AppConstants.tokenKey);
    if (savedToken == null) return;

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        AppConstants.profileRoute,
        options: Options(headers: {'Authorization': 'Bearer $savedToken'}),
      );
      final user = User.fromJson(response.data['user'] as Map<String, dynamic>);
      state = AuthStateAuthenticated(user);
    } catch (_) {
      await _clearSession();
      state = const AuthStateInitial();
    }
  }

  // ── Login ─────────────────────────────────────────────────
  Future<void> login(String email, String password) async {
    state = const AuthStateLoading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        AppConstants.loginRoute,
        data: {'email': email.trim(), 'password': password},
      );
      final user = User.fromJson(response.data as Map<String, dynamic>);
      await _saveSession(user);
      state = AuthStateAuthenticated(user);
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
          _httpErrorMessage(e.response?.statusCode);
      state = AuthStateError(message);
    } catch (_) {
      state = const AuthStateError('An unexpected error occurred.');
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _clearSession();
    ref.invalidate(cartProvider); // uncomment after Lesson 08
    state = const AuthStateInitial();
  }

  // ── Helpers ───────────────────────────────────────────────
  Future<void> _saveSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, user.token);
    await prefs.setString(AppConstants.userIdKey, user.id);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove('user_data');
  }

  String _httpErrorMessage(int? code) => switch (code) {
    401 => 'Incorrect email or password.',
    429 => 'Too many attempts. Please wait.',
    500 => 'Server error. Please try again later.',
    null => 'No internet connection.',
    _ => 'Login failed (error $code).',
  };
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
