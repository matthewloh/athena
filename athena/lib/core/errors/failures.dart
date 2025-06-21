import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code; // Added code here as optional

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message) : super(code: null);
}

// Specific Auth Failures (can extend ServerFailure or be unique)
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure(super.message)
    : super(code: '401'); // Example status code
}

class EmailInUseFailure extends AuthFailure {
  const EmailInUseFailure(super.message)
    : super(code: '409'); // Example status code
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure(super.message) : super(code: '404');
}

class SimpleFailure extends Failure {
  const SimpleFailure(super.message, {super.code});
}

// Add more specific failure types as needed
