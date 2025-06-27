import 'package:athena/features/review/domain/entities/review_response_entity.dart';

class ReviewResponseModel extends ReviewResponseEntity {
  /// Creates a [ReviewResponseModel] instance.
  const ReviewResponseModel({
    required super.id,
    required super.reviewSessionId,
    required super.quizItemId,
    required super.userId,
    required super.difficultyRating,
    super.responseTimeSeconds,
    super.userAnswer,
    super.isCorrect,
    super.previousEasinessFactor,
    super.previousIntervalDays,
    super.previousRepetitions,
    super.newEasinessFactor,
    super.newIntervalDays,
    super.newRepetitions,
    super.newNextReviewDate,
    required super.respondedAt,
  });

  /// Factory constructor to create a [ReviewResponseModel] from a [ReviewResponseEntity].
  factory ReviewResponseModel.fromEntity(ReviewResponseEntity entity) {
    return ReviewResponseModel(
      id: entity.id,
      reviewSessionId: entity.reviewSessionId,
      quizItemId: entity.quizItemId,
      userId: entity.userId,
      difficultyRating: entity.difficultyRating,
      responseTimeSeconds: entity.responseTimeSeconds,
      userAnswer: entity.userAnswer,
      isCorrect: entity.isCorrect,
      previousEasinessFactor: entity.previousEasinessFactor,
      previousIntervalDays: entity.previousIntervalDays,
      previousRepetitions: entity.previousRepetitions,
      newEasinessFactor: entity.newEasinessFactor,
      newIntervalDays: entity.newIntervalDays,
      newRepetitions: entity.newRepetitions,
      newNextReviewDate: entity.newNextReviewDate,
      respondedAt: entity.respondedAt,
    );
  }

  /// Converts the [ReviewResponseModel] to a [ReviewResponseEntity].
  ReviewResponseEntity toEntity() {
    return ReviewResponseEntity(
      id: id,
      reviewSessionId: reviewSessionId,
      quizItemId: quizItemId,
      userId: userId,
      difficultyRating: difficultyRating,
      responseTimeSeconds: responseTimeSeconds,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
      previousEasinessFactor: previousEasinessFactor,
      previousIntervalDays: previousIntervalDays,
      previousRepetitions: previousRepetitions,
      newEasinessFactor: newEasinessFactor,
      newIntervalDays: newIntervalDays,
      newRepetitions: newRepetitions,
      newNextReviewDate: newNextReviewDate,
      respondedAt: respondedAt,
    );
  }

  /// Factory constructor to create a [ReviewResponseModel] from JSON.
  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      id: json['id'],
      reviewSessionId: json['session_id'],
      quizItemId: json['quiz_item_id'],
      userId: json['user_id'],
      difficultyRating: DifficultyRating.values.firstWhere(
        (e) => e.name == json['difficulty_rating'],
        orElse: () => DifficultyRating.easy,
      ),
      responseTimeSeconds: json['response_time_seconds'],
      userAnswer: json['user_answer'],
      isCorrect: json['is_correct'],
      previousEasinessFactor:
          (json['previous_easiness_factor'] as num?)?.toDouble(),
      previousIntervalDays: json['previous_interval_days'],
      previousRepetitions: json['previous_repetitions'],
      newEasinessFactor: (json['new_easiness_factor'] as num?)?.toDouble(),
      newIntervalDays: json['new_interval_days'],
      newRepetitions: json['new_repetitions'],
      newNextReviewDate: DateTime.tryParse(json['new_next_review_date']),
      respondedAt: DateTime.parse(json['responded_at']),
    );
  }

  /// Converts the [ReviewResponseModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': reviewSessionId,
      'quiz_item_id': quizItemId,
      'user_id': userId,
      'difficulty_rating': difficultyRating.name,
      'response_time_seconds': responseTimeSeconds,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'previous_easiness_factor': previousEasinessFactor,
      'previous_interval_days': previousIntervalDays,
      'previous_repetitions': previousRepetitions,
      'new_easiness_factor': newEasinessFactor,
      'new_interval_days': newIntervalDays,
      'new_repetitions': newRepetitions,
      'new_next_review_date': newNextReviewDate?.toIso8601String(),
      'responded_at': respondedAt.toIso8601String(),
    };
  }

  /// Converts the [ReviewResponseModel] to a format suitable for insertion into a database.
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  @override
  List<Object?> get props => [
    id,
    reviewSessionId,
    quizItemId,
    userId,
    difficultyRating,
    responseTimeSeconds,
    userAnswer,
    isCorrect,
    previousEasinessFactor,
    previousIntervalDays,
    previousRepetitions,
    newEasinessFactor,
    newIntervalDays,
    newRepetitions,
    newNextReviewDate,
    respondedAt,
  ];

  @override
  ReviewResponseModel copyWith({
    String? id,
    String? reviewSessionId,
    String? quizItemId,
    String? userId,
    DifficultyRating? difficultyRating,
    int? responseTimeSeconds,
    String? userAnswer,
    bool? isCorrect,
    double? previousEasinessFactor,
    int? previousIntervalDays,
    int? previousRepetitions,
    double? newEasinessFactor,
    int? newIntervalDays,
    int? newRepetitions,
    DateTime? newNextReviewDate,
    DateTime? respondedAt,
  }) {
    return ReviewResponseModel(
      id: id ?? this.id,
      reviewSessionId: reviewSessionId ?? this.reviewSessionId,
      quizItemId: quizItemId ?? this.quizItemId,
      userId: userId ?? this.userId,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      previousEasinessFactor:
          previousEasinessFactor ?? this.previousEasinessFactor,
      previousIntervalDays: previousIntervalDays ?? this.previousIntervalDays,
      previousRepetitions: previousRepetitions ?? this.previousRepetitions,
      newEasinessFactor: newEasinessFactor ?? this.newEasinessFactor,
      newIntervalDays: newIntervalDays ?? this.newIntervalDays,
      newRepetitions: newRepetitions ?? this.newRepetitions,
      newNextReviewDate: newNextReviewDate ?? this.newNextReviewDate,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
