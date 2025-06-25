import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_state.freezed.dart';

enum QuizSortCriteria {
  lastUpdated,
  title,
  itemCount,
  dueCount,
  accuracy,
  subject,
}

@freezed
abstract class ReviewState with _$ReviewState {
  const ReviewState._();

  const factory ReviewState({
    // Data
    @Default([]) List<QuizEntity> quizzes,
    @Default({})
    Map<String, List<QuizItemEntity>> quizItems, // Quiz ID -> List of items
    @Default({}) Map<String, QuizStats> quizStats, // Quiz ID -> Stats
    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingQuizItems,

    // Error handling
    String? error,

    // Overall stats
    @Default(0) int totalQuizzes,
    @Default(0) int totalItems,
    @Default(0) int dueItems,
    @Default(0.0) double overallAccuracy,

    // UI states
    @Default(false) bool showEmptyState,

    // Sorting
    @Default(QuizSortCriteria.lastUpdated) QuizSortCriteria sortCriteria,
    @Default(false) bool sortAscending,
  }) = _ReviewState;

  // Computed properties
  bool get hasError => error != null;
  bool get hasQuizzes => quizzes.isNotEmpty;
  bool get hasDueItems => dueItems > 0;
  bool get hasAnyLoading => isLoading || isRefreshing || isLoadingQuizItems;

  // Get formatted accuracy as percentage string
  String get formattedAccuracy => '${(overallAccuracy * 100).toInt()}%';

  // Get quizzes sorted by the current criteria
  List<QuizEntity> get sortedQuizzes {
    final sorted = [...quizzes];

    switch (sortCriteria) {
      case QuizSortCriteria.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case QuizSortCriteria.itemCount:
        sorted.sort(
          (a, b) => getQuizItemCount(b.id).compareTo(getQuizItemCount(a.id)),
        );
        break;
      case QuizSortCriteria.dueCount:
        sorted.sort(
          (a, b) => getQuizDueCount(b.id).compareTo(getQuizDueCount(a.id)),
        );
        break;
      case QuizSortCriteria.accuracy:
        sorted.sort((a, b) {
          final accuracyA = getQuizStats(a.id)?.accuracy ?? 0.0;
          final accuracyB = getQuizStats(b.id)?.accuracy ?? 0.0;
          return accuracyB.compareTo(accuracyA);
        });
        break;
      case QuizSortCriteria.subject:
        sorted.sort((a, b) {
          final subjectA = a.subject?.name ?? '';
          final subjectB = b.subject?.name ?? '';
          return subjectA.compareTo(subjectB);
        });
        break;
      case QuizSortCriteria.lastUpdated:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    // Reverse if ascending order is requested
    if (sortAscending) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  // Get item count for a specific quiz
  int getQuizItemCount(String quizId) {
    return quizItems[quizId]?.length ?? 0;
  }

  // Get due items count for a specific quiz
  int getQuizDueCount(String quizId) {
    final items = quizItems[quizId];
    if (items == null) return 0;

    final now = DateTime.now();
    return items.where((item) => item.nextReviewDate.isBefore(now)).length;
  }

  // Get stats for a specific quiz
  QuizStats? getQuizStats(String quizId) {
    return quizStats[quizId];
  }

  // Check if quiz was recently reviewed
  bool isQuizRecentlyReviewed(String quizId) {
    final items = quizItems[quizId];
    if (items == null || items.isEmpty) return false;

    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    return items.any((item) => item.lastReviewedAt.isAfter(oneDayAgo));
  }
}

// Helper class for quiz statistics
@freezed
abstract class QuizStats with _$QuizStats {
  const factory QuizStats({
    @Default(0) int totalItems,
    @Default(0) int dueItems,
    @Default(0.0) double accuracy,
    DateTime? lastReviewed,
  }) = _QuizStats;
}
