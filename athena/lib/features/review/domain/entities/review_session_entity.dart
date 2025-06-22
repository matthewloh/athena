import 'package:equatable/equatable.dart';

enum SessionType { mixed, dueOnly, newOnly }

enum SessionStatus { active, completed, abandoned }

class ReviewSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String quizId;
  // Session metadata
  final SessionType sessionType;
  final int totalItems;
  final int completedItems;
  final int correctResponses;
  // Performance metrics
  final double? averageDifficulty;
  final int? sessionDurationSeconds;
  // Session status and timestamps
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;

  const ReviewSessionEntity({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.sessionType,
    required this.totalItems,
    required this.completedItems,
    required this.correctResponses,
    this.averageDifficulty,
    this.sessionDurationSeconds,
    required this.status,
    required this.startedAt,
    this.completedAt,
  });

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

  ReviewSessionEntity copyWith({
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
    return ReviewSessionEntity(
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
