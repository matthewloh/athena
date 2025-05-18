import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SignUpUsecase {
  final AuthRepository repository;

  SignUpUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String? fullName;

  const SignUpParams({
    required this.email,
    required this.password,
    this.fullName,
  });

  @override
  List<Object?> get props => [email, password, fullName];
} 