import 'package:equatable/equatable.dart';

enum QuizItemType { flashcard, multipleChoice }

class QuizItemEntity extends Equatable {
  final String id;
  final String quizId;
  final String userId;
  // Basic quiz item fields
  final QuizItemType itemType;
  final String questionText;
  final String answerText;
  // Multiple choice specific fields (nullable for flashcards)
  final Map<String, dynamic>? mcqOptions;
  final String? mcqCorrectOptionKey;
  // Spaced repetition algorithm fields
  final double easinessFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime lastReviewedAt;
  final DateTime nextReviewDate;
  // Metadata and timestamps
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizItemEntity({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.itemType,
    required this.questionText,
    required this.answerText,
    this.mcqOptions,
    this.mcqCorrectOptionKey,
    required this.easinessFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.lastReviewedAt,
    required this.nextReviewDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

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

  QuizItemEntity copyWith({
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
    return QuizItemEntity(
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
