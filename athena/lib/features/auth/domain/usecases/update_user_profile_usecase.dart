import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateUserProfileUsecase {
  final AuthRepository repository;

  UpdateUserProfileUsecase(this.repository);

  Future<Either<Failure, void>> call(UserEntity user) async {
    return await repository.updateUserProfile(user);
  }
} 