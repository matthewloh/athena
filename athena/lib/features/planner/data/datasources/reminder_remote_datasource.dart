import 'package:athena/features/planner/data/models/reminder_template_model.dart';
import 'package:athena/features/planner/data/models/session_reminder_model.dart';
import 'package:athena/features/planner/data/models/user_reminder_preferences_model.dart';

/// Abstract interface for reminder remote data source operations
abstract class ReminderRemoteDataSource {
  // ============================================================================
  // REMINDER TEMPLATES OPERATIONS
  // ============================================================================

  /// Gets all active reminder templates from remote database
  Future<List<ReminderTemplateModel>> getReminderTemplates();

  /// Gets default reminder templates from remote database
  Future<List<ReminderTemplateModel>> getDefaultReminderTemplates();

  // ============================================================================
  // SESSION REMINDERS OPERATIONS
  // ============================================================================

  /// Gets all session reminders for a user from remote database
  Future<List<SessionReminderModel>> getSessionReminders(String userId);

  /// Gets reminders for a specific session from remote database
  Future<List<SessionReminderModel>> getSessionRemindersBySession(String sessionId);

  /// Gets a specific session reminder by ID from remote database
  Future<SessionReminderModel> getSessionReminderById(String reminderId);

  /// Creates a new session reminder in remote database
  Future<SessionReminderModel> createSessionReminder(SessionReminderModel reminder);

  /// Updates an existing session reminder in remote database
  Future<SessionReminderModel> updateSessionReminder(SessionReminderModel reminder);

  /// Deletes a session reminder from remote database
  Future<void> deleteSessionReminder(String reminderId);

  /// Updates the delivery status of a reminder
  Future<SessionReminderModel> updateReminderDeliveryStatus(
    String reminderId,
    String deliveryStatus,
    {String? errorMessage}
  );

  // ============================================================================
  // USER REMINDER PREFERENCES OPERATIONS
  // ============================================================================

  /// Gets user reminder preferences from remote database
  Future<UserReminderPreferencesModel> getUserReminderPreferences(String userId);

  /// Creates new user reminder preferences in remote database
  Future<UserReminderPreferencesModel> createUserReminderPreferences(
    UserReminderPreferencesModel preferences
  );

  /// Updates user reminder preferences in remote database
  Future<UserReminderPreferencesModel> updateUserReminderPreferences(
    UserReminderPreferencesModel preferences
  );
} 