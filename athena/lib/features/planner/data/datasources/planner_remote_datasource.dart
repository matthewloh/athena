import 'package:athena/features/planner/data/models/study_goal_model.dart';
import 'package:athena/features/planner/data/models/study_session_model.dart';

/// Abstract interface for remote data source operations
/// This will be implemented by SupabaseDataSourceImpl
abstract class PlannerRemoteDataSource {
  // ============================================================================
  // STUDY GOALS OPERATIONS
  // ============================================================================

  /// Gets all study goals for a user from remote database
  Future<List<StudyGoalModel>> getStudyGoals(String userId);

  /// Gets a specific study goal by ID from remote database
  Future<StudyGoalModel> getStudyGoalById(String goalId);

  /// Creates a new study goal in remote database
  Future<StudyGoalModel> createStudyGoal(StudyGoalModel goal);

  /// Updates an existing study goal in remote database
  Future<StudyGoalModel> updateStudyGoal(StudyGoalModel goal);

  /// Deletes a study goal from remote database
  Future<void> deleteStudyGoal(String goalId);

  // ============================================================================
  // STUDY SESSIONS OPERATIONS
  // ============================================================================

  /// Gets all study sessions for a user from remote database
  Future<List<StudySessionModel>> getStudySessions(String userId);

  /// Gets study sessions within a date range from remote database
  Future<List<StudySessionModel>> getStudySessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets sessions linked to a specific goal from remote database
  Future<List<StudySessionModel>> getSessionsByGoal(String goalId);

  /// Gets a specific study session by ID from remote database
  Future<StudySessionModel> getStudySessionById(String sessionId);

  /// Creates a new study session in remote database
  Future<StudySessionModel> createStudySession(StudySessionModel session);

  /// Updates an existing study session in remote database
  Future<StudySessionModel> updateStudySession(StudySessionModel session);

  /// Deletes a study session from remote database
  Future<void> deleteStudySession(String sessionId);
}
