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
      quizId: json['quizId'],
      userId: json['userId'],
      itemType: QuizItemType.values.firstWhere(
        (e) => e.toString() == 'QuizItemType.${json['itemType']}',
      ),
      questionText: json['questionText'],
      answerText: json['answerText'],
      mcqOptions:
          json['mcqOptions'] != null
              ? Map<String, dynamic>.from(json['mcqOptions'])
              : null,
      mcqCorrectOptionKey: json['mcqCorrectOptionKey'],
      easinessFactor: (json['easinessFactor'] as num).toDouble(),
      intervalDays: json['intervalDays'],
      repetitions: json['repetitions'],
      lastReviewedAt: DateTime.parse(json['lastReviewedAt']),
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'])
              : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Converts the [QuizItemModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'userId': userId,
      'itemType': itemType.toString().split('.').last,
      'questionText': questionText,
      'answerText': answerText,
      'mcqOptions': mcqOptions,
      'mcqCorrectOptionKey': mcqCorrectOptionKey,
      'easinessFactor': easinessFactor,
      'intervalDays': intervalDays,
      'repetitions': repetitions,
      'lastReviewedAt': lastReviewedAt.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts the [QuizItemModel] to a JSON map for insertion.
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json.remove('updatedAt');
    return json;
  }

  /// Converts the [QuizItemModel] to a JSON map for updates.
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json.remove('updatedAt');
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
