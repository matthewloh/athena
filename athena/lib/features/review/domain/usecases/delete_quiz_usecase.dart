import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting a quiz and all its associated data.
///
/// This use case handles the complete deletion of a quiz including:
/// - The quiz itself
/// - All associated quiz items (automatically via CASCADE)
/// - All review responses linked to the quiz items (automatically via CASCADE)
/// - Review sessions will have their quiz_id set to NULL but remain for historical data
///
/// The database schema is configured with proper CASCADE relationships:
/// - quiz_items.quiz_id → quizzes.id (ON DELETE CASCADE)
/// - review_responses.quiz_item_id → quiz_items.id (ON DELETE CASCADE)
/// - review_sessions.quiz_id → quizzes.id (ON DELETE SET NULL)
///
/// This ensures data integrity while preserving historical session data.
class DeleteQuizUseCase {
  final ReviewRepository _repository;

  DeleteQuizUseCase(this._repository);

  /// Deletes a quiz and all its associated data.
  ///
  /// [quizId] - The ID of the quiz to delete
  ///
  /// Returns Either<Failure, void> indicating success or failure
  ///
  /// The deletion will automatically cascade to:
  /// - All quiz items belonging to this quiz
  /// - All review responses for those quiz items
  /// - Review sessions will keep historical data but lose quiz reference
  Future<Either<Failure, void>> call(String quizId) async {
    // Validate input
    if (quizId.trim().isEmpty) {
      return Left(ServerFailure('Quiz ID cannot be empty'));
    }

    // Delegate to repository which handles the actual deletion
    // The database CASCADE constraints will handle related data cleanup
    return _repository.deleteQuiz(quizId);
  }
}
