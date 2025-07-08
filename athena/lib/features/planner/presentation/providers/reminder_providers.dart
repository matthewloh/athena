import 'package:athena/core/providers/supabase_providers.dart';
import 'package:athena/features/planner/data/datasources/reminder_remote_datasource.dart';
import 'package:athena/features/planner/data/datasources/reminder_supabase_datasource_impl.dart';
import 'package:athena/features/planner/data/repositories/reminder_repository_impl.dart';
import 'package:athena/features/planner/domain/repositories/reminder_repository.dart';
import 'package:athena/features/planner/domain/usecases/get_reminder_templates_usecase.dart';
import 'package:athena/features/planner/domain/usecases/manage_session_reminders_usecase.dart';
import 'package:athena/features/planner/domain/usecases/manage_user_reminder_preferences_usecase.dart';
import 'package:athena/features/planner/presentation/viewmodel/reminder_templates_viewmodel.dart';
import 'package:athena/features/planner/presentation/viewmodel/session_reminders_viewmodel.dart';
import 'package:athena/features/planner/presentation/viewmodel/user_reminder_preferences_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// =============================================================================
// DATA LAYER PROVIDERS
// =============================================================================

/// Provider for reminder remote data source
final reminderRemoteDataSourceProvider = Provider<ReminderRemoteDataSource>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return ReminderSupabaseDataSourceImpl(supabaseClient);
});

/// Provider for reminder repository
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final remoteDataSource = ref.read(reminderRemoteDataSourceProvider);
  return ReminderRepositoryImpl(remoteDataSource);
});

// =============================================================================
// DOMAIN LAYER PROVIDERS (USE CASES)
// =============================================================================

/// Provider for get reminder templates use case
final getReminderTemplatesUseCaseProvider = Provider<GetReminderTemplatesUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return GetReminderTemplatesUseCase(repository);
});

/// Provider for manage session reminders use case
final manageSessionRemindersUseCaseProvider = Provider<ManageSessionRemindersUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return ManageSessionRemindersUseCase(repository);
});

/// Provider for manage user reminder preferences use case
final manageUserReminderPreferencesUseCaseProvider = Provider<ManageUserReminderPreferencesUseCase>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return ManageUserReminderPreferencesUseCase(repository);
});

// =============================================================================
// PRESENTATION LAYER PROVIDERS (VIEW MODELS)
// =============================================================================

/// Provider for reminder templates view model
final reminderTemplatesViewModelProvider = StateNotifierProvider<ReminderTemplatesViewModel, ReminderTemplatesState>((ref) {
  final getReminderTemplatesUseCase = ref.read(getReminderTemplatesUseCaseProvider);
  return ReminderTemplatesViewModel(getReminderTemplatesUseCase);
});

/// Provider for session reminders view model
final sessionRemindersViewModelProvider = StateNotifierProvider<SessionRemindersViewModel, SessionRemindersState>((ref) {
  final manageSessionRemindersUseCase = ref.read(manageSessionRemindersUseCaseProvider);
  return SessionRemindersViewModel(manageSessionRemindersUseCase);
});

/// Provider for user reminder preferences view model
final userReminderPreferencesViewModelProvider = StateNotifierProvider<UserReminderPreferencesViewModel, UserReminderPreferencesState>((ref) {
  final manageUserReminderPreferencesUseCase = ref.read(manageUserReminderPreferencesUseCaseProvider);
  return UserReminderPreferencesViewModel(manageUserReminderPreferencesUseCase);
}); 