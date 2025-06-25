import 'package:athena/features/planner/domain/entities/study_goal_entity.dart';

/// Data Transfer Object for StudyGoal - handles JSON serialization for Supabase
class StudyGoalModel extends StudyGoalEntity {
  /// Constructs a StudyGoalModel instance
  const StudyGoalModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.subject,
    super.targetDate,
    super.progress = 0.0,
    super.isCompleted = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converts a StudyGoalEntity to a StudyGoalModel
  factory StudyGoalModel.fromEntity(StudyGoalEntity entity) {
    return StudyGoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      subject: entity.subject,
      targetDate: entity.targetDate,
      progress: entity.progress,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model to a StudyGoalEntity
  StudyGoalEntity toEntity() {
    return StudyGoalEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      subject: subject,
      targetDate: targetDate,
      progress: progress,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts a JSON map from Supabase to a StudyGoalModel instance
  factory StudyGoalModel.fromJson(Map<String, dynamic> json) {
    return StudyGoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      subject: json['subject'] as String?,
      targetDate:
          json['target_date'] != null
              ? DateTime.parse(json['target_date'] as String)
              : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a JSON map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'subject': subject,
      'target_date': targetDate?.toIso8601String().split('T')[0], // Date only
      'progress': progress,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts to JSON for insert operations (excludes id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  /// Converts to JSON for update operations (excludes id, created_at, sets updated_at to now)
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  /// Creates a copy of this model with the given fields replaced
  @override
  StudyGoalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? subject,
    DateTime? targetDate,
    double? progress,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
