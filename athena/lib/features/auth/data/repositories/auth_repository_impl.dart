import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Optional: if you need to check network status

  AuthRepositoryImpl({
    required this.remoteDataSource,
    // required this.networkInfo,
  });

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((supabaseUser) {
      return supabaseUser != null
          ? _mapSupabaseUserToUserEntity(supabaseUser)
          : null;
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // if (await networkInfo.isConnected) { // Optional network check
    try {
      final supabaseUser = await remoteDataSource.signInWithEmailAndPassword(
        email,
        password,
      );
      return Right(_mapSupabaseUserToUserEntity(supabaseUser));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      // This might be redundant if datasource throws ServerException for AuthException
      return Left(
        AuthFailure(e.message, statusCode: int.tryParse(e.statusCode ?? "")),
      );
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
    // } else {
    //   return Left(NetworkFailure('No internet connection'));
    // }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final supabaseUser = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
      );
      return Right(_mapSupabaseUserToUserEntity(supabaseUser));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(e.message, statusCode: int.tryParse(e.statusCode ?? "")),
      );
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null); // Or Right(unit) if using dartz unit
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on AuthException catch (e) {
      return Left(
        AuthFailure(e.message, statusCode: int.tryParse(e.statusCode ?? "")),
      );
    } catch (e) {
      return Left(
        UnknownFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  // Helper to map Supabase User to UserEntity
  UserEntity _mapSupabaseUserToUserEntity(User supabaseUser, {Map<String, dynamic>? profileData}) {
    List<String>? preferredSubjects;
    if (profileData?['preferred_subjects'] != null && profileData!['preferred_subjects'] is List) {
      preferredSubjects = List<String>.from(profileData['preferred_subjects']);
    }
    return UserEntity(
      id: supabaseUser.id,
      email: supabaseUser.email,
      fullName: profileData?['full_name'] as String? ?? supabaseUser.userMetadata?['full_name'] as String?,
      preferredSubjects: preferredSubjects,
    );
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final supabaseUser = remoteDataSource.getCurrentUser();
      if (supabaseUser == null) {
        return Left(AuthFailure('User not authenticated', statusCode: 401));
      }
      final profileData = await remoteDataSource.getUserProfile(supabaseUser.id);
      return Right(_mapSupabaseUserToUserEntity(supabaseUser, profileData: profileData));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserEntity user) async {
    try {
      // Ensure we have the current user ID, as UserEntity might be constructed with an ID
      // but it's good practice to use the ID from the authenticated session if possible,
      // or ensure the passed user.id is indeed the currently authenticated user's ID.
      final supabaseUser = remoteDataSource.getCurrentUser();
      if (supabaseUser == null || supabaseUser.id != user.id) {
        return Left(AuthFailure('User not authenticated or ID mismatch', statusCode: 401));
      }
      await remoteDataSource.updateUserProfile(user.id, user);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Example for getCurrentUser, if added to the interface
  /*
  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final supabaseUser = remoteDataSource.getCurrentUser();
      if (supabaseUser != null) {
        return Right(_mapSupabaseUserToUserEntity(supabaseUser));
      } else {
        return const Right(null);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
  */
}

// Optional: NetworkInfo interface and implementation if needed
/*
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    // The current connectivity status, check if it's none
    if (result.contains(ConnectivityResult.none)) {
        return false;
    }
    return true;  }
}
*/
