import 'dart:async';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ReviewRepository {
  // Quiz operations
    Future<Either<Failure, List<QuizEntity>>> getAllQuizzes(String userId);
  Future<Either<Failure, QuizEntity>> getQuizById(String quizId);
  Future<Either<Failure, QuizEntity>> createQuiz(QuizEntity quiz);
  Future<Either<Failure, QuizEntity>> updateQuiz(QuizEntity quiz);
  Future<Either<Failure, void>> deleteQuiz(String quizId);
  Future<Either<Failure, List<QuizEntity>>> generateAiQuiz(String? studyMaterialId);

  // TODO: Future implementation for other operations
  // // Quiz item operations
  // Future<Either<Failure, String>> addQuizItem(String quizId, String userId, Map<String, dynamic> itemData);
  // Future<Either<Failure, void>> updateQuizItem(String itemId, String userId, Map<String, dynamic> itemData);
  // Future<Either<Failure, void>> deleteQuizItem(String itemId, String userId);
  // Future<Either<Failure, List<Map<String, dynamic>>>> getQuizItems(String quizId);

  // // Review session operations
  // Future<Either<Failure, String>> startReviewSession(String quizId, String userId);
  // Future<Either<Failure, void>> submitReviewResponse(String sessionId);
  // Future<Either<Failure, List<Map<String, dynamic>>>> getReviewSessions(String userId);
}
