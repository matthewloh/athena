import 'package:athena/core/providers/supabase_providers.dart';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_providers.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthSupabaseDataSourceImpl(supabaseClient: supabaseClient);
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  // final networkInfo = ref.watch(networkInfoProvider); // If using NetworkInfo
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
LoginUsecase loginUsecase(LoginUsecaseRef ref) {
  return LoginUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpUsecase signUpUsecase(SignUpUsecaseRef ref) {
  return SignUpUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
LogoutUsecase logoutUsecase(LogoutUsecaseRef ref) {
  return LogoutUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
GetAuthStateChangesUsecase getAuthStateChangesUsecase(GetAuthStateChangesUsecaseRef ref) {
  return GetAuthStateChangesUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
GetUserProfileUsecase getUserProfileUsecase(GetUserProfileUsecaseRef ref) {
  return GetUserProfileUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
UpdateUserProfileUsecase updateUserProfileUsecase(UpdateUserProfileUsecaseRef ref) {
  return UpdateUserProfileUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
} 