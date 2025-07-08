import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:athena/features/planner/domain/repositories/planner_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for getting upcoming study sessions for a user
///
/// Returns sessions that are scheduled for today only,
/// useful for dashboard and home screen display.
class GetUpcomingSessionsUseCase {
  final PlannerRepository _repository;

  const GetUpcomingSessionsUseCase(this._repository);

  /// Executes the use case to get upcoming sessions for a user
  ///
  /// Gets sessions for today only (from start of today to end of today)
  /// to ensure all sessions for today are included regardless of current time
  ///
  /// [userId] - The ID of the user whose sessions to retrieve
  ///
  /// Returns: Either a Failure or a List of StudySessionEntity
  Future<Either<Failure, List<StudySessionEntity>>> call(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      return await _repository.getStudySessionsByDateRange(
        userId,
        startOfDay,
        endOfDay,
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to get upcoming sessions: ${e.toString()}'),
      );
    }
  }

  /// Get sessions for today specifically
  Future<Either<Failure, List<StudySessionEntity>>> getTodaySessions(
    String userId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay
          .add(const Duration(days: 1))
          .subtract(const Duration(microseconds: 1));

      return await _repository.getStudySessionsByDateRange(
        userId,
        startOfDay,
        endOfDay,
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to get today\'s sessions: ${e.toString()}'),
      );
    }
  }
}
