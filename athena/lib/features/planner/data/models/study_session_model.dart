import 'package:athena/features/planner/domain/entities/study_session_entity.dart';

/// Data Transfer Object for StudySession - handles JSON serialization for Supabase
class StudySessionModel extends StudySessionEntity {
  /// Constructs a StudySessionModel instance
  const StudySessionModel({
    required super.id,
    required super.userId,
    super.studyGoalId,
    required super.title,
    super.subject,
    required super.startTime,
    required super.endTime,
    super.status = StudySessionStatus.scheduled,
    super.reminderOffsetMinutes,
    super.notes,
    super.actualDurationMinutes,
    super.linkedMaterialId,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converts a StudySessionEntity to a StudySessionModel
  factory StudySessionModel.fromEntity(StudySessionEntity entity) {
    return StudySessionModel(
      id: entity.id,
      userId: entity.userId,
      studyGoalId: entity.studyGoalId,
      title: entity.title,
      subject: entity.subject,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      reminderOffsetMinutes: entity.reminderOffsetMinutes,
      notes: entity.notes,
      actualDurationMinutes: entity.actualDurationMinutes,
      linkedMaterialId: entity.linkedMaterialId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts this model to a StudySessionEntity
  StudySessionEntity toEntity() {
    return StudySessionEntity(
      id: id,
      userId: userId,
      studyGoalId: studyGoalId,
      title: title,
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      status: status,
      reminderOffsetMinutes: reminderOffsetMinutes,
      notes: notes,
      actualDurationMinutes: actualDurationMinutes,
      linkedMaterialId: linkedMaterialId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts a JSON map from Supabase to a StudySessionModel instance
  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      studyGoalId: json['study_goal_id'] as String?,
      title: json['title'] as String,
      subject: json['subject'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: _parseStatus(json['status'] as String),
      reminderOffsetMinutes: json['reminder_offset_minutes'] as int?,
      notes: json['notes'] as String?,
      actualDurationMinutes: json['actual_duration_minutes'] as int?,
      linkedMaterialId: json['linked_material_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a JSON map for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'study_goal_id': studyGoalId,
      'title': title,
      'subject': subject,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': _statusToString(status),
      'reminder_offset_minutes': reminderOffsetMinutes,
      'notes': notes,
      'actual_duration_minutes': actualDurationMinutes,
      'linked_material_id': linkedMaterialId,
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
  StudySessionModel copyWith({
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
    return StudySessionModel(
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

  /// Helper method to parse status from JSON string
  static StudySessionStatus _parseStatus(String statusString) {
    switch (statusString) {
      case 'scheduled':
        return StudySessionStatus.scheduled;
      case 'inProgress':
        return StudySessionStatus.inProgress;
      case 'completed':
        return StudySessionStatus.completed;
      case 'missed':
        return StudySessionStatus.missed;
      case 'cancelled':
        return StudySessionStatus.cancelled;
      default:
        return StudySessionStatus.scheduled;
    }
  }

  /// Helper method to convert status to JSON string
  static String _statusToString(StudySessionStatus status) {
    switch (status) {
      case StudySessionStatus.scheduled:
        return 'scheduled';
      case StudySessionStatus.inProgress:
        return 'inProgress';
      case StudySessionStatus.completed:
        return 'completed';
      case StudySessionStatus.missed:
        return 'missed';
      case StudySessionStatus.cancelled:
        return 'cancelled';
    }
  }
}
