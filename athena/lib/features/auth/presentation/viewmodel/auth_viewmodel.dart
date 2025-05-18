import 'dart:async';

import 'package:athena/features/auth/domain/entities/user_entity.dart';
import 'package:athena/features/auth/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:athena/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:athena/features/auth/domain/usecases/login_usecase.dart';
import 'package:athena/features/auth/domain/usecases/logout_usecase.dart';
import 'package:athena/features/auth/domain/usecases/signup_usecase.dart';
import 'package:athena/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:athena/features/auth/presentation/providers/auth_providers.dart'; // Assuming this is where new providers are
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final UserEntity? currentUser;
  final bool isAuthenticated;

  final bool isProfileLoading;
  final String? profileError;

  AuthState({
    this.isLoading = false,
    this.error,
    this.currentUser,
    this.isProfileLoading = false,
    this.profileError,
  }) : isAuthenticated = currentUser != null;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserEntity? currentUser,
    bool? isAuthenticated,
    bool? isProfileLoading,
    String? profileError,
    bool? forceErrorNull,
    bool? forceProfileErrorNull,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: forceErrorNull == true ? null : error ?? this.error,
      currentUser: currentUser ?? this.currentUser,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      profileError:
          forceProfileErrorNull == true
              ? null
              : profileError ?? this.profileError,
    );
  }
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  late final LoginUsecase _loginUsecase;
  late final SignUpUsecase _signUpUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetAuthStateChangesUsecase _getAuthStateChangesUsecase;
  late final GetUserProfileUsecase _getUserProfileUsecase;
  late final UpdateUserProfileUsecase _updateUserProfileUsecase;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  @override
  AuthState build() {
    _loginUsecase = ref.watch(loginUsecaseProvider);
    _signUpUsecase = ref.watch(signUpUsecaseProvider);
    _logoutUsecase = ref.watch(logoutUsecaseProvider);
    _getAuthStateChangesUsecase = ref.watch(getAuthStateChangesUsecaseProvider);
    _getUserProfileUsecase = ref.watch(getUserProfileUsecaseProvider);
    _updateUserProfileUsecase = ref.watch(updateUserProfileUsecaseProvider);

    _authStateSubscription?.cancel();
    _authStateSubscription = _getAuthStateChangesUsecase.call().listen(
      (user) {
        if (user != null) {
          state = state.copyWith(
            currentUser: user,
            isLoading: false,
            forceErrorNull: true,
          );
          fetchUserProfile();
        } else {
          state = state.copyWith(
            currentUser: null,
            isLoading: false,
            forceErrorNull: true,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to listen to auth state: $error',
          isLoading: false,
        );
      },
    );

    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return AuthState();
  }

  Future<void> fetchUserProfile() async {
    state = state.copyWith(isProfileLoading: true, forceProfileErrorNull: true);
    final result = await _getUserProfileUsecase.call();
    result.fold(
      (failure) =>
          state = state.copyWith(
            isProfileLoading: false,
            profileError: failure.message,
          ),
      (userProfile) =>
          state = state.copyWith(
            isProfileLoading: false,
            currentUser: userProfile,
            forceProfileErrorNull: true,
          ),
    );
  }

  Future<void> updateUserProfile(UserEntity user) async {
    state = state.copyWith(isProfileLoading: true, forceProfileErrorNull: true);
    final result = await _updateUserProfileUsecase.call(user);
    result.fold(
      (failure) =>
          state = state.copyWith(
            isProfileLoading: false,
            profileError: failure.message,
          ),
      (_) {
        state = state.copyWith(
          isProfileLoading: false,
          currentUser: user,
          forceProfileErrorNull: true,
        );
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, forceErrorNull: true);
    final result = await _loginUsecase.call(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        state = state.copyWith(isLoading: false, forceErrorNull: true);
      },
    );
  }

  Future<void> signUp(String email, String password, {String? fullName}) async {
    state = state.copyWith(isLoading: true, forceErrorNull: true);
    final result = await _signUpUsecase.call(
      SignUpParams(email: email, password: password, fullName: fullName),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) {
        state = state.copyWith(isLoading: false, forceErrorNull: true);
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, forceErrorNull: true);
    final result = await _logoutUsecase.call();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        state = state.copyWith(isLoading: false, forceErrorNull: true);
      },
    );
  }
}
