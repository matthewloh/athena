import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_results_state.freezed.dart';

/// State for the quiz results screen.
///
/// Contains session completion data and statistics from a completed review session.
@freezed
abstract class QuizResultsState with _$QuizResultsState {
  const factory QuizResultsState({
    // Session data
    ReviewSessionEntity? session,

    // Loading state
    @Default(false) bool isLoading,

    // Error state
    String? error,
  }) = _QuizResultsState;

  const QuizResultsState._();

  /// Whether we have session data
  bool get hasSession => session != null;

  /// Whether there was an error
  bool get hasError => error != null;

  /// Items reviewed in the session
  int get itemsReviewed => session?.totalItems ?? 0;

  /// Correct responses in the session
  int get correctResponses => session?.correctResponses ?? 0;

  /// Accuracy percentage calculated from session data
  double get accuracyPercentage {
    if (itemsReviewed == 0) return 0.0;
    return (correctResponses / itemsReviewed) * 100;
  }

  /// Session duration in seconds
  int get sessionDurationSeconds => session?.sessionDurationSeconds ?? 0;

  /// Average difficulty from session
  double get averageDifficulty => session?.averageDifficulty ?? 0.0;

  /// Formatted accuracy percentage as string
  String get formattedAccuracy => '${accuracyPercentage.toStringAsFixed(0)}%';

  /// Formatted session duration
  String get formattedDuration {
    final minutes = sessionDurationSeconds ~/ 60;
    final seconds = sessionDurationSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Formatted average confidence/performance score (1-4 scale)
  /// 1.0 = Forgot, 2.0 = Hard, 3.0 = Good, 4.0 = Easy
  String get formattedAverageConfidence =>
      averageDifficulty > 0 ? averageDifficulty.toStringAsFixed(1) : 'N/A';
}
