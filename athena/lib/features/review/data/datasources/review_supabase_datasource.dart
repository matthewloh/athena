import 'dart:async';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/review/data/datasources/review_remote_datasource.dart';
import 'package:athena/features/review/data/models/quiz_item_model.dart';
import 'package:athena/features/review/data/models/quiz_model.dart';
import 'package:athena/features/review/data/models/review_response_model.dart';
import 'package:athena/features/review/data/models/review_session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewSupabaseDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ReviewSupabaseDataSourceImpl(this._supabaseClient);

  // Quiz operations
  @override
  Future<List<QuizModel>> getAllQuizzes(String userId) async {
    try {
      final response = await _supabaseClient
          .from('quizzes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuizModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizModel> getQuizById(String quizId) async {
    try {
      final response =
          await _supabaseClient
              .from('quizzes')
              .select()
              .eq('id', quizId)
              .single();

      return QuizModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizModel> createQuiz(QuizModel quiz) async {
    try {
      final response =
          await _supabaseClient
              .from('quizzes')
              .insert(quiz.toInsertJson())
              .select()
              .single();

      return QuizModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizModel> updateQuiz(QuizModel quiz) async {
    try {
      final response =
          await _supabaseClient
              .from('quizzes')
              .update(quiz.toUpdateJson())
              .eq('id', quiz.id)
              .select()
              .single();

      return QuizModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _supabaseClient.from('quizzes').delete().eq('id', quizId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizModel> generateAiQuiz(String? studyMaterialId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'generate-quiz-questions',
        body: {'studyMaterialId': studyMaterialId},
      );

      return response.data['quiz'] != null
          ? QuizModel.fromJson(response.data['quiz'])
          : throw ServerException('No quiz generated');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Quiz item operations
  @override
  Future<List<QuizItemModel>> getAllQuizItems(String quizId) async {
    try {
      final response = await _supabaseClient
          .from('quiz_items')
          .select()
          .eq('quiz_id', quizId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuizItemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizItemModel> getQuizItemById(String itemId) {
    try {
      final response =
          _supabaseClient.from('quiz_items').select().eq('id', itemId).single();

      return response.then((json) => QuizItemModel.fromJson(json));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizItemModel> createQuizItem(QuizItemModel quizItem) async {
    try {
      final response =
          await _supabaseClient
              .from('quiz_items')
              .insert(quizItem.toInsertJson())
              .select()
              .single();

      return QuizItemModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizItemModel> updateQuizItem(QuizItemModel quizItem) async {
    try {
      final response =
          await _supabaseClient
              .from('quiz_items')
              .update(quizItem.toUpdateJson())
              .eq('id', quizItem.id)
              .select()
              .single();

      return QuizItemModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteQuizItem(String itemId) async {
    try {
      await _supabaseClient.from('quiz_items').delete().eq('id', itemId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Review session operations
  @override
  Future<List<ReviewSessionModel>> getAllReviewSessions(String quizId) async {
    try {
      final response = await _supabaseClient
          .from('review_sessions')
          .select()
          .eq('quiz_id', quizId)
          .order('started_at', ascending: false);

      return (response as List)
          .map((json) => ReviewSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReviewSessionModel> getReviewSessionById(String sessionId) async {
    try {
      final response =
          await _supabaseClient
              .from('review_sessions')
              .select()
              .eq('id', sessionId)
              .single();

      return ReviewSessionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReviewSessionModel> createReviewSession(
    ReviewSessionModel session,
  ) async {
    try {
      final response =
          await _supabaseClient
              .from('review_sessions')
              .insert(session.toInsertJson())
              .select()
              .single();

      return ReviewSessionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReviewSessionModel> updateReviewSession(
    ReviewSessionModel session,
  ) async {
    try {
      final response =
          await _supabaseClient
              .from('review_sessions')
              .update(session.toUpdateJson())
              .eq('id', session.id)
              .select()
              .single();

      return ReviewSessionModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteReviewSession(String sessionId) async {
    try {
      await _supabaseClient
          .from('review_sessions')
          .delete()
          .eq('id', sessionId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // Review response operations
  @override
  Future<List<ReviewResponseModel>> getAllReviewResponses(String quizId) async {
    try {
      final response = await _supabaseClient
          .from('review_responses')
          .select()
          .eq('quiz_id', quizId)
          .order('responded_at', ascending: false);

      return (response as List)
          .map((json) => ReviewResponseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReviewResponseModel> getReviewResponseById(String responseId) async {
    try {
      final response =
          await _supabaseClient
              .from('review_responses')
              .select()
              .eq('id', responseId)
              .single();

      return ReviewResponseModel.fromJson(response);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReviewResponseModel> createReviewResponse(
    ReviewResponseModel response,
  ) async {
    try {
      final responseJson =
          await _supabaseClient
              .from('review_responses')
              .insert(response.toInsertJson())
              .select()
              .single();

      return ReviewResponseModel.fromJson(responseJson);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReviewResponseModel> updateReviewResponse(
    ReviewResponseModel response,
  ) async {
    try {
      final responseJson =
          await _supabaseClient
              .from('review_responses')
              .update(response.toUpdateJson())
              .eq('id', response.id)
              .select()
              .single();

      return ReviewResponseModel.fromJson(responseJson);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteReviewResponse(String responseId) async {
    try {
      await _supabaseClient
          .from('review_responses')
          .delete()
          .eq('id', responseId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
