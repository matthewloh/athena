import 'dart:async';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/data/datasources/review_remote_datasource.dart';
import 'package:athena/features/review/data/models/quiz_item_model.dart';
import 'package:athena/features/review/data/models/quiz_model.dart';
import 'package:athena/features/review/data/models/review_response_model.dart';
import 'package:athena/features/review/data/models/review_session_model.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource _remoteDataSource;

  ReviewRepositoryImpl(this._remoteDataSource);

  // Quiz operations
  @override
  Future<Either<Failure, List<QuizEntity>>> getAllQuizzes(String userId) async {
    try {
      final quizModels = await _remoteDataSource.getAllQuizzes(userId);
      return Right(quizModels.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to fetch quizzes: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> getQuizById(String quizId) async {
    try {
      final quizModel = await _remoteDataSource.getQuizById(quizId);
      return Right(quizModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to fetch quiz: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> createQuiz(QuizEntity quiz) async {
    try {
      final quizModel = QuizModel.fromEntity(quiz);
      final createdQuizModel = await _remoteDataSource.createQuiz(quizModel);
      return Right(createdQuizModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to create quiz: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> updateQuiz(QuizEntity quiz) async {
    try {
      final quizModel = QuizModel.fromEntity(quiz);
      final updatedQuizModel = await _remoteDataSource.updateQuiz(quizModel);
      return Right(updatedQuizModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to update quiz: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuiz(String quizId) async {
    try {
      await _remoteDataSource.deleteQuiz(quizId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to delete quiz: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizEntity>> generateAiQuiz(
    String? studyMaterialId,
  ) async {
    try {
      final generatedQuizModel = await _remoteDataSource.generateAiQuiz(
        studyMaterialId,
      );
      return Right(generatedQuizModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to generate AI quiz: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during AI quiz generation: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> generateAiQuestions({
    required String studyMaterialId,
    required String quizType,
    int maxQuestions = 10, // Changed from numQuestions to maxQuestions
    String difficultyLevel = 'medium',
  }) async {
    try {
      final result = await _remoteDataSource.generateAiQuestions(
        studyMaterialId: studyMaterialId,
        quizType: quizType,
        maxQuestions: maxQuestions, // Updated parameter name
        difficultyLevel: difficultyLevel,
      );

      final questions = result['questions'] as List;
      return Right(questions.cast<Map<String, dynamic>>());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to generate AI questions: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Unexpected error during AI question generation: $e'),
      );
    }
  }

  // Quiz item operations
  @override
  Future<Either<Failure, List<QuizItemEntity>>> getAllQuizItems(
    String quizId,
  ) async {
    try {
      final quizItemsModel = await _remoteDataSource.getAllQuizItems(quizId);
      return Right(quizItemsModel.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to fetch quiz items: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizItemEntity>> getQuizItemById(String itemId) async {
    try {
      final quizItemModel = await _remoteDataSource.getQuizItemById(itemId);
      return Right(quizItemModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to fetch quiz item: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizItemEntity>> createQuizItem(
    QuizItemEntity quizItem,
  ) async {
    try {
      final quizItemModel = QuizItemModel.fromEntity(quizItem);

      final createdQuizItemModel = await _remoteDataSource.createQuizItem(
        quizItemModel,
      );

      return Right(createdQuizItemModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to create quiz item: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, QuizItemEntity>> updateQuizItem(
    QuizItemEntity quizItem,
  ) async {
    try {
      final quizItemModel = QuizItemModel.fromEntity(quizItem);
      final updatedQuizItemModel = await _remoteDataSource.updateQuizItem(
        quizItemModel,
      );
      return Right(updatedQuizItemModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to update quiz item: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuizItem(String itemId) async {
    try {
      await _remoteDataSource.deleteQuizItem(itemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to delete quiz item: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  // Review session operations
  @override
  Future<Either<Failure, List<ReviewSessionEntity>>> getAllReviewSessions(
    String quizId,
  ) async {
    try {
      final reviewSessionsModel = await _remoteDataSource.getAllReviewSessions(
        quizId,
      );
      return Right(
        reviewSessionsModel.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to fetch review sessions: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewSessionEntity>> getReviewSessionById(
    String sessionId,
  ) async {
    try {
      final reviewSessionModel = await _remoteDataSource.getReviewSessionById(
        sessionId,
      );
      return Right(reviewSessionModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to fetch review session: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewSessionEntity>> createReviewSession(
    ReviewSessionEntity session,
  ) async {
    try {
      final sessionModel = ReviewSessionModel.fromEntity(session);
      final createdSessionModel = await _remoteDataSource.createReviewSession(
        sessionModel,
      );
      return Right(createdSessionModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to create review session: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewSessionEntity>> updateReviewSession(
    ReviewSessionEntity session,
  ) async {
    try {
      final sessionModel = ReviewSessionModel.fromEntity(session);
      final updatedSessionModel = await _remoteDataSource.updateReviewSession(
        sessionModel,
      );
      return Right(updatedSessionModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to update review session: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteReviewSession(String sessionId) async {
    try {
      await _remoteDataSource.deleteReviewSession(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to delete review session: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  // Review response operations
  @override
  Future<Either<Failure, List<ReviewResponseEntity>>> getAllReviewResponses(
    String quizId,
  ) async {
    try {
      final reviewResponsesModel = await _remoteDataSource
          .getAllReviewResponses(quizId);
      return Right(
        reviewResponsesModel.map((model) => model.toEntity()).toList(),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to fetch review responses: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewResponseEntity>> getReviewResponseById(
    String responseId,
  ) async {
    try {
      final reviewResponseModel = await _remoteDataSource.getReviewResponseById(
        responseId,
      );
      return Right(reviewResponseModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to fetch review response: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewResponseEntity>> createReviewResponse(
    ReviewResponseEntity response,
  ) async {
    try {
      final responseModel = ReviewResponseModel.fromEntity(response);
      final createdResponseModel = await _remoteDataSource.createReviewResponse(
        responseModel,
      );
      return Right(createdResponseModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to create review response: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ReviewResponseEntity>> updateReviewResponse(
    ReviewResponseEntity response,
  ) async {
    try {
      final responseModel = ReviewResponseModel.fromEntity(response);
      final updatedResponseModel = await _remoteDataSource.updateReviewResponse(
        responseModel,
      );
      return Right(updatedResponseModel.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to update review response: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteReviewResponse(String responseId) async {
    try {
      await _remoteDataSource.deleteReviewResponse(responseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to delete review response: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
