import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  // Stream to get the current authenticated user or null if not authenticated
  // This can also emit an AuthChangeEvent (e.g. signedIn, signedOut, userUpdated, tokenRefreshed, passwordRecovery)
  // For simplicity, let's start with UserEntity?
  Stream<UserEntity?> get authStateChanges;

  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName, // Or other metadata like Map<String, dynamic> data
  });

  Future<Either<Failure, void>> signOut();

  // Optional: Get current user if one exists synchronously (might be null)
  // Future<Either<Failure, UserEntity?>> getCurrentUser(); 

  // Optional: Send password reset email
  // Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  // Optional: Update user profile (e.g., name, preferences)
  // Future<Either<Failure, UserEntity>> updateUser(UserEntity user);

  // Profile Management
  Future<Either<Failure, UserEntity>> getUserProfile();
  Future<Either<Failure, void>> updateUserProfile(UserEntity user);
} 