// ignore_for_file: avoid_print

import 'package:athena/core/providers/supabase_providers.dart'; // For supabaseClientProvider
import 'package:athena/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:athena/features/auth/data/datasources/profile_supabase_datasource.dart';
import 'package:athena/features/auth/data/repositories/profile_repository_impl.dart';
import 'package:athena/features/auth/domain/entities/profile_entity.dart';
import 'package:athena/features/auth/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

// --- Data Source Provider ---
@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ProfileSupabaseDataSourceImpl(supabaseClient);
}

// --- Repository Provider ---
@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(
    remoteDataSource,
    ref,
  ); // Pass ref for _getCurrentUserId
}

// --- Current User Profile Provider ---
// This provider will fetch the current user's profile.
// It depends on the auth state, so it should react to login/logout.
@riverpod
Future<ProfileEntity?> currentUserProfile(Ref ref) async {
  // No need to watch appAuthProvider here directly,
  // as profileRepository.getCurrentUserProfile() internally gets the current user ID
  // or returns AuthFailure if not logged in.
  final profileRepository = ref.watch(profileRepositoryProvider);
  final result = await profileRepository.getCurrentUserProfile();
  return result.fold((failure) {
    // Log failure or handle error state appropriately
    print('Failed to fetch current user profile: $failure');
    return null; // Or throw to be caught by AsyncValue.error
  }, (profile) => profile);
}
