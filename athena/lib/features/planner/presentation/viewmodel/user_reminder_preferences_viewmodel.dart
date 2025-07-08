import 'package:athena/features/planner/domain/entities/user_reminder_preferences_entity.dart';
import 'package:athena/features/planner/domain/usecases/manage_user_reminder_preferences_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for user reminder preferences
class UserReminderPreferencesState {
  final UserReminderPreferencesEntity? preferences;
  final bool isLoading;
  final String? errorMessage;

  const UserReminderPreferencesState({
    this.preferences,
    this.isLoading = false,
    this.errorMessage,
  });

  UserReminderPreferencesState copyWith({
    UserReminderPreferencesEntity? preferences,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserReminderPreferencesState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for managing user reminder preferences
class UserReminderPreferencesViewModel extends StateNotifier<UserReminderPreferencesState> {
  final ManageUserReminderPreferencesUseCase _manageUserReminderPreferencesUseCase;

  UserReminderPreferencesViewModel(this._manageUserReminderPreferencesUseCase) 
      : super(const UserReminderPreferencesState());

  /// Loads user reminder preferences
  Future<void> loadUserPreferences(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageUserReminderPreferencesUseCase.getUserPreferences(userId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (preferences) => state = state.copyWith(
        isLoading: false,
        preferences: preferences,
        errorMessage: null,
      ),
    );
  }

  /// Creates user preferences with defaults if they don't exist
  Future<bool> createUserPreferences(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageUserReminderPreferencesUseCase.createUserPreferences(userId);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (preferences) {
        state = state.copyWith(
          isLoading: false,
          preferences: preferences,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Updates user reminder preferences
  Future<bool> updateUserPreferences(UserReminderPreferencesEntity preferences) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageUserReminderPreferencesUseCase.updateUserPreferences(preferences);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedPreferences) {
        state = state.copyWith(
          isLoading: false,
          preferences: updatedPreferences,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Toggles a specific reminder type
  Future<bool> toggleReminderType(String userId, ReminderType reminderType, bool enabled) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageUserReminderPreferencesUseCase.toggleReminderType(
      userId,
      reminderType,
      enabled,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedPreferences) {
        state = state.copyWith(
          isLoading: false,
          preferences: updatedPreferences,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Updates quiet hours settings
  Future<bool> updateQuietHours(String userId, String startTime, String endTime) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageUserReminderPreferencesUseCase.updateQuietHours(
      userId,
      startTime,
      endTime,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedPreferences) {
        state = state.copyWith(
          isLoading: false,
          preferences: updatedPreferences,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Updates default reminder offset
  Future<bool> updateDefaultReminderOffset(String userId, int offsetMinutes) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageUserReminderPreferencesUseCase.updateDefaultReminderOffset(
      userId,
      offsetMinutes,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedPreferences) {
        state = state.copyWith(
          isLoading: false,
          preferences: updatedPreferences,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Checks if quiet hours are currently active
  bool isInQuietHours() {
    if (state.preferences == null) return false;
    return state.preferences!.isInQuietHours(DateTime.now());
  }

  /// Gets formatted quiet hours display
  String getQuietHoursDisplay() {
    if (state.preferences == null || 
        state.preferences!.quietHoursStart == null || 
        state.preferences!.quietHoursEnd == null) {
      return 'Not set';
    }
    
    return '${state.preferences!.quietHoursStart} - ${state.preferences!.quietHoursEnd}';
  }

  /// Clear current state
  void clearState() {
    state = const UserReminderPreferencesState();
  }
} 