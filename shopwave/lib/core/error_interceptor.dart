// lib/core/error_interceptor.dart — full file

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/auth_provider.dart';
import 'app_error.dart';

class ErrorInterceptor extends Interceptor {
   final Ref _ref;

  ErrorInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppError appError;

     switch (err.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
         if (err.error is SocketException) {
          appError = const AppError.network(
            'No internet connection. Please check your network and try again.',
          );
        } else {
          appError = const AppError.network(
            'Connection timed out. Please try again.',
          );
        }

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        appError = _handleHttpError(statusCode, err);

      case DioExceptionType.cancel:
         return handler.next(err);

      default:
        appError = AppError.unknown(
          'An unexpected error occurred. Please try again.',
          original: err,
        );
    }

     handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appError,
        type: err.type,
        response: err.response,
      ),
    );
  }

  AppError _handleHttpError(int statusCode, DioException err) {
    switch (statusCode) {
      case 401:
         _handleExpiredToken();
        return const AppError.auth(
          'Your session has expired. Please log in again.',
        );

      case 403:
        return const AppError.auth(
          'You don\'t have permission to do that.',
        );

      case 404:
        return const AppError.server(
          'The requested content could not be found.',
        );

      case 422:
         final serverMessage = _extractServerMessage(err.response?.data);
        return AppError.validation(
          serverMessage ?? 'Please check your input and try again.',
        );

      case 429:
        return const AppError.server(
          'Too many requests. Please wait a moment and try again.',
        );

      case >= 500:
        return const AppError.server(
          'Something went wrong on our end. Please try again later.',
        );

      default:
        return AppError.server(
          'Request failed (Error $statusCode). Please try again.',
        );
    }
  }

  void _handleExpiredToken() {
     try {
      _ref.read(authProvider.notifier).logout();
    } catch (_) {
     }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
             data['error'] as String? ??
             data['detail'] as String?;
    }
    return null;
  }
} 
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration initialDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.initialDelay = const Duration(milliseconds: 500),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode ?? 0;

     if (statusCode >= 500 && statusCode < 600) {
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

      if (retryCount < maxRetries) {
         final delay = initialDelay * (1 << retryCount);
        await Future.delayed(delay);

        try {
          final response = await dio.fetch(
            err.requestOptions..extra['retryCount'] = retryCount + 1,
          );
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      }
    }

    handler.next(err);
  }
}