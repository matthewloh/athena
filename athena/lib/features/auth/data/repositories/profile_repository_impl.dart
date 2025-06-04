import 'dart:io';
import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/core/providers/auth_provider.dart'; // To get current user ID
import 'package:athena/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:athena/features/auth/data/models/profile_model.dart';
import 'package:athena/features/auth/domain/entities/profile_entity.dart';
import 'package:athena/features/auth/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For Ref

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final Ref _ref; // To access AppAuth provider for current user ID

  ProfileRepositoryImpl(this._remoteDataSource, this._ref);

  String? _getCurrentUserId() {
    return _ref.read(appAuthProvider).valueOrNull?.id;
  }

  @override
  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      return Left(AuthFailure('User not authenticated.'));
    }
    try {
      final profileModel = await _remoteDataSource.getCurrentUserProfile(userId);
      return Right(profileModel); // ProfileModel is a subtype of ProfileEntity
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to get user profile: ${e.message}', code: e.code));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(ProfileEntity profile) async {
    if (profile is! ProfileModel) {
      // This conversion might be too simplistic. Consider a better way if needed.
      final profileModel = ProfileModel(
          id: profile.id,
          username: profile.username,
          fullName: profile.fullName,
          avatarUrl: profile.avatarUrl,
          website: profile.website,
          updatedAt: profile.updatedAt ?? DateTime.now(),
      );
      try {
        await _remoteDataSource.updateUserProfile(profileModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure('Failed to update profile: ${e.message}', code: e.code));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      try {
        await _remoteDataSource.updateUserProfile(profile);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure('Failed to update profile: ${e.message}', code: e.code));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(String filePath) async {
     final userId = _getCurrentUserId();
    if (userId == null) {
      return Left(AuthFailure('User not authenticated.'));
    }
    try {
      final File imageFile = File(filePath);
      if (!await imageFile.exists()){
        return Left(SimpleFailure('Image file not found at path: $filePath'));
      }
      final downloadUrl = await _remoteDataSource.uploadProfilePicture(userId, imageFile);
      return Right(downloadUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to upload profile picture: ${e.message}', code: e.code));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred during upload: ${e.toString()}'));
    }
  }
} 