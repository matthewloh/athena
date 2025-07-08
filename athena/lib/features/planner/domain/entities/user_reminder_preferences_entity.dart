// User Reminder Preferences Entity
// Domain layer representation of user notification preferences

import 'package:equatable/equatable.dart';

/// Entity representing user preferences for reminder notifications
/// 
/// This controls default behavior for new sessions, global notification
/// settings, quiet hours, and feature-specific preferences
class UserReminderPreferencesEntity extends Equatable {
  const UserReminderPreferencesEntity({
    required this.id,
    required this.userId,
    required this.defaultReminderTemplateIds,
    required this.notificationsEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.timezone,
    required this.sessionRemindersEnabled,
    required this.goalRemindersEnabled,
    required this.dailyCheckinsEnabled,
    required this.streakRemindersEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for these preferences
  final String id;

  /// ID of the user these preferences belong to
  final String userId;

  /// List of template IDs to auto-create for new sessions
  final List<String> defaultReminderTemplateIds;

  /// Master switch for all notifications
  final bool notificationsEnabled;

  /// Start time for quiet hours (no notifications) in HH:MM format
  final String? quietHoursStart;

  /// End time for quiet hours (no notifications) in HH:MM format
  final String? quietHoursEnd;

  /// User's timezone (e.g., 'Asia/Kuala_Lumpur')
  final String timezone;

  /// Whether session reminders are enabled
  final bool sessionRemindersEnabled;

  /// Whether goal deadline reminders are enabled
  final bool goalRemindersEnabled;

  /// Whether daily check-in notifications are enabled
  final bool dailyCheckinsEnabled;

  /// Whether study streak reminders are enabled
  final bool streakRemindersEnabled;

  /// When these preferences were created
  final DateTime createdAt;

  /// When these preferences were last updated
  final DateTime updatedAt;

  /// Creates a copy of this entity with updated fields
  UserReminderPreferencesEntity copyWith({
    String? id,
    String? userId,
    List<String>? defaultReminderTemplateIds,
    bool? notificationsEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? timezone,
    bool? sessionRemindersEnabled,
    bool? goalRemindersEnabled,
    bool? dailyCheckinsEnabled,
    bool? streakRemindersEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserReminderPreferencesEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      defaultReminderTemplateIds: defaultReminderTemplateIds ?? this.defaultReminderTemplateIds,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      timezone: timezone ?? this.timezone,
      sessionRemindersEnabled: sessionRemindersEnabled ?? this.sessionRemindersEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      dailyCheckinsEnabled: dailyCheckinsEnabled ?? this.dailyCheckinsEnabled,
      streakRemindersEnabled: streakRemindersEnabled ?? this.streakRemindersEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Checks if notifications should be sent at a given time
  bool shouldSendNotificationAt(DateTime time) {
    // Check master switch
    if (!notificationsEnabled) {
      return false;
    }

    // Check quiet hours
    if (quietHoursStart != null && quietHoursEnd != null) {
      return !isInQuietHours(time);
    }

    return true;
  }

  /// Checks if a specific notification type is enabled
  bool isNotificationTypeEnabled(String notificationType) {
    if (!notificationsEnabled) {
      return false;
    }

    switch (notificationType.toLowerCase()) {
      case 'session_reminder':
      case 'session_starting_soon':
        return sessionRemindersEnabled;
      case 'goal_deadline_reminder':
      case 'goal_reminder':
        return goalRemindersEnabled;
      case 'daily_checkin':
        return dailyCheckinsEnabled;
      case 'study_streak_reminder':
      case 'streak_reminder':
        return streakRemindersEnabled;
      default:
        return true; // Default to enabled for unknown types
    }
  }

  /// Gets the next time notifications can be sent (after quiet hours if applicable)
  DateTime? getNextAvailableNotificationTime(DateTime fromTime) {
    if (!notificationsEnabled) {
      return null;
    }

    if (quietHoursStart == null || quietHoursEnd == null) {
      return fromTime;
    }

    if (!isInQuietHours(fromTime)) {
      return fromTime;
    }

    // Calculate when quiet hours end
    final quietEnd = _parseTimeOfDay(quietHoursEnd!);
    if (quietEnd == null) {
      return fromTime;
    }

    final today = DateTime(fromTime.year, fromTime.month, fromTime.day);
    DateTime endTime = today.add(Duration(
      hours: quietEnd.hour,
      minutes: quietEnd.minute,
    ));

    // If quiet hours end is before start (spans midnight), add a day
    final quietStart = _parseTimeOfDay(quietHoursStart!);
    if (quietStart != null && quietEnd.hour < quietStart.hour) {
      endTime = endTime.add(const Duration(days: 1));
    }

    return endTime;
  }

  /// Checks if a time falls within quiet hours
  bool isInQuietHours(DateTime time) {
    if (quietHoursStart == null || quietHoursEnd == null) {
      return false;
    }

    final start = _parseTimeOfDay(quietHoursStart!);
    final end = _parseTimeOfDay(quietHoursEnd!);

    if (start == null || end == null) {
      return false;
    }

    final timeOfDay = TimeOfDay(hour: time.hour, minute: time.minute);

    // Handle overnight quiet hours (e.g., 22:00 to 06:00)
    if (start.hour > end.hour || (start.hour == end.hour && start.minute > end.minute)) {
      return _timeIsAfterOrEqual(timeOfDay, start) || _timeIsBeforeOrEqual(timeOfDay, end);
    } else {
      // Same day quiet hours (e.g., 12:00 to 14:00)
      return _timeIsAfterOrEqual(timeOfDay, start) && _timeIsBeforeOrEqual(timeOfDay, end);
    }
  }

  /// Parses a time string (HH:MM) into TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return null;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  /// Compares TimeOfDay objects
  bool _timeIsAfterOrEqual(TimeOfDay time, TimeOfDay other) {
    return time.hour > other.hour || (time.hour == other.hour && time.minute >= other.minute);
  }

  bool _timeIsBeforeOrEqual(TimeOfDay time, TimeOfDay other) {
    return time.hour < other.hour || (time.hour == other.hour && time.minute <= other.minute);
  }

  /// Gets a human-readable description of quiet hours
  String? get quietHoursDescription {
    if (quietHoursStart == null || quietHoursEnd == null) {
      return null;
    }

    return 'No notifications from $quietHoursStart to $quietHoursEnd';
  }

  /// Gets a summary of enabled notification types
  List<String> get enabledNotificationTypes {
    final types = <String>[];
    
    if (sessionRemindersEnabled) types.add('Session reminders');
    if (goalRemindersEnabled) types.add('Goal reminders');
    if (dailyCheckinsEnabled) types.add('Daily check-ins');
    if (streakRemindersEnabled) types.add('Streak reminders');
    
    return types;
  }

  /// Checks if these are default/minimal preferences
  bool get isDefaultConfiguration {
    return defaultReminderTemplateIds.isEmpty &&
           notificationsEnabled &&
           quietHoursStart == null &&
           quietHoursEnd == null &&
           sessionRemindersEnabled &&
           goalRemindersEnabled &&
           dailyCheckinsEnabled &&
           streakRemindersEnabled;
  }

  /// Creates default preferences for a new user
  static UserReminderPreferencesEntity createDefault({
    required String userId,
    String timezone = 'Asia/Kuala_Lumpur',
  }) {
    final now = DateTime.now();
    
    return UserReminderPreferencesEntity(
      id: '', // Will be generated by backend
      userId: userId,
      defaultReminderTemplateIds: [], // Let user choose their defaults
      notificationsEnabled: true,
      quietHoursStart: null,
      quietHoursEnd: null,
      timezone: timezone,
      sessionRemindersEnabled: true,
      goalRemindersEnabled: true,
      dailyCheckinsEnabled: true,
      streakRemindersEnabled: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        defaultReminderTemplateIds,
        notificationsEnabled,
        quietHoursStart,
        quietHoursEnd,
        timezone,
        sessionRemindersEnabled,
        goalRemindersEnabled,
        dailyCheckinsEnabled,
        streakRemindersEnabled,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserReminderPreferencesEntity{'
        'id: $id, '
        'userId: $userId, '
        'notificationsEnabled: $notificationsEnabled, '
        'timezone: $timezone, '
        'defaultTemplates: ${defaultReminderTemplateIds.length}'
        '}';
  }
}

/// Simple TimeOfDay class since it's not available in core Dart
class TimeOfDay {
  const TimeOfDay({required this.hour, required this.minute});
  
  final int hour;
  final int minute;
  
  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
} 