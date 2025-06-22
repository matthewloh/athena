import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/entities/profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile();
  Future<Either<Failure, void>> updateUserProfile(ProfileEntity profile);
  Future<Either<Failure, String>> uploadProfilePicture(String filePath);
} 