import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For User, AuthResponse, AuthChangeEvent

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;

  Future<User> signInWithEmailAndPassword(String email, String password);

  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
  });

  Future<void> signOut();

  User? getCurrentUser();

  // Profile Management
  Future<Map<String, dynamic>> getUserProfile(String userId);
  Future<void> updateUserProfile(String userId, UserEntity user);
} 