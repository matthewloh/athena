import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetUserProfileUsecase {
  final AuthRepository repository;

  GetUserProfileUsecase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getUserProfile();
  }
} 