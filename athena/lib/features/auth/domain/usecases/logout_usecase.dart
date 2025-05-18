import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

// Usecase for a simple action with no parameters
class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
} 