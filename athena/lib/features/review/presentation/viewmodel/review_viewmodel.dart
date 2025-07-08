import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:athena/features/review/presentation/viewmodel/review_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_viewmodel.g.dart';

@riverpod
class ReviewViewModel extends _$ReviewViewModel {
  @override
  ReviewState build() {
    // Initialize with empty state
    final initialState = const ReviewState();

    // Listen to auth state changes
    ref.listen(appAuthProvider, (previous, next) {
      // Load quizzes when user becomes authenticated
      if (next.hasValue && next.value != null) {
        _loadQuizzes();
      }
    });

    // Try to load quizzes immediately if user is already authenticated
    final authState = ref.read(appAuthProvider);
    if (authState.hasValue && authState.value != null) {
      // Use a microtask to avoid calling setState during build
      Future.microtask(() => _loadQuizzes());
    }

    return initialState;
  }

  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  // Load all quizzes
  Future<void> loadQuizzes() async {
    await _loadQuizzes();
  }

  // Refresh quizzes
  Future<void> refreshQuizzes() async {
    debugPrint('ReviewViewModel: refreshQuizzes called');
    state = state.copyWith(isRefreshing: true, error: null);
    await _loadQuizzes();
  }

  // Internal method to load quizzes
  Future<void> _loadQuizzes() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'User not authenticated',
        showEmptyState: true,
      );
      return;
    }

    // Set loading state if not already refreshing
    if (!state.isRefreshing) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final useCase = ref.read(getAllQuizzesUseCaseProvider);
      final result = await useCase.call(userId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: failure.message,
            showEmptyState: state.quizzes.isEmpty,
          );
        },
        (quizzes) async {
          debugPrint('ReviewViewModel: loaded ${quizzes.length} quizzes');
          // Update quizzes first
          state = state.copyWith(
            isLoading: false,
            isRefreshing: false,
            error: null,
            quizzes: quizzes,
            totalQuizzes: quizzes.length,
            showEmptyState: quizzes.isEmpty,
          );

          // Load quiz items for each quiz
          if (quizzes.isNotEmpty) {
            await _loadQuizItems(quizzes);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Failed to load quizzes: ${e.toString()}',
        showEmptyState: state.quizzes.isEmpty,
      );
    }
  }

  // Load quiz items for all quizzes
  Future<void> _loadQuizItems(List<QuizEntity> quizzes) async {
    state = state.copyWith(isLoadingQuizItems: true);

    try {
      final getAllQuizItemsUseCase = ref.read(getAllQuizItemsUseCaseProvider);
      final Map<String, List<QuizItemEntity>> allQuizItems = {};
      final Map<String, QuizStats> allQuizStats = {};

      // Load items for each quiz
      for (final quiz in quizzes) {
        final result = await getAllQuizItemsUseCase.call(quiz.id);

        result.fold(
          (failure) {
            // Log error but continue with other quizzes
            // TODO: Use proper logging instead of print
            debugPrint(
              'Failed to load items for quiz ${quiz.id}: ${failure.message}',
            );
            allQuizItems[quiz.id] = [];
          },
          (items) {
            allQuizItems[quiz.id] = items;
            allQuizStats[quiz.id] = _calculateQuizStats(items);
            // Debug logging
            debugPrint('Quiz ${quiz.id}: loaded ${items.length} items');
          },
        );
      }
      // Debug logging
      final overallStats = _calculateOverallStats(allQuizItems, allQuizStats);

      debugPrint('=== Quiz Items Debug ===');
      debugPrint('Total quizzes: ${quizzes.length}');
      for (final entry in allQuizItems.entries) {
        debugPrint('Quiz ${entry.key}: ${entry.value.length} items');
      }
      debugPrint('Calculated total items: ${overallStats.totalItems}');
      debugPrint('Calculated due items: ${overallStats.dueItems}');
      debugPrint('========================');

      state = state.copyWith(
        isLoadingQuizItems: false,
        quizItems: allQuizItems,
        quizStats: allQuizStats,
        totalItems: overallStats.totalItems,
        dueItems: overallStats.dueItems,
        overallAccuracy: overallStats.accuracy,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuizItems: false,
        error: 'Failed to load quiz items: ${e.toString()}',
      );
    }
  }

  // Calculate statistics for a single quiz
  QuizStats _calculateQuizStats(List<QuizItemEntity> items) {
    if (items.isEmpty) {
      return const QuizStats();
    }

    final now = DateTime.now();
    final dueItems =
        items.where((item) => item.nextReviewDate.isBefore(now)).length;

    // Calculate accuracy based on easiness factor (rough approximation)
    // Only consider items that have been reviewed at least once (repetitions > 0)
    // Uses SM-2 algorithm range (1.3-3.0) mapped to accuracy percentage (0-100%)
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
      accuracy = ((avgEasinessFactor - 1.3) / (3.0 - 1.3)).clamp(0.0, 1.0);
    }
    // If no items have been reviewed, accuracy remains 0.0

    // Find most recent review
    DateTime? lastReviewed;
    for (final item in items) {
      if (lastReviewed == null || item.lastReviewedAt.isAfter(lastReviewed)) {
        lastReviewed = item.lastReviewedAt;
      }
    }

    return QuizStats(
      totalItems: items.length,
      dueItems: dueItems,
      accuracy: accuracy,
      lastReviewed: lastReviewed,
    );
  }

  // Calculate overall statistics across all quizzes
  ReviewStats _calculateOverallStats(
    Map<String, List<QuizItemEntity>> allQuizItems,
    Map<String, QuizStats> allQuizStats,
  ) {
    int totalItems = 0;
    int totalDueItems = 0;
    double totalAccuracy = 0.0;
    int quizzesWithItems = 0;

    for (final stats in allQuizStats.values) {
      totalItems += stats.totalItems;
      totalDueItems += stats.dueItems;
      if (stats.totalItems > 0) {
        totalAccuracy += stats.accuracy;
        quizzesWithItems++;
      }
    }

    final overallAccuracy =
        quizzesWithItems > 0 ? totalAccuracy / quizzesWithItems : 0.0;

    return ReviewStats(
      totalItems: totalItems,
      dueItems: totalDueItems,
      accuracy: overallAccuracy,
    );
  }

  // Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get quiz by ID
  QuizEntity? getQuizById(String quizId) {
    try {
      return state.quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Get quizzes by subject
  List<QuizEntity> getQuizzesBySubject(String subject) {
    return state.quizzes
        .where((quiz) => quiz.subject?.name == subject)
        .toList();
  }

  // Search quizzes by title
  List<QuizEntity> searchQuizzes(String query) {
    if (query.isEmpty) return state.quizzes;

    final lowercaseQuery = query.toLowerCase();
    return state.quizzes.where((quiz) {
      return quiz.title.toLowerCase().contains(lowercaseQuery) ||
          (quiz.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Sorting methods
  void setSortCriteria(QuizSortCriteria criteria) {
    // If same criteria is selected, toggle sort order
    if (state.sortCriteria == criteria) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      // Set new criteria with default descending order (except for title and subject)
      final defaultAscending =
          criteria == QuizSortCriteria.title ||
          criteria == QuizSortCriteria.subject;
      state = state.copyWith(
        sortCriteria: criteria,
        sortAscending: defaultAscending,
      );
    }
  }

  void toggleSortOrder() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }
}

// Helper class for statistics
class ReviewStats {
  final int totalItems;
  final int dueItems;
  final double accuracy;

  const ReviewStats({
    required this.totalItems,
    required this.dueItems,
    required this.accuracy,
  });
}
