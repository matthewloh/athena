import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode; // Optional: for HTTP errors or specific error codes

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message)
    : super(statusCode: null); // Cache failures might not have status codes
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message) : super(statusCode: null);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message) : super(statusCode: null);
}

// Specific Auth Failures (can extend ServerFailure or be unique)
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure(super.message)
    : super(statusCode: 401); // Example status code
}

class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure(super.message)
    : super(statusCode: 409); // Example status code
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure(super.message) : super(statusCode: 404);
}

// Add more specific failure types as needed
