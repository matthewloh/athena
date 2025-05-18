import 'package:athena/core/errors/exceptions.dart'; // We'll create this for custom exceptions
import 'package:athena/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSupabaseDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthSupabaseDataSourceImpl({required this.supabaseClient});

  @override
  Stream<User?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((authState) {
      return authState.session?.user;
    });
  }

  @override
  User? getCurrentUser() {
    try {
      return supabaseClient.auth.currentUser;
    } catch (e) {
      // In case of any unexpected error accessing currentUser
      throw ServerException('Could not retrieve current user: ${e.toString()}');
    }
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return response.user!;
      } else {
        throw ServerException('Sign in failed: User is null. Possible MFA or other issue.');
      }
    } on AuthException catch (e) {
      throw ServerException('Sign in failed: ${e.message}', statusCode: int.tryParse(e.statusCode ?? ""));
    } catch (e) {
      throw ServerException('An unexpected error occurred during sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException('Sign out failed: ${e.message}', statusCode: int.tryParse(e.statusCode ?? ""));
    } catch (e) {
      throw ServerException('An unexpected error occurred during sign out: ${e.toString()}');
    }
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      if (response.user != null) {
        return response.user!;
      } else {
        // This case might indicate email confirmation is required and user object is not immediately available
        // Or an error occurred that wasn't an AuthException
        throw ServerException('Sign up failed: User is null after sign up. Email confirmation might be pending or an error occurred.');
      }
    } on AuthException catch (e) {
      throw ServerException('Sign up failed: ${e.message}', statusCode: int.tryParse(e.statusCode ?? ""));
    } catch (e) {
      throw ServerException('An unexpected error occurred during sign up: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get user profile: ${e.message}', statusCode: int.tryParse(e.code ?? ""));
    } catch (e) {
      throw ServerException('An unexpected error occurred while fetching profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(String userId, UserEntity user) async {
    try {
      await supabaseClient.from('profiles').update({
        'full_name': user.fullName,
        'preferred_subjects': user.preferredSubjects,
        // 'updated_at': DateTime.now().toIso8601String(), // Handled by DB trigger potentially
      }).eq('id', userId);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update user profile: ${e.message}', statusCode: int.tryParse(e.code ?? ""));
    } catch (e) {
      throw ServerException('An unexpected error occurred while updating profile: ${e.toString()}');
    }
  }
} 