class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status Code: ${statusCode ?? 'N/A'})';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
    final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// You can add other specific exceptions as needed 