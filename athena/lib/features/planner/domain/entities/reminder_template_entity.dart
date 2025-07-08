// Reminder Template Entity
// Domain layer representation of reminder templates

import 'package:equatable/equatable.dart';

/// Entity representing a reminder template for study sessions
/// 
/// Reminder templates provide predefined configurations for common reminder
/// scenarios (e.g., 15 minutes before, 1 hour before, etc.)
class ReminderTemplateEntity extends Equatable {
  const ReminderTemplateEntity({
    required this.id,
    required this.name,
    this.description,
    required this.offsetMinutes,
    required this.messageTemplate,
    required this.isDefault,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the template
  final String id;

  /// Human-readable name (e.g., "15 Minutes Before")
  final String name;

  /// Optional description explaining when to use this template
  final String? description;

  /// Number of minutes before session start to send reminder
  final int offsetMinutes;

  /// Template message with placeholders (e.g., "{session_title}")
  final String messageTemplate;

  /// Whether this is a default template shown to new users
  final bool isDefault;

  /// Whether this template is currently active/available
  final bool isActive;

  /// When this template was created
  final DateTime? createdAt;

  /// When this template was last updated
  final DateTime? updatedAt;

  /// Creates a copy of this entity with updated fields
  ReminderTemplateEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? offsetMinutes,
    String? messageTemplate,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderTemplateEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Formats the offset time as a human-readable string
  String get formattedOffset {
    if (offsetMinutes < 60) {
      return '$offsetMinutes minutes';
    } else if (offsetMinutes < 1440) {
      final hours = offsetMinutes ~/ 60;
      final minutes = offsetMinutes % 60;
      if (minutes == 0) {
        return hours == 1 ? '1 hour' : '$hours hours';
      } else {
        return '${hours}h ${minutes}m';
      }
    } else {
      final days = offsetMinutes ~/ 1440;
      final remainingMinutes = offsetMinutes % 1440;
      if (remainingMinutes == 0) {
        return days == 1 ? '1 day' : '$days days';
      } else {
        final hours = remainingMinutes ~/ 60;
        return '${days}d ${hours}h';
      }
    }
  }

  /// Gets the appropriate icon based on the offset duration
  String get iconName {
    if (offsetMinutes <= 5) {
      return 'access_alarm'; // Last minute
    } else if (offsetMinutes <= 30) {
      return 'schedule'; // Short term
    } else if (offsetMinutes <= 120) {
      return 'access_time'; // Medium term
    } else {
      return 'date_range'; // Long term
    }
  }

  /// Gets a color category for UI theming
  String get colorCategory {
    if (offsetMinutes <= 15) {
      return 'urgent'; // Red/orange
    } else if (offsetMinutes <= 60) {
      return 'warning'; // Yellow/amber
    } else if (offsetMinutes <= 1440) {
      return 'info'; // Blue
    } else {
      return 'neutral'; // Grey
    }
  }

  /// Interpolates the message template with actual session data
  String interpolateMessage({
    required String sessionTitle,
    required String sessionTime,
    String? sessionSubject,
  }) {
    return messageTemplate
        .replaceAll('{session_title}', sessionTitle)
        .replaceAll('{session_time}', sessionTime)
        .replaceAll('{session_subject}', sessionSubject ?? 'Study Session');
  }

  /// Validates if this template can be used for a given session
  bool canBeUsedForSession({required DateTime sessionStartTime}) {
    final now = DateTime.now();
    final reminderTime = sessionStartTime.subtract(Duration(minutes: offsetMinutes));
    
    // Reminder time must be in the future
    return reminderTime.isAfter(now);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        offsetMinutes,
        messageTemplate,
        isDefault,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ReminderTemplateEntity{'
        'id: $id, '
        'name: $name, '
        'offsetMinutes: $offsetMinutes, '
        'isDefault: $isDefault, '
        'isActive: $isActive'
        '}';
  }
} 