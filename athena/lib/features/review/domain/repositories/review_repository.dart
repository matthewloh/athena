import 'dart:async';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
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
  // Review session operations
  Future<Either<Failure, List<ReviewSessionEntity>>> getAllReviewSessions(String quizId);
  Future<Either<Failure, ReviewSessionEntity>> getReviewSessionById(String sessionId);
  Future<Either<Failure, ReviewSessionEntity>> createReviewSession(ReviewSessionEntity session);
  Future<Either<Failure, ReviewSessionEntity>> updateReviewSession(ReviewSessionEntity session);
  Future<Either<Failure, void>> deleteReviewSession(String sessionId);
  // Review response operations
  Future<Either<Failure, List<ReviewResponseEntity>>> getAllReviewResponses(String quizId);
  Future<Either<Failure, ReviewResponseEntity>> getReviewResponseById(String responseId);
  Future<Either<Failure, ReviewResponseEntity>> createReviewResponse(ReviewResponseEntity response);
  Future<Either<Failure, ReviewResponseEntity>> updateReviewResponse(ReviewResponseEntity response);
  Future<Either<Failure, void>> deleteReviewResponse(String responseId);
}
