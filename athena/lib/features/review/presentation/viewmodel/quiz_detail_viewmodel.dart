import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:athena/features/review/presentation/viewmodel/quiz_detail_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_detail_viewmodel.g.dart';

@riverpod
class QuizDetailViewModel extends _$QuizDetailViewModel {
  @override
  QuizDetailState build(String quizId) {
    // Load quiz data when the provider is first created
    Future.microtask(() => _loadQuizData(quizId));

    return const QuizDetailState();
  }

  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  // Load quiz data
  Future<void> loadQuizData(String quizId) async {
    await _loadQuizData(quizId);
  }

  // Refresh quiz data
  Future<void> refreshQuizData(String quizId) async {
    state = state.copyWith(isRefreshing: true, error: null);
    await _loadQuizData(quizId);
  }

  // Internal method to load quiz data
  Future<void> _loadQuizData(String quizId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'User not authenticated',
      );
      return;
    }

    // Set loading state if not already refreshing
    if (!state.isRefreshing) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Load quiz details
      final getQuizDetailUseCase = ref.read(getQuizDetailUseCaseProvider);
      final quizResult = await getQuizDetailUseCase.call(quizId);

      await quizResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: 'Failed to load quiz: ${failure.message}',
          );
        },
        (quiz) async {
          // Load quiz items
          await _loadQuizItems(quiz);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Failed to load quiz data: ${e.toString()}',
      );
    }
  }

  // Load quiz items and calculate statistics
  Future<void> _loadQuizItems(QuizEntity quiz) async {
    state = state.copyWith(quiz: quiz, isLoadingItems: true);

    try {
      final getAllQuizItemsUseCase = ref.read(getAllQuizItemsUseCaseProvider);
      final itemsResult = await getAllQuizItemsUseCase.call(quiz.id);

      itemsResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            isLoadingItems: false,
            error: 'Failed to load quiz items: ${failure.message}',
          );
        },
        (items) {
          final stats = _calculateQuizStatistics(items);

          debugPrint('Quiz ${quiz.id}: loaded ${items.length} items');
          debugPrint(
            'Stats: ${stats.totalItems} total, ${stats.dueItems} due, ${stats.accuracy}% accuracy',
          );

          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            isLoadingItems: false,
            quizItems: items,
            totalItems: stats.totalItems,
            dueItems: stats.dueItems,
            masteredItems: stats.masteredItems,
            accuracy: stats.accuracy,
            totalReviews: stats.totalReviews,
            streak: stats.streak,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingItems: false,
        error: 'Failed to load quiz items: ${e.toString()}',
      );
    }
  }

  // Calculate comprehensive quiz statistics
  QuizStatistics _calculateQuizStatistics(List<QuizItemEntity> items) {
    if (items.isEmpty) {
      return const QuizStatistics();
    }

    final now = DateTime.now();

    // Count due items (items with next review date in the past)
    final dueItems =
        items.where((item) => item.nextReviewDate.isBefore(now)).length;

    // Count mastered items (items with high easiness factor and multiple repetitions)
    final masteredItems =
        items
            .where(
              (item) => item.easinessFactor >= 2.5 && item.repetitions >= 3,
            )
            .length;

    // Calculate overall accuracy based on easiness factors
    // Only consider items that have been reviewed at least once (repetitions > 0)
    // Uses SM-2 algorithm range (1.3-4.0) mapped to accuracy percentage (0-100%)
    // Higher easiness factor indicates better performance/accuracy
    final reviewedItems = items.where((item) => item.repetitions > 0).toList();

    double accuracy = 0.0;
    if (reviewedItems.isNotEmpty) {
      final avgEasinessFactor =
          reviewedItems.fold<double>(
            0,
            (sum, item) => sum + item.easinessFactor,
          ) /
          reviewedItems.length;

      // Convert easiness factor to accuracy percentage (1.3-4.0 range mapped to 0-100%)
      accuracy = ((avgEasinessFactor - 1.3) / (4.0 - 1.3)).clamp(0.0, 1.0);
    }
    // If no items have been reviewed, accuracy remains 0.0

    // Calculate total reviews (sum of all repetitions)
    final totalReviews = items.fold<int>(
      0,
      (sum, item) => sum + item.repetitions,
    );

    // Calculate current streak (consecutive days with reviews)
    // TODO: This should be calculated from actual review session data when available
    final streak = _calculateStreakFromItems(items);

    return QuizStatistics(
      totalItems: items.length,
      dueItems: dueItems,
      masteredItems: masteredItems,
      accuracy: accuracy,
      totalReviews: totalReviews,
      streak: streak,
    );
  }

  // Calculate streak from items (simplified version)
  int _calculateStreakFromItems(List<QuizItemEntity> items) {
    // TODO: Replace with actual review session data when available
    // For now, return a simple calculation based on recent reviews
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    final recentlyReviewed =
        items.where((item) => item.lastReviewedAt.isAfter(oneDayAgo)).length;

    return recentlyReviewed > 0 ? 1 : 0;
  }

  // UI interaction methods
  void setSelectedTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Delete quiz and handle navigation
  Future<void> deleteQuiz(String quizId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final deleteQuizUseCase = ref.read(deleteQuizUseCaseProvider);
      final result = await deleteQuizUseCase.call(quizId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to delete quiz: ${failure.message}',
          );
        },
        (_) {
          // Quiz deleted successfully
          // The state will be disposed when navigating away, so no need to update it
          debugPrint('Quiz $quizId deleted successfully');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete quiz: ${e.toString()}',
      );
    }
  }
}

// Helper class for statistics calculation
class QuizStatistics {
  final int totalItems;
  final int dueItems;
  final int masteredItems;
  final double accuracy;
  final int totalReviews;
  final int streak;

  const QuizStatistics({
    this.totalItems = 0,
    this.dueItems = 0,
    this.masteredItems = 0,
    this.accuracy = 0.0,
    this.totalReviews = 0,
    this.streak = 0,
  });
}
