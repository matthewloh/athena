import 'package:equatable/equatable.dart';

/// Types of study goals
enum GoalType {
  academic,
  skills,
  career,
  personal,
  research;

  /// Display name for the goal type
  String get displayName {
    switch (this) {
      case GoalType.academic:
        return 'Academic';
      case GoalType.skills:
        return 'Skills';
      case GoalType.career:
        return 'Career';
      case GoalType.personal:
        return 'Personal';
      case GoalType.research:
        return 'Research';
    }
  }
}

/// Priority levels for study goals
enum PriorityLevel {
  high,
  medium,
  low;

  /// Display name for the priority level
  String get displayName {
    switch (this) {
      case PriorityLevel.high:
        return 'High';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.low:
        return 'Low';
    }
  }
}

/// Represents a long-term study objective in the domain layer
class StudyGoalEntity extends Equatable {
  /// Unique identifier for the goal
  final String id;

  /// User who owns this goal
  final String userId;

  /// Title/name of the study goal
  final String title;

  /// Optional detailed description of the goal
  final String? description;

  /// Subject/topic this goal relates to (e.g., 'Mathematics', 'Biology')
  final String? subject;

  /// Target completion date for this goal
  final DateTime? targetDate;

  /// Current progress (0.0 to 1.0, where 1.0 = 100% complete)
  final double progress;

  /// Whether this goal has been marked as completed
  final bool isCompleted;

  /// Type of study goal (academic, skills, career, personal, research)
  final GoalType goalType;

  /// Priority level of the goal (high, medium, low)
  final PriorityLevel priorityLevel;

  /// When this goal was created
  final DateTime createdAt;

  /// When this goal was last updated
  final DateTime updatedAt;

  const StudyGoalEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.subject,
    this.targetDate,
    this.progress = 0.0,
    this.isCompleted = false,
    this.goalType = GoalType.academic,
    this.priorityLevel = PriorityLevel.medium,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this entity with the given fields replaced by new values
  StudyGoalEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? subject,
    DateTime? targetDate,
    double? progress,
    bool? isCompleted,
    GoalType? goalType,
    PriorityLevel? priorityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyGoalEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      goalType: goalType ?? this.goalType,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates days remaining until target date
  int? get daysUntilTarget {
    if (targetDate == null) return null;
    final now = DateTime.now();
    final difference = targetDate!.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Gets progress as a percentage (0-100)
  int get progressPercentage => (progress * 100).round();

  /// Checks if the goal is overdue
  bool get isOverdue {
    if (targetDate == null || isCompleted) return false;
    return DateTime.now().isAfter(targetDate!);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    subject,
    targetDate,
    progress,
    isCompleted,
    goalType,
    priorityLevel,
    createdAt,
    updatedAt,
  ];
}
