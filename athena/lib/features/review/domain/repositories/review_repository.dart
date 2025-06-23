import 'dart:async';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ReviewRepository {
  // Quiz operations
  Future<Either<Failure, List<QuizEntity>>> getAllQuizzes(String userId);
  Future<Either<Failure, QuizEntity>> getQuizById(String quizId);
  Future<Either<Failure, QuizEntity>> createQuiz(QuizEntity quiz);
  Future<Either<Failure, QuizEntity>> updateQuiz(QuizEntity quiz);
  Future<Either<Failure, void>> deleteQuiz(String quizId);
  Future<Either<Failure, QuizEntity>> generateAiQuiz(String? studyMaterialId);

  // Quiz item operations
  Future<Either<Failure, List<QuizItemEntity>>> getAllQuizItems(String quizId);
  Future<Either<Failure, QuizItemEntity>> getQuizItemById(String itemId);
  Future<Either<Failure, QuizItemEntity>> createQuizItem(QuizItemEntity quizItem);
  Future<Either<Failure, QuizItemEntity>> updateQuizItem(QuizItemEntity quizItem);
  Future<Either<Failure, void>> deleteQuizItem(String itemId);

  // TODO: Future implementation for other operations
  // // Review session operations
  // Future<Either<Failure, String>> startReviewSession(String quizId, String userId);
  // Future<Either<Failure, void>> submitReviewResponse(String sessionId);
  // Future<Either<Failure, List<Map<String, dynamic>>>> getReviewSessions(String userId);
}
