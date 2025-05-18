import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// Basic Usecase structure - can be made more generic later if needed
class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.signInWithEmailAndPassword(
      params.email,
      params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
} 