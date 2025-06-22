import 'dart:async';
import 'dart:io';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/review/data/datasources/review_remote_datasource.dart';
import 'package:athena/features/review/data/models/quiz_item_model.dart';
import 'package:athena/features/review/data/models/quiz_model.dart';
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
          .eq('userId', userId)
          .order('createdAt', ascending: false);

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
          .eq('quizId', quizId)
          .order('createdAt', ascending: false);

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
  Future<QuizItemModel> createQuizItem(QuizItemModel quizItem) {
    try {
      final response =
          _supabaseClient
              .from('quiz_items')
              .insert(quizItem.toInsertJson())
              .single();

      return response.then((json) => QuizItemModel.fromJson(json));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<QuizItemModel> updateQuizItem(QuizItemModel quizItem) {
    try {
      final response =
          _supabaseClient
              .from('quiz_items')
              .update(quizItem.toUpdateJson())
              .eq('id', quizItem.id)
              .single();

      return response.then((json) => QuizItemModel.fromJson(json));
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
}
