import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case to get quiz items that are due for review based on spaced repetition schedule.
///
/// This use case fetches items where the next_review_date is less than or equal to the current date.
/// Items are returned sorted by next_review_date (oldest first) to prioritize overdue items.
class GetDueItemsUseCase {
  final ReviewRepository _repository;

  GetDueItemsUseCase(this._repository);

  /// Executes the use case to get due items for a specific quiz.
  ///
  /// [quizId] - The ID of the quiz to get due items for
  /// [userId] - The ID of the current user (for security)
  /// [includeNew] - Whether to include new items (never reviewed) in the results
  /// [limit] - Optional limit on number of items to return
  ///
  /// Returns Either<Failure, List<QuizItemEntity>> with due items or failure
  Future<Either<Failure, List<QuizItemEntity>>> call(
    String quizId,
    String userId, {
    bool includeNew = true,
    int? limit,
  }) async {
    try {
      // Get all quiz items for the quiz
      final allItemsResult = await _repository.getAllQuizItems(quizId);

      return allItemsResult.fold((failure) => Left(failure), (allItems) {
        final now = DateTime.now();

        // Filter items that are due for review
        var dueItems =
            allItems.where((item) {
              // Check if item belongs to the requesting user
              if (item.userId != userId) return false;

              // Check if item is due (next review date <= now)
              final isDue =
                  item.nextReviewDate.isBefore(now) ||
                  item.nextReviewDate.isAtSameMomentAs(now);

              // Check if item is new (never reviewed) and should be included
              final isNew =
                  item.repetitions == 0 &&
                  item.lastReviewedAt == item.createdAt;

              return isDue || (includeNew && isNew);
            }).toList();

        // Sort by next review date (oldest first)
        dueItems.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

        // Apply limit if specified
        if (limit != null && limit > 0) {
          dueItems = dueItems.take(limit).toList();
        }

        return Right(dueItems);
      });
    } catch (e) {
      return Left(ServerFailure('Failed to get due items: ${e.toString()}'));
    }
  }

  /// Gets due items for multiple quizzes.
  ///
  /// [quizIds] - List of quiz IDs to get due items for
  /// [userId] - The ID of the current user
  /// [includeNew] - Whether to include new items
  /// [limit] - Optional limit on total number of items to return
  ///
  /// Returns Either<Failure, List<QuizItemEntity>> with due items from all quizzes
  Future<Either<Failure, List<QuizItemEntity>>> callMultiple(
    List<String> quizIds,
    String userId, {
    bool includeNew = true,
    int? limit,
  }) async {
    try {
      final List<QuizItemEntity> allDueItems = [];

      // Get due items from each quiz
      for (final quizId in quizIds) {
        final result = await call(quizId, userId, includeNew: includeNew);

        result.fold(
          (failure) =>
              throw Exception(
                'Failed to get due items for quiz $quizId: ${failure.message}',
              ),
          (dueItems) => allDueItems.addAll(dueItems),
        );
      }

      // Sort all items by next review date
      allDueItems.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));

      // Apply limit if specified
      if (limit != null && limit > 0) {
        return Right(allDueItems.take(limit).toList());
      }

      return Right(allDueItems);
    } catch (e) {
      return Left(
        ServerFailure(
          'Failed to get due items from multiple quizzes: ${e.toString()}',
        ),
      );
    }
  }
}
