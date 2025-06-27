import 'dart:async';
import 'package:athena/features/review/data/models/quiz_item_model.dart';
import 'package:athena/features/review/data/models/quiz_model.dart';
import 'package:athena/features/review/data/models/review_response_model.dart';
import 'package:athena/features/review/data/models/review_session_model.dart';

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
  // Review session operations
  Future<List<ReviewSessionModel>> getAllReviewSessions(String quizId);
  Future<ReviewSessionModel> getReviewSessionById(String sessionId);
  Future<ReviewSessionModel> createReviewSession(ReviewSessionModel session);
  Future<ReviewSessionModel> updateReviewSession(ReviewSessionModel session);
  Future<void> deleteReviewSession(String sessionId);
  // Review response operations
  Future<List<ReviewResponseModel>> getAllReviewResponses(String quizId);
  Future<ReviewResponseModel> getReviewResponseById(String responseId);
  Future<ReviewResponseModel> createReviewResponse(ReviewResponseModel response);
  Future<ReviewResponseModel> updateReviewResponse(ReviewResponseModel response);
  Future<void> deleteReviewResponse(String responseId);
}