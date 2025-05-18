import 'package:athena/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:athena/features/auth/data/datasources/auth_supabase_datasource.dart';
import 'package:athena/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:athena/features/auth/domain/repositories/auth_repository.dart';
import 'package:athena/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:athena/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:athena/features/auth/domain/usecases/login_usecase.dart';
import 'package:athena/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athena/features/auth/domain/usecases/signup_usecase.dart';
import 'package:athena/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthSupabaseDataSourceImpl(supabaseClient: supabaseClient);
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  // final networkInfo = ref.watch(networkInfoProvider); // If using NetworkInfo
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
LoginUsecase loginUsecase(Ref ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpUsecase signUpUsecase(Ref ref) {
  return SignUpUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUsecase logoutUsecase(Ref ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
GetAuthStateChangesUsecase getAuthStateChangesUsecase(Ref ref) {
  return GetAuthStateChangesUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
GetUserProfileUsecase getUserProfileUsecase(Ref ref) {
  return GetUserProfileUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
UpdateUserProfileUsecase updateUserProfileUsecase(Ref ref) {
  return UpdateUserProfileUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
