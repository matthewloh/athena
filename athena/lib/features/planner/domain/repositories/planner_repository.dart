import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/domain/entities/study_goal_entity.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:dartz/dartz.dart';

/// Repository interface defining all planner-related data operations
abstract class PlannerRepository {
  // ============================================================================
  // STUDY GOALS OPERATIONS
  // ============================================================================

  /// Gets all study goals for the given user ID
  Future<Either<Failure, List<StudyGoalEntity>>> getStudyGoals(String userId);

  /// Gets a specific study goal by its ID
  Future<Either<Failure, StudyGoalEntity>> getStudyGoalById(String goalId);

  /// Creates a new study goal
  Future<Either<Failure, StudyGoalEntity>> createStudyGoal(
    StudyGoalEntity goal,
  );

  /// Updates an existing study goal
  Future<Either<Failure, StudyGoalEntity>> updateStudyGoal(
    StudyGoalEntity goal,
  );

  /// Deletes a study goal by its ID
  Future<Either<Failure, void>> deleteStudyGoal(String goalId);

  /// Updates the progress of a specific goal
  Future<Either<Failure, StudyGoalEntity>> updateGoalProgress(
    String goalId,
    double progress,
  );

  /// Marks a goal as completed
  Future<Either<Failure, StudyGoalEntity>> markGoalCompleted(String goalId);

  // ============================================================================
  // STUDY SESSIONS OPERATIONS
  // ============================================================================

  /// Gets all study sessions for the given user ID
  Future<Either<Failure, List<StudySessionEntity>>> getStudySessions(
    String userId,
  );

  /// Gets study sessions for a specific date range
  Future<Either<Failure, List<StudySessionEntity>>> getStudySessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets sessions linked to a specific goal
  Future<Either<Failure, List<StudySessionEntity>>> getSessionsByGoal(
    String goalId,
  );

  /// Gets a specific study session by its ID
  Future<Either<Failure, StudySessionEntity>> getStudySessionById(
    String sessionId,
  );

  /// Creates a new study session
  Future<Either<Failure, StudySessionEntity>> createStudySession(
    StudySessionEntity session,
  );

  /// Updates an existing study session
  Future<Either<Failure, StudySessionEntity>> updateStudySession(
    StudySessionEntity session,
  );

  /// Deletes a study session by its ID
  Future<Either<Failure, void>> deleteStudySession(String sessionId);

  /// Updates the status of a study session
  Future<Either<Failure, StudySessionEntity>> updateSessionStatus(
    String sessionId,
    StudySessionStatus status,
  );

  /// Marks a session as completed with actual duration
  Future<Either<Failure, StudySessionEntity>> completeStudySession(
    String sessionId,
    int actualDurationMinutes,
  );

  // ============================================================================
  // ANALYTICS & INSIGHTS OPERATIONS
  // ============================================================================

  /// Gets upcoming sessions (next 7 days)
  Future<Either<Failure, List<StudySessionEntity>>> getUpcomingSessions(
    String userId,
  );

  /// Gets overdue sessions that haven't been completed
  Future<Either<Failure, List<StudySessionEntity>>> getOverdueSessions(
    String userId,
  );

  /// Gets sessions scheduled for today
  Future<Either<Failure, List<StudySessionEntity>>> getTodaySessions(
    String userId,
  );

  /// Gets goals that are nearing their target date
  Future<Either<Failure, List<StudyGoalEntity>>> getGoalsNearingDeadline(
    String userId,
    int daysThreshold,
  );

  /// Gets total study time for a specific period
  Future<Either<Failure, int>> getTotalStudyTimeForPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets completion rate for goals in a specific period
  Future<Either<Failure, double>> getGoalCompletionRate(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
}
