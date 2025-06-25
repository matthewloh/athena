import 'package:equatable/equatable.dart';

/// Represents a scheduled study session in the domain layer
class StudySessionEntity extends Equatable {
  /// Unique identifier for the session
  final String id;

  /// User who owns this session
  final String userId;

  /// Optional goal this session is linked to
  final String? studyGoalId;

  /// Title/name of the study session
  final String title;

  /// Subject/topic this session focuses on (e.g., 'Mathematics', 'Biology')
  final String? subject;

  /// Scheduled start time for the session
  final DateTime startTime;

  /// Scheduled end time for the session
  final DateTime endTime;

  /// Current status of the session
  final StudySessionStatus status;

  /// How many minutes before the session to send a reminder
  final int? reminderOffsetMinutes;

  /// Optional notes about the session
  final String? notes;

  /// Actual duration spent studying (in minutes), set after completion
  final int? actualDurationMinutes;

  /// Optional link to a specific study material
  final String? linkedMaterialId;

  /// When this session was created
  final DateTime createdAt;

  /// When this session was last updated
  final DateTime updatedAt;

  const StudySessionEntity({
    required this.id,
    required this.userId,
    this.studyGoalId,
    required this.title,
    this.subject,
    required this.startTime,
    required this.endTime,
    this.status = StudySessionStatus.scheduled,
    this.reminderOffsetMinutes,
    this.notes,
    this.actualDurationMinutes,
    this.linkedMaterialId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this entity with the given fields replaced by new values
  StudySessionEntity copyWith({
    String? id,
    String? userId,
    String? studyGoalId,
    String? title,
    String? subject,
    DateTime? startTime,
    DateTime? endTime,
    StudySessionStatus? status,
    int? reminderOffsetMinutes,
    String? notes,
    int? actualDurationMinutes,
    String? linkedMaterialId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudySessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      studyGoalId: studyGoalId ?? this.studyGoalId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      notes: notes ?? this.notes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      linkedMaterialId: linkedMaterialId ?? this.linkedMaterialId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets the planned duration of this session in minutes
  int get plannedDurationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Gets the planned duration as a formatted string (e.g., "1h 30m")
  String get plannedDurationFormatted {
    final minutes = plannedDurationMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }

  /// Checks if the session is currently happening
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return status == StudySessionStatus.inProgress ||
        (status == StudySessionStatus.scheduled &&
            now.isAfter(startTime) &&
            now.isBefore(endTime));
  }

  /// Checks if the session is upcoming (starts within next 24 hours)
  bool get isUpcoming {
    if (status != StudySessionStatus.scheduled) return false;
    final now = DateTime.now();
    final timeUntilStart = startTime.difference(now);
    return timeUntilStart.inHours <= 24 && timeUntilStart.inMinutes > 0;
  }

  /// Checks if the session is overdue (scheduled time has passed but not completed)
  bool get isOverdue {
    if (status == StudySessionStatus.completed) return false;
    return DateTime.now().isAfter(endTime);
  }

  /// Gets time until session starts (null if already started or completed)
  Duration? get timeUntilStart {
    if (status != StudySessionStatus.scheduled) return null;
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return startTime.difference(now);
    }
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    studyGoalId,
    title,
    subject,
    startTime,
    endTime,
    status,
    reminderOffsetMinutes,
    notes,
    actualDurationMinutes,
    linkedMaterialId,
    createdAt,
    updatedAt,
  ];
}

/// Enum representing the possible states of a study session
enum StudySessionStatus {
  /// Session is scheduled for the future
  scheduled,

  /// Session is currently in progress
  inProgress,

  /// Session has been completed successfully
  completed,

  /// Session was missed (time passed without starting)
  missed,

  /// Session was cancelled by the user
  cancelled,
}

/// Extension to provide human-readable labels for session status
extension StudySessionStatusExtension on StudySessionStatus {
  String get displayName {
    switch (this) {
      case StudySessionStatus.scheduled:
        return 'Scheduled';
      case StudySessionStatus.inProgress:
        return 'In Progress';
      case StudySessionStatus.completed:
        return 'Completed';
      case StudySessionStatus.missed:
        return 'Missed';
      case StudySessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Gets an appropriate color for the status
  int get colorValue {
    switch (this) {
      case StudySessionStatus.scheduled:
        return 0xFF2196F3; // Blue
      case StudySessionStatus.inProgress:
        return 0xFFFF9800; // Orange
      case StudySessionStatus.completed:
        return 0xFF4CAF50; // Green
      case StudySessionStatus.missed:
        return 0xFFF44336; // Red
      case StudySessionStatus.cancelled:
        return 0xFF9E9E9E; // Grey
    }
  }
}
