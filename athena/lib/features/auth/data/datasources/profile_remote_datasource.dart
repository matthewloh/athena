import 'dart:io';
import 'package:athena/features/auth/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getCurrentUserProfile(String userId);
  Future<void> updateUserProfile(ProfileModel profile);
  Future<String> uploadProfilePicture(String userId, File imageFile);
} 