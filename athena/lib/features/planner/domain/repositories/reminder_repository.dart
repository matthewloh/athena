import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';
import 'package:athena/features/planner/domain/entities/session_reminder_entity.dart';
import 'package:athena/features/planner/domain/entities/user_reminder_preferences_entity.dart';
import 'package:dartz/dartz.dart';

/// Abstract repository interface for reminder operations
abstract class ReminderRepository {
  // ============================================================================
  // REMINDER TEMPLATES OPERATIONS
  // ============================================================================

  /// Gets all active reminder templates
  Future<Either<Failure, List<ReminderTemplateEntity>>> getReminderTemplates();

  /// Gets default reminder templates
  Future<Either<Failure, List<ReminderTemplateEntity>>> getDefaultReminderTemplates();

  // ============================================================================
  // SESSION REMINDERS OPERATIONS
  // ============================================================================

  /// Gets all session reminders for a user
  Future<Either<Failure, List<SessionReminderEntity>>> getSessionReminders(String userId);

  /// Gets reminders for a specific session
  Future<Either<Failure, List<SessionReminderEntity>>> getSessionRemindersBySession(String sessionId);

  /// Gets a specific session reminder by ID
  Future<Either<Failure, SessionReminderEntity>> getSessionReminderById(String reminderId);

  /// Creates a new session reminder
  Future<Either<Failure, SessionReminderEntity>> createSessionReminder(SessionReminderEntity reminder);

  /// Updates an existing session reminder
  Future<Either<Failure, SessionReminderEntity>> updateSessionReminder(SessionReminderEntity reminder);

  /// Deletes a session reminder
  Future<Either<Failure, void>> deleteSessionReminder(String reminderId);

  /// Updates the delivery status of a reminder
  Future<Either<Failure, SessionReminderEntity>> updateReminderDeliveryStatus(
    String reminderId,
    String deliveryStatus,
    {String? errorMessage}
  );

  // ============================================================================
  // USER REMINDER PREFERENCES OPERATIONS
  // ============================================================================

  /// Gets user reminder preferences
  Future<Either<Failure, UserReminderPreferencesEntity>> getUserReminderPreferences(String userId);

  /// Creates new user reminder preferences
  Future<Either<Failure, UserReminderPreferencesEntity>> createUserReminderPreferences(
    UserReminderPreferencesEntity preferences
  );

  /// Updates user reminder preferences
  Future<Either<Failure, UserReminderPreferencesEntity>> updateUserReminderPreferences(
    UserReminderPreferencesEntity preferences
  );
} 