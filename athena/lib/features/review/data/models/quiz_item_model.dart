import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';

class QuizItemModel extends QuizItemEntity {
  /// Creates a [QuizItemModel] instance.
  const QuizItemModel({
    required super.id,
    required super.quizId,
    required super.userId,
    required super.itemType,
    required super.questionText,
    required super.answerText,
    super.mcqOptions,
    super.mcqCorrectOptionKey,
    required super.easinessFactor,
    required super.intervalDays,
    required super.repetitions,
    required super.lastReviewedAt,
    required super.nextReviewDate,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory constructor to create a [QuizItemModel] from a [QuizItemEntity].
  factory QuizItemModel.fromEntity(QuizItemEntity entity) {
    return QuizItemModel(
      id: entity.id,
      quizId: entity.quizId,
      userId: entity.userId,
      itemType: entity.itemType,
      questionText: entity.questionText,
      answerText: entity.answerText,
      mcqOptions: entity.mcqOptions,
      mcqCorrectOptionKey: entity.mcqCorrectOptionKey,
      easinessFactor: entity.easinessFactor,
      intervalDays: entity.intervalDays,
      repetitions: entity.repetitions,
      lastReviewedAt: entity.lastReviewedAt,
      nextReviewDate: entity.nextReviewDate,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts the [QuizItemModel] to a [QuizItemEntity].
  QuizItemEntity toEntity() {
    return QuizItemEntity(
      id: id,
      quizId: quizId,
      userId: userId,
      itemType: itemType,
      questionText: questionText,
      answerText: answerText,
      mcqOptions: mcqOptions,
      mcqCorrectOptionKey: mcqCorrectOptionKey,
      easinessFactor: easinessFactor,
      intervalDays: intervalDays,
      repetitions: repetitions,
      lastReviewedAt: lastReviewedAt,
      nextReviewDate: nextReviewDate,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Factory constructor to create a [QuizItemModel] from JSON.
  factory QuizItemModel.fromJson(Map<String, dynamic> json) {
    return QuizItemModel(
      id: json['id'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      itemType:
          json['item_type'] != null
              ? QuizItemType.values.firstWhere(
                (e) => e.name == json['item_type'],
                orElse: () => QuizItemType.flashcard,
              )
              : QuizItemType.flashcard,
      questionText: json['question_text'],
      answerText: json['answer_text'],
      mcqOptions:
          json['mcq_options'] != null
              ? Map<String, dynamic>.from(json['mcq_options'])
              : null,
      mcqCorrectOptionKey: json['mcq_correct_option_key'],
      easinessFactor: (json['easiness_factor'] as num).toDouble(),
      intervalDays: json['interval_days'],
      repetitions: json['repetitions'],
      lastReviewedAt: DateTime.parse(json['last_reviewed_at']),
      nextReviewDate:
          json['next_review_date'] is String
              ? DateTime.parse(json['next_review_date'])
              : DateTime.parse(json['next_review_date'].toString()),
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'])
              : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Converts the [QuizItemModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'item_type': itemType.name,
      'question_text': questionText,
      'answer_text': answerText,
      'mcq_options': mcqOptions,
      'mcq_correct_option_key': mcqCorrectOptionKey,
      'easiness_factor': easinessFactor,
      'interval_days': intervalDays,
      'repetitions': repetitions,
      'last_reviewed_at': lastReviewedAt.toIso8601String(),
      'next_review_date':
          '${nextReviewDate.year}-${nextReviewDate.month.toString().padLeft(2, '0')}-${nextReviewDate.day.toString().padLeft(2, '0')}',
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts the [QuizItemModel] to a JSON map for insertion.
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  /// Converts the [QuizItemModel] to a JSON map for updates.
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  /// Overrides the equality operator to compare [QuizItemModel] instances.
  @override
  List<Object?> get props => [
    id,
    quizId,
    userId,
    itemType,
    questionText,
    answerText,
    mcqOptions,
    mcqCorrectOptionKey,
    easinessFactor,
    intervalDays,
    repetitions,
    lastReviewedAt,
    nextReviewDate,
    metadata,
    createdAt,
    updatedAt,
  ];

  /// Creates a copy of the [QuizItemModel] with optional new values.
  @override
  QuizItemModel copyWith({
    String? id,
    String? quizId,
    String? userId,
    QuizItemType? itemType,
    String? questionText,
    String? answerText,
    Map<String, dynamic>? mcqOptions,
    String? mcqCorrectOptionKey,
    double? easinessFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? lastReviewedAt,
    DateTime? nextReviewDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizItemModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      mcqOptions: mcqOptions ?? this.mcqOptions,
      mcqCorrectOptionKey: mcqCorrectOptionKey ?? this.mcqCorrectOptionKey,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
