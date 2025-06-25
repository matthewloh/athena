import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/planner/data/datasources/planner_remote_datasource.dart';
import 'package:athena/features/planner/data/models/study_goal_model.dart';
import 'package:athena/features/planner/data/models/study_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete implementation of PlannerRemoteDataSource using Supabase
class PlannerSupabaseDataSourceImpl implements PlannerRemoteDataSource {
  final SupabaseClient _supabaseClient;

  const PlannerSupabaseDataSourceImpl(this._supabaseClient);

  // ============================================================================
  // STUDY GOALS OPERATIONS
  // ============================================================================

  @override
  Future<List<StudyGoalModel>> getStudyGoals(String userId) async {
    try {
      final response = await _supabaseClient
          .from('study_goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => StudyGoalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch study goals: ${e.toString()}');
    }
  }

  @override
  Future<StudyGoalModel> getStudyGoalById(String goalId) async {
    try {
      final response =
          await _supabaseClient
              .from('study_goals')
              .select()
              .eq('id', goalId)
              .single();

      return StudyGoalModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch study goal: ${e.toString()}');
    }
  }

  @override
  Future<StudyGoalModel> createStudyGoal(StudyGoalModel goal) async {
    try {
      final goalData = goal.toInsertJson();

      final response =
          await _supabaseClient
              .from('study_goals')
              .insert(goalData)
              .select()
              .single();

      return StudyGoalModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create study goal: ${e.toString()}');
    }
  }

  @override
  Future<StudyGoalModel> updateStudyGoal(StudyGoalModel goal) async {
    try {
      final goalData = goal.toUpdateJson();

      final response =
          await _supabaseClient
              .from('study_goals')
              .update(goalData)
              .eq('id', goal.id)
              .select()
              .single();

      return StudyGoalModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update study goal: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStudyGoal(String goalId) async {
    try {
      await _supabaseClient.from('study_goals').delete().eq('id', goalId);
    } catch (e) {
      throw ServerException('Failed to delete study goal: ${e.toString()}');
    }
  }

  // ============================================================================
  // STUDY SESSIONS OPERATIONS
  // ============================================================================

  @override
  Future<List<StudySessionModel>> getStudySessions(String userId) async {
    try {
      final response = await _supabaseClient
          .from('study_sessions')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => StudySessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch study sessions: ${e.toString()}');
    }
  }

  @override
  Future<List<StudySessionModel>> getStudySessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabaseClient
          .from('study_sessions')
          .select()
          .eq('user_id', userId)
          .gte('start_time', startDate.toIso8601String())
          .lte('start_time', endDate.toIso8601String())
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => StudySessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(
        'Failed to fetch sessions by date range: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<StudySessionModel>> getSessionsByGoal(String goalId) async {
    try {
      final response = await _supabaseClient
          .from('study_sessions')
          .select()
          .eq('study_goal_id', goalId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => StudySessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(
        'Failed to fetch sessions by goal: ${e.toString()}',
      );
    }
  }

  @override
  Future<StudySessionModel> getStudySessionById(String sessionId) async {
    try {
      final response =
          await _supabaseClient
              .from('study_sessions')
              .select()
              .eq('id', sessionId)
              .single();

      return StudySessionModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch study session: ${e.toString()}');
    }
  }

  @override
  Future<StudySessionModel> createStudySession(
    StudySessionModel session,
  ) async {
    try {
      final sessionData = session.toInsertJson();

      final response =
          await _supabaseClient
              .from('study_sessions')
              .insert(sessionData)
              .select()
              .single();

      return StudySessionModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to create study session: ${e.toString()}');
    }
  }

  @override
  Future<StudySessionModel> updateStudySession(
    StudySessionModel session,
  ) async {
    try {
      final sessionData = session.toUpdateJson();

      final response =
          await _supabaseClient
              .from('study_sessions')
              .update(sessionData)
              .eq('id', session.id)
              .select()
              .single();

      return StudySessionModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update study session: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteStudySession(String sessionId) async {
    try {
      await _supabaseClient.from('study_sessions').delete().eq('id', sessionId);
    } catch (e) {
      throw ServerException('Failed to delete study session: ${e.toString()}');
    }
  }
}
