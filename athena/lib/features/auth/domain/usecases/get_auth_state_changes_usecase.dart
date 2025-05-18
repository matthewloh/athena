import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';

class GetAuthStateChangesUsecase {
  final AuthRepository repository;

  GetAuthStateChangesUsecase(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
} 