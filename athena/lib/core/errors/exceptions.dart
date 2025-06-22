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
class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException(this.message, {this.code});

  @override
  String toString() {
    if (code != null) {
      return 'ServerException: $message (Code: $code)';
    }
    return 'ServerException: $message';
  }
}

/// Exception specifically for authentication-related errors.
class AuthException implements Exception {
  final String message;
  final String? statusCode; // Kept for compatibility if used elsewhere specifically for HTTP status

  AuthException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'AuthException: $message (Status Code: $statusCode)';
    }
    return 'AuthException: $message';
  }
}

/// Exception for errors related to local cache operations.
class CacheException implements Exception {
  final String message;
  CacheException(this.message);
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