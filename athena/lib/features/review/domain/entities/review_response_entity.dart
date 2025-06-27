import 'package:equatable/equatable.dart';

enum DifficultyRating {
  again,
  hard,
  good,
  easy,
}

class ReviewResponseEntity extends Equatable {
  final String id;
  final String reviewSessionId;
  final String quizItemId;
  final String userId;
  // Response data
  final DifficultyRating difficultyRating;
  final int? responseTimeSeconds;
  final String? userAnswer; // For MCQ: the selected option key, for flashcards: can be null
  final bool? isCorrect; // For MCQ: automatic, for flashcards: based on self-assessment
  // Previous spaced repetition values (for history/analytics)
  final double? previousEasinessFactor;
  final int? previousIntervalDays;
  final int? previousRepetitions;
  // New spaced repetition values (calculated after this response)
  final double? newEasinessFactor;
  final int? newIntervalDays;
  final int? newRepetitions;
  final DateTime? newNextReviewDate;
  // Timestamps
  final DateTime respondedAt;

  const ReviewResponseEntity({
    required this.id,
    required this.reviewSessionId,
    required this.quizItemId,
    required this.userId,
    required this.difficultyRating,
    this.responseTimeSeconds,
    this.userAnswer,
    this.isCorrect,
    this.previousEasinessFactor,
    this.previousIntervalDays,
    this.previousRepetitions,
    this.newEasinessFactor,
    this.newIntervalDays,
    this.newRepetitions,
    this.newNextReviewDate,
    required this.respondedAt,
  });

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

  ReviewResponseEntity copyWith({
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
    return ReviewResponseEntity(
      id: id ?? this.id,
      reviewSessionId: reviewSessionId ?? this.reviewSessionId,
      quizItemId: quizItemId ?? this.quizItemId,
      userId: userId ?? this.userId,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      previousEasinessFactor: previousEasinessFactor ?? this.previousEasinessFactor,
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
