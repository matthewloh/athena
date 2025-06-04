import 'dart:io';
import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/auth/data/datasources/profile_remote_datasource.dart';
import 'package:athena/features/auth/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSupabaseDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ProfileSupabaseDataSourceImpl(this._supabaseClient);

  @override
  Future<ProfileModel> getCurrentUserProfile(String userId) async {
    try {
      final response =
          await _supabaseClient
              .from('profiles')
              .select()
              .eq('id', userId)
              .single();
      return ProfileModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        'Failed to fetch profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred while fetching profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateUserProfile(ProfileModel profile) async {
    try {
      await _supabaseClient
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    } on PostgrestException catch (e) {
      throw ServerException(
        'Failed to update profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred while updating profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/profile.$fileExt';
      await _supabaseClient.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Construct the public URL using the same full path
      final publicUrl = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Update the avatar_url in the profiles table
      await _supabaseClient
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(
        'Failed to upload profile picture: ${e.message}',
        code: e.statusCode,
      );
    } on PostgrestException catch (e) {
      throw ServerException(
        'Failed to update avatar_url in profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        'An unexpected error occurred while uploading profile picture: ${e.toString()}',
      );
    }
  }
}
