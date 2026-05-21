sealed class AppError implements Exception {
  final String userMessage;
  const AppError(this.userMessage);

  const factory AppError.network(String userMessage) = NetworkError;
  const factory AppError.auth(String userMessage) = AuthError;
  const factory AppError.server(String userMessage) = ServerError;
  const factory AppError.validation(String userMessage) = ValidationError;
  factory AppError.unknown(String userMessage, {Object? original}) =
      UnknownError;

  @override
  String toString() => 'AppError(${runtimeType}): $userMessage';
}

class NetworkError extends AppError {
  const NetworkError(super.userMessage);
}

class AuthError extends AppError {
  const AuthError(super.userMessage);
}

class ServerError extends AppError {
  const ServerError(super.userMessage);
}

class ValidationError extends AppError {
  const ValidationError(super.userMessage);
}

class UnknownError extends AppError {
  final Object? original;
  const UnknownError(super.userMessage, {this.original});
}

extension AppErrorX on AppError {
  bool get isRetryable => switch (this) {
    NetworkError() => true,
    ServerError() => true,
    AuthError() => false,
    ValidationError() => false,
    UnknownError() => false,
  };

  bool get requiresLogout => this is AuthError;
}
