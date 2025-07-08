import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/planner/data/datasources/reminder_remote_datasource.dart';
import 'package:athena/features/planner/data/models/reminder_template_model.dart';
import 'package:athena/features/planner/data/models/session_reminder_model.dart';
import 'package:athena/features/planner/data/models/user_reminder_preferences_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete implementation of ReminderRemoteDataSource using direct Supabase database operations
class ReminderSupabaseDataSourceImpl implements ReminderRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const ReminderSupabaseDataSourceImpl(this._supabaseClient);

  // ============================================================================
  // REMINDER TEMPLATES OPERATIONS
  // ============================================================================

  @override
  Future<List<ReminderTemplateModel>> getReminderTemplates() async {
    try {
      final response = await _supabaseClient
          .from('reminder_templates')
          .select()
          .eq('is_active', true)
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<ReminderTemplateModel>((json) => ReminderTemplateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch reminder templates: ${e.toString()}');
    }
  }

  @override
  Future<List<ReminderTemplateModel>> getDefaultReminderTemplates() async {
    try {
      final response = await _supabaseClient
          .from('reminder_templates')
          .select()
          .eq('is_active', true)
          .eq('is_default', true)
          .order('offset_minutes');

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<ReminderTemplateModel>((json) => ReminderTemplateModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch default reminder templates: ${e.toString()}');
    }
  }

  // ============================================================================
  // SESSION REMINDERS OPERATIONS
  // ============================================================================

  @override
  Future<List<SessionReminderModel>> getSessionReminders(String userId) async {
    try {
      final response = await _supabaseClient
          .from('session_reminders')
          .select('''
            *,
            reminder_templates (
              id,
              name,
              description,
              offset_minutes,
              message_template,
              is_default,
              is_active,
              created_at,
              updated_at
            ),
            study_sessions (
              id,
              title,
              subject,
              start_time,
              end_time,
              status
            )
          ''')
          .eq('user_id', userId)
          .order('scheduled_time', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<SessionReminderModel>((json) => SessionReminderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch session reminders: ${e.toString()}');
    }
  }

  @override
  Future<List<SessionReminderModel>> getSessionRemindersBySession(String sessionId) async {
    try {
      final response = await _supabaseClient
          .from('session_reminders')
          .select('''
            *,
            reminder_templates (
              id,
              name,
              description,
              offset_minutes,
              message_template,
              is_default,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('session_id', sessionId)
          .order('offset_minutes', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      return response
          .map<SessionReminderModel>((json) => SessionReminderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch session reminders: ${e.toString()}');
    }
  }

  @override
  Future<SessionReminderModel> getSessionReminderById(String reminderId) async {
    try {
      final response = await _supabaseClient
          .from('session_reminders')
          .select('''
            *,
            reminder_templates (
              id,
              name,
              description,
              offset_minutes,
              message_template,
              is_default,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .eq('id', reminderId)
          .single();

      return SessionReminderModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch session reminder: ${e.toString()}');
    }
  }

  @override
  Future<SessionReminderModel> createSessionReminder(SessionReminderModel reminder) async {
    try {
      final insertData = reminder.toJson();
      insertData.remove('id'); // Let database generate the ID
      insertData['created_at'] = DateTime.now().toIso8601String();
      insertData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from('session_reminders')
          .insert(insertData)
          .select('''
            *,
            reminder_templates (
              id,
              name,
              description,
              offset_minutes,
              message_template,
              is_default,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .single();

      return SessionReminderModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create session reminder: ${e.toString()}');
    }
  }

  @override
  Future<SessionReminderModel> updateSessionReminder(SessionReminderModel reminder) async {
    try {
      final updateData = reminder.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from('session_reminders')
          .update(updateData)
          .eq('id', reminder.id)
          .select('''
            *,
            reminder_templates (
              id,
              name,
              description,
              offset_minutes,
              message_template,
              is_default,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .single();

      return SessionReminderModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update session reminder: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteSessionReminder(String reminderId) async {
    try {
      await _supabaseClient
          .from('session_reminders')
          .delete()
          .eq('id', reminderId);
    } catch (e) {
      throw ServerException('Failed to delete session reminder: ${e.toString()}');
    }
  }

  @override
  Future<SessionReminderModel> updateReminderDeliveryStatus(
    String reminderId,
    String deliveryStatus, {
    String? errorMessage,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'delivery_status': deliveryStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (deliveryStatus == 'sent') {
        updateData['sent_at'] = DateTime.now().toIso8601String();
      }

      if (errorMessage != null) {
        updateData['error_message'] = errorMessage;
      }

      final response = await _supabaseClient
          .from('session_reminders')
          .update(updateData)
          .eq('id', reminderId)
          .select('''
            *,
            reminder_templates (
              id,
              name,
              description,
              offset_minutes,
              message_template,
              is_default,
              is_active,
              created_at,
              updated_at
            )
          ''')
          .single();

      return SessionReminderModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update reminder delivery status: ${e.toString()}');
    }
  }

  // ============================================================================
  // USER REMINDER PREFERENCES OPERATIONS
  // ============================================================================

  @override
  Future<UserReminderPreferencesModel> getUserReminderPreferences(String userId) async {
    try {
      final response = await _supabaseClient
          .from('user_reminder_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        // Return default preferences if none exist
        return UserReminderPreferencesModel.defaultForUser(userId);
      }

      return UserReminderPreferencesModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch user reminder preferences: ${e.toString()}');
    }
  }

  @override
  Future<UserReminderPreferencesModel> createUserReminderPreferences(
    UserReminderPreferencesModel preferences,
  ) async {
    try {
      final insertData = preferences.toJson();
      insertData.remove('id'); // Let database generate the ID
      insertData['created_at'] = DateTime.now().toIso8601String();
      insertData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseClient
          .from('user_reminder_preferences')
          .insert(insertData)
          .select()
          .single();

      return UserReminderPreferencesModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create user reminder preferences: ${e.toString()}');
    }
  }

  @override
  Future<UserReminderPreferencesModel> updateUserReminderPreferences(
    UserReminderPreferencesModel preferences,
  ) async {
    try {
      final updateData = preferences.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();
      
      // Ensure times are in correct format - don't double convert
      // They should already be in HH:MM:SS format from the UI

      // Use upsert with onConflict to handle both insert and update cases
      // Remove empty id to let database handle it properly
      if (updateData['id'] == null || updateData['id'] == '') {
        updateData.remove('id');
      }

      final response = await _supabaseClient
          .from('user_reminder_preferences')
          .upsert(updateData, onConflict: 'user_id')
          .select()
          .single();

      return UserReminderPreferencesModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update user reminder preferences: ${e.toString()}');
    }
  }

  /// Helper method to parse time from database (HH:MM:SS) to HH:MM format
  static String? _parseTimeFromDatabase(dynamic timeValue) {
    if (timeValue == null) return null;
    
    final timeString = timeValue.toString();
    if (timeString.contains(':')) {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}'; // Return just HH:MM
      }
    }
    return timeString;
  }
}
