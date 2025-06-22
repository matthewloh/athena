import 'dart:async';
import 'package:athena/features/review/data/models/quiz_item_model.dart';
import 'package:athena/features/review/data/models/quiz_model.dart';

abstract class ReviewRemoteDataSource {
  // Quiz operations
  Future<List<QuizModel>> getAllQuizzes(String userId);
  Future<QuizModel> getQuizById(String quizId);
  Future<QuizModel> createQuiz(QuizModel quiz);
  Future<QuizModel> updateQuiz(QuizModel quiz);
  Future<void> deleteQuiz(String quizId);
  Future<QuizModel> generateAiQuiz(String? studyMaterialId);
  // Quiz item operations
  Future<List<QuizItemModel>> getAllQuizItems(String quizId);
  Future<QuizItemModel> getQuizItemById(String itemId);
  Future<QuizItemModel> createQuizItem(QuizItemModel quizItem);
  Future<QuizItemModel> updateQuizItem(QuizItemModel quizItem);
  Future<void> deleteQuizItem(String itemId);
}