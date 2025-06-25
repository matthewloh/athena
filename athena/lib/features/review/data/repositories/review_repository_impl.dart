import 'dart:async';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/data/datasources/review_remote_datasource.dart';
import 'package:athena/features/review/data/models/quiz_item_model.dart';
import 'package:athena/features/review/data/models/quiz_model.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
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
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
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
}
