// Session Reminder Entity
// Domain layer representation of individual session reminders

import 'package:equatable/equatable.dart';
import 'reminder_template_entity.dart';

/// Enumeration for reminder delivery status
enum ReminderDeliveryStatus {
  pending,
  sent,
  failed,
  cancelled,
}

/// Entity representing an individual reminder for a study session
/// 
/// This links a specific study session to a reminder configuration,
/// tracks delivery status, and manages the reminder lifecycle
class SessionReminderEntity extends Equatable {
  const SessionReminderEntity({
    required this.id,
    required this.sessionId,
    required this.userId,
    this.templateId,
    this.template,
    required this.offsetMinutes,
    this.customMessage,
    required this.isEnabled,
    this.scheduledTime,
    required this.deliveryStatus,
    this.sentAt,
    this.errorMessage,
    this.notificationId,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for this reminder
  final String id;

  /// ID of the study session this reminder is for
  final String sessionId;

  /// ID of the user who owns this reminder
  final String userId;

  /// Optional ID of the template used (null for custom reminders)
  final String? templateId;

  /// Optional template entity if loaded with joins
  final ReminderTemplateEntity? template;

  /// Minutes before session start to send the reminder
  final int offsetMinutes;

  /// Custom message override (takes precedence over template message)
  final String? customMessage;

  /// Whether this reminder is enabled/active
  final bool isEnabled;

  /// Calculated time when reminder should be sent
  final DateTime? scheduledTime;

  /// Current delivery status of the reminder
  final ReminderDeliveryStatus deliveryStatus;

  /// When the reminder was actually sent (if delivered)
  final DateTime? sentAt;

  /// Error message if delivery failed
  final String? errorMessage;

  /// ID of the notification history record (if sent)
  final String? notificationId;

  /// When this reminder was created
  final DateTime? createdAt;

  /// When this reminder was last updated
  final DateTime? updatedAt;

  /// Creates a copy of this entity with updated fields
  SessionReminderEntity copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? templateId,
    ReminderTemplateEntity? template,
    int? offsetMinutes,
    String? customMessage,
    bool? isEnabled,
    DateTime? scheduledTime,
    ReminderDeliveryStatus? deliveryStatus,
    DateTime? sentAt,
    String? errorMessage,
    String? notificationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SessionReminderEntity(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      templateId: templateId ?? this.templateId,
      template: template ?? this.template,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      customMessage: customMessage ?? this.customMessage,
      isEnabled: isEnabled ?? this.isEnabled,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      sentAt: sentAt ?? this.sentAt,
      errorMessage: errorMessage ?? this.errorMessage,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets the effective message to display/send
  String getEffectiveMessage({
    required String sessionTitle,
    required String sessionTime,
    String? sessionSubject,
  }) {
    if (customMessage != null && customMessage!.isNotEmpty) {
      return customMessage!
          .replaceAll('{session_title}', sessionTitle)
          .replaceAll('{session_time}', sessionTime)
          .replaceAll('{session_subject}', sessionSubject ?? 'Study Session');
    }

    if (template != null) {
      return template!.interpolateMessage(
        sessionTitle: sessionTitle,
        sessionTime: sessionTime,
        sessionSubject: sessionSubject,
      );
    }

    // Fallback message
    return 'Your study session "$sessionTitle" starts in ${_formatDuration(offsetMinutes)}!';
  }

  /// Formats the offset time as a human-readable string
  String get formattedOffset {
    return _formatDuration(offsetMinutes);
  }

  /// Helper to format duration
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) {
        return hours == 1 ? '1 hour' : '$hours hours';
      } else {
        return '${hours}h ${mins}m';
      }
    } else {
      final days = minutes ~/ 1440;
      return days == 1 ? '1 day' : '$days days';
    }
  }

  /// Gets the display name for this reminder
  String get displayName {
    if (template != null) {
      return template!.name;
    }
    return 'Custom reminder ($formattedOffset before)';
  }

  /// Checks if this reminder is ready to be sent
  bool get isReadyToSend {
    if (!isEnabled || deliveryStatus != ReminderDeliveryStatus.pending) {
      return false;
    }

    if (scheduledTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.isAfter(scheduledTime!) || now.isAtSameMomentAs(scheduledTime!);
  }

  /// Checks if this reminder is overdue (should have been sent but wasn't)
  bool get isOverdue {
    if (!isEnabled || 
        deliveryStatus != ReminderDeliveryStatus.pending ||
        scheduledTime == null) {
      return false;
    }

    final now = DateTime.now();
    final overdueThreshold = scheduledTime!.add(const Duration(minutes: 5));
    return now.isAfter(overdueThreshold);
  }

  /// Gets the time remaining until this reminder should be sent
  Duration? get timeUntilSend {
    if (scheduledTime == null || deliveryStatus != ReminderDeliveryStatus.pending) {
      return null;
    }

    final now = DateTime.now();
    if (now.isAfter(scheduledTime!)) {
      return Duration.zero;
    }

    return scheduledTime!.difference(now);
  }

  /// Gets an appropriate status color for UI display
  String get statusColor {
    switch (deliveryStatus) {
      case ReminderDeliveryStatus.pending:
        return isOverdue ? 'warning' : 'info';
      case ReminderDeliveryStatus.sent:
        return 'success';
      case ReminderDeliveryStatus.failed:
        return 'error';
      case ReminderDeliveryStatus.cancelled:
        return 'neutral';
    }
  }

  /// Gets a human-readable status description
  String get statusDescription {
    switch (deliveryStatus) {
      case ReminderDeliveryStatus.pending:
        if (isOverdue) {
          return 'Overdue';
        } else if (scheduledTime != null) {
          final timeLeft = timeUntilSend;
          if (timeLeft != null && timeLeft.inMinutes > 0) {
            return 'Scheduled in ${_formatDuration(timeLeft.inMinutes)}';
          }
          return 'Ready to send';
        }
        return 'Pending';
      case ReminderDeliveryStatus.sent:
        return sentAt != null ? 'Sent' : 'Delivered';
      case ReminderDeliveryStatus.failed:
        return 'Failed';
      case ReminderDeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Marks this reminder as sent
  SessionReminderEntity markAsSent({
    DateTime? sentTime,
    String? notificationId,
  }) {
    return copyWith(
      deliveryStatus: ReminderDeliveryStatus.sent,
      sentAt: sentTime ?? DateTime.now(),
      notificationId: notificationId,
      errorMessage: null, // Clear any previous error
    );
  }

  /// Marks this reminder as failed
  SessionReminderEntity markAsFailed({required String error}) {
    return copyWith(
      deliveryStatus: ReminderDeliveryStatus.failed,
      errorMessage: error,
    );
  }

  /// Marks this reminder as cancelled
  SessionReminderEntity markAsCancelled() {
    return copyWith(
      deliveryStatus: ReminderDeliveryStatus.cancelled,
      errorMessage: null,
    );
  }

  /// Enables or disables this reminder
  SessionReminderEntity setEnabled(bool enabled) {
    return copyWith(isEnabled: enabled);
  }

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        templateId,
        template,
        offsetMinutes,
        customMessage,
        isEnabled,
        scheduledTime,
        deliveryStatus,
        sentAt,
        errorMessage,
        notificationId,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'SessionReminderEntity{'
        'id: $id, '
        'sessionId: $sessionId, '
        'offsetMinutes: $offsetMinutes, '
        'isEnabled: $isEnabled, '
        'deliveryStatus: $deliveryStatus, '
        'scheduledTime: $scheduledTime'
        '}';
  }
} 