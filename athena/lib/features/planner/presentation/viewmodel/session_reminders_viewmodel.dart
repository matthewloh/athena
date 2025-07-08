import 'package:athena/features/planner/domain/entities/session_reminder_entity.dart';
import 'package:athena/features/planner/domain/usecases/manage_session_reminders_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for session reminders
class SessionRemindersState {
  final List<SessionReminderEntity> reminders;
  final bool isLoading;
  final String? errorMessage;

  const SessionRemindersState({
    this.reminders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SessionRemindersState copyWith({
    List<SessionReminderEntity>? reminders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SessionRemindersState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for managing session reminders
class SessionRemindersViewModel extends StateNotifier<SessionRemindersState> {
  final ManageSessionRemindersUseCase _manageSessionRemindersUseCase;

  SessionRemindersViewModel(this._manageSessionRemindersUseCase) 
      : super(const SessionRemindersState());

  /// Loads reminders for a specific session
  Future<void> loadSessionReminders(String sessionId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageSessionRemindersUseCase.getSessionReminders(sessionId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (reminders) => state = state.copyWith(
        isLoading: false,
        reminders: reminders,
        errorMessage: null,
      ),
    );
  }

  /// Loads all reminders for a user
  Future<void> loadUserReminders(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageSessionRemindersUseCase.getUserReminders(userId);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (reminders) => state = state.copyWith(
        isLoading: false,
        reminders: reminders,
        errorMessage: null,
      ),
    );
  }

  /// Creates a new reminder
  Future<bool> createReminder(SessionReminderEntity reminder) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageSessionRemindersUseCase.createReminder(reminder);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdReminder) {
        final updatedReminders = [...state.reminders, createdReminder];
        state = state.copyWith(
          isLoading: false,
          reminders: updatedReminders,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Updates an existing reminder
  Future<bool> updateReminder(SessionReminderEntity reminder) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageSessionRemindersUseCase.updateReminder(reminder);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedReminder) {
        final updatedReminders = state.reminders
            .map((r) => r.id == updatedReminder.id ? updatedReminder : r)
            .toList();
        state = state.copyWith(
          isLoading: false,
          reminders: updatedReminders,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Deletes a reminder
  Future<bool> deleteReminder(String reminderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageSessionRemindersUseCase.deleteReminder(reminderId);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        final updatedReminders = state.reminders
            .where((r) => r.id != reminderId)
            .toList();
        state = state.copyWith(
          isLoading: false,
          reminders: updatedReminders,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Toggles a reminder's enabled state
  Future<bool> toggleReminderEnabled(String reminderId, bool isEnabled) async {
    final reminder = state.reminders.firstWhere((r) => r.id == reminderId);
    final updatedReminder = reminder.copyWith(isEnabled: isEnabled);
    return await updateReminder(updatedReminder);
  }

  /// Creates default reminders for a session
  Future<bool> createDefaultRemindersForSession(
    String sessionId,
    String userId,
    List<String> templateIds,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _manageSessionRemindersUseCase.createDefaultRemindersForSession(
      sessionId,
      userId,
      templateIds,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdReminders) {
        final updatedReminders = [...state.reminders, ...createdReminders];
        state = state.copyWith(
          isLoading: false,
          reminders: updatedReminders,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  /// Clear current state
  void clearState() {
    state = const SessionRemindersState();
  }
} 