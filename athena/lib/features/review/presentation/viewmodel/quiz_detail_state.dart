import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_detail_state.freezed.dart';

@freezed
abstract class QuizDetailState with _$QuizDetailState {
  const QuizDetailState._();

  const factory QuizDetailState({
    // Core data
    QuizEntity? quiz,
    @Default([]) List<QuizItemEntity> quizItems,
    @Default([]) List<ReviewSessionEntity> sessionHistory,

    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingItems,
    @Default(false) bool isLoadingHistory,
    @Default(false) bool isRefreshing,

    // Error handling
    String? error,

    // Statistics
    @Default(0) int totalItems,
    @Default(0) int dueItems,
    @Default(0) int masteredItems,
    @Default(0.0) double accuracy,
    @Default(0) int totalReviews,
    @Default(0) int streak,

    // UI states
    @Default(0) int selectedTabIndex,
  }) = _QuizDetailState;

  // Computed properties
  bool get hasError => error != null;
  bool get hasQuiz => quiz != null;
  bool get hasItems => quizItems.isNotEmpty;
  bool get hasSessionHistory => sessionHistory.isNotEmpty;
  bool get hasDueItems => dueItems > 0;
  bool get hasAnyLoading => isLoading || isLoadingItems || isLoadingHistory || isRefreshing;

  // Get mastery percentage (performance-based learning progress)
  double get masteryPercentage {
    if (totalItems == 0) return 0.0;
    return accuracy; // Use accuracy as the mastery indicator
  }

  // Get review progress percentage (progress through current due items)
  double get reviewProgress {
    if (totalItems == 0) return 0.0;
    
    // If no items are due, today's review is complete
    if (dueItems == 0) return 1.0;
    
    // Show progress as: items reviewed today / (items reviewed today + items still due)
    final itemsReviewedToday = _getItemsReviewedToday();
    final totalItemsNeedingAttention = itemsReviewedToday + dueItems;
    
    if (totalItemsNeedingAttention == 0) return 0.0;
    
    return itemsReviewedToday / totalItemsNeedingAttention;
  }

  // Get formatted accuracy
  String get formattedAccuracy {
    if (!hasReviewedItems) return 'N/A';
    return '${(accuracy * 100).toInt()}%';
  }

  // Check if any items have been reviewed
  bool get hasReviewedItems => quizItems.any((item) => item.repetitions > 0);

  // Get count of reviewed items
  int get reviewedItemsCount =>
      quizItems.where((item) => item.repetitions > 0).length;

  // Get items by difficulty level
  List<QuizItemEntity> get easyItems =>
      quizItems.where((item) => item.easinessFactor >= 2.5).toList();

  List<QuizItemEntity> get hardItems =>
      quizItems.where((item) => item.easinessFactor < 2.0).toList();

  // Helper method to count items reviewed today
  int _getItemsReviewedToday() {
    final today = DateTime.now();
    return sessionHistory
        .where((session) => _isSameDay(session.startedAt, today))
        .fold(0, (sum, session) => sum + session.completedItems);
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Get next review date (earliest future review, not past due items)
  DateTime? get nextReviewDate {
    if (quizItems.isEmpty) return null;

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final futureReviews =
        quizItems.map((item) => item.nextReviewDate).where((date) {
          final dateOnly = DateTime(date.year, date.month, date.day);
          return dateOnly.isAfter(todayDateOnly) ||
              dateOnly.isAtSameMomentAs(todayDateOnly);
        }).toList();

    if (futureReviews.isEmpty) return null;

    return futureReviews.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  // Check if quiz is ready for review
  bool get isReadyForReview => dueItems > 0;
}
