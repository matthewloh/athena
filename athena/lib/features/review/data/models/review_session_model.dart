import 'package:athena/features/review/domain/entities/review_session_entity.dart';

class ReviewSessionModel extends ReviewSessionEntity {
  /// Creates a [ReviewSessionModel] instance.
  const ReviewSessionModel({
    required super.id,
    required super.userId,
    required super.quizId,
    required super.sessionType,
    required super.totalItems,
    required super.completedItems,
    required super.correctResponses,
    super.averageDifficulty,
    super.sessionDurationSeconds,
    required super.status,
    required super.startedAt,
    super.completedAt,
  });

  /// Factory constructor to create a [ReviewSessionModel] from a [ReviewSessionEntity].
  factory ReviewSessionModel.fromEntity(ReviewSessionEntity entity) {
    return ReviewSessionModel(
      id: entity.id,
      userId: entity.userId,
      quizId: entity.quizId,
      sessionType: entity.sessionType,
      totalItems: entity.totalItems,
      completedItems: entity.completedItems,
      correctResponses: entity.correctResponses,
      averageDifficulty: entity.averageDifficulty,
      sessionDurationSeconds: entity.sessionDurationSeconds,
      status: entity.status,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
    );
  }

  /// Converts the [ReviewSessionModel] to a [ReviewSessionEntity].
  ReviewSessionEntity toEntity() {
    return ReviewSessionEntity(
      id: id,
      userId: userId,
      quizId: quizId,
      sessionType: sessionType,
      totalItems: totalItems,
      completedItems: completedItems,
      correctResponses: correctResponses,
      averageDifficulty: averageDifficulty,
      sessionDurationSeconds: sessionDurationSeconds,
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Factory constructor to create a [ReviewSessionModel] from JSON.
  factory ReviewSessionModel.fromJson(Map<String, dynamic> json) {
    return ReviewSessionModel(
      id: json['id'],
      userId: json['user_id'],
      quizId: json['quiz_id'],
      sessionType: _parseSessionType(json['session_type']),
      totalItems: json['total_items'],
      completedItems: json['completed_items'],
      correctResponses: json['correct_responses'],
      averageDifficulty: (json['average_difficulty'] as num?)?.toDouble(),
      sessionDurationSeconds: json['session_duration_seconds'],
      status: _parseSessionStatus(json['status']),
      startedAt: DateTime.parse(json['started_at']),
      completedAt:
          json.containsKey('completed_at') && json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
    );
  }

  /// Converts the [ReviewSessionModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'session_type': sessionType.name,
      'total_items': totalItems,
      'completed_items': completedItems,
      'correct_responses': correctResponses,
      'average_difficulty': averageDifficulty,
      'session_duration_seconds': sessionDurationSeconds,
      'status': status.name,
      'started_at': startedAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  /// Converts the [ReviewSessionModel] to a JSON map for insertion.
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('started_at');
    return json;
  }

  /// Converts the [ReviewSessionModel] to a JSON map for updates.
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('started_at');
    return json;
  }

  /// Helper method to parse SessionType from string.
  static SessionType _parseSessionType(dynamic value) {
    if (value == null) return SessionType.mixed; // Default fallback
    if (value is SessionType) return value;

    final stringValue = value.toString().toLowerCase();
    switch (stringValue) {
      case 'mixed':
        return SessionType.mixed;
      case 'dueonly':
      case 'due_only':
        return SessionType.dueOnly;
      case 'newonly':
      case 'new_only':
        return SessionType.newOnly;
      default:
        return SessionType.mixed; // Default fallback
    }
  }

  /// Helper method to parse SessionStatus from string.
  static SessionStatus _parseSessionStatus(dynamic value) {
    if (value == null) return SessionStatus.active; // Default fallback
    if (value is SessionStatus) return value;

    final stringValue = value.toString().toLowerCase();
    switch (stringValue) {
      case 'active':
        return SessionStatus.active;
      case 'completed':
        return SessionStatus.completed;
      case 'abandoned':
        return SessionStatus.abandoned;
      default:
        return SessionStatus.active; // Default fallback
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    quizId,
    sessionType,
    totalItems,
    completedItems,
    correctResponses,
    averageDifficulty,
    sessionDurationSeconds,
    status,
    startedAt,
    completedAt,
  ];

  @override
  ReviewSessionModel copyWith({
    String? id,
    String? userId,
    String? quizId,
    SessionType? sessionType,
    int? totalItems,
    int? completedItems,
    int? correctResponses,
    double? averageDifficulty,
    int? sessionDurationSeconds,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ReviewSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      sessionType: sessionType ?? this.sessionType,
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
      correctResponses: correctResponses ?? this.correctResponses,
      averageDifficulty: averageDifficulty ?? this.averageDifficulty,
      sessionDurationSeconds:
          sessionDurationSeconds ?? this.sessionDurationSeconds,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
