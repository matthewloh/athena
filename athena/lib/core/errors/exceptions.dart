/// Base class for all custom exceptions in the application.
class AppException implements Exception {
  final String message;
  final String? statusCode; // Optional: for HTTP status codes or similar

  const AppException(this.message, {this.statusCode});

  @override
  String toString() {
    String result = 'AppException';
    if (statusCode != null) {
      result += ' ($statusCode)';
    }
    result += ': $message';
    return result;
  }
}

/// Exception for server-side errors (e.g., API errors, network issues).
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Exception specifically for authentication-related errors.
class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode});
}

/// Exception for errors related to local cache operations.
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Exception for errors when a feature or functionality is not implemented yet.
class NotImplementedException extends AppException {
  const NotImplementedException([super.message = 'Functionality not implemented yet']);
}

class NetworkException implements Exception {
    final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// You can add other specific exceptions as needed 