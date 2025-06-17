import 'dart:async';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/data/datasources/study_material_remote_datasource.dart';
import 'package:athena/features/study_materials/data/models/study_material_model.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class StudyMaterialRepositoryImpl implements StudyMaterialRepository {
  final StudyMaterialRemoteDataSource _remoteDataSource;

  StudyMaterialRepositoryImpl(this._remoteDataSource);
  @override
  Future<Either<Failure, List<StudyMaterialEntity>>> getAllStudyMaterials(
    String userId,
  ) async {
    try {
      final studyMaterials = await _remoteDataSource.getAllStudyMaterials(
        userId,
      );
      return Right(studyMaterials.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to fetch study materials: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, StudyMaterialEntity>> getStudyMaterialById(
    String studyMaterialId,
  ) async {
    try {
      final studyMaterial = await _remoteDataSource.getStudyMaterialById(
        studyMaterialId,
      );
      return Right(studyMaterial.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to fetch study material: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, StudyMaterialEntity>> createStudyMaterial(
    StudyMaterialEntity studyMaterial,
  ) async {
    try {
      // Convert the StudyMaterialEntity to StudyMaterialModel
      final studyMaterialModel = StudyMaterialModel.fromEntity(studyMaterial);

      // Call the remote data source to create the study material
      final createdStudyMaterial = await _remoteDataSource.createStudyMaterial(
        studyMaterialModel,
      );

      // Return the created study material as an entity
      return Right(createdStudyMaterial);
    } on ServerException catch (e) {
      print('ServerException: ${e.message}');
      return Left(
        ServerFailure('Failed to create study material: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, StudyMaterialEntity>> updateStudyMaterial(
    StudyMaterialEntity studyMaterial,
  ) async {
    try {
      // Convert the StudyMaterialEntity to StudyMaterialModel
      final studyMaterialModel = StudyMaterialModel.fromEntity(studyMaterial);

      // Call the remote data source to update the study material
      final updatedStudyMaterial = await _remoteDataSource.updateStudyMaterial(
        studyMaterialModel,
      );

      // Return the updated study material as an entity
      return Right(updatedStudyMaterial.toEntity());
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to update study material: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudyMaterial(
    String studyMaterialId,
  ) async {
    try {
      // Call the remote data source to delete the study material
      await _remoteDataSource.deleteStudyMaterial(studyMaterialId);

      // Return success
      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure('Failed to delete study material: ${e.message}'),
      );
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> requestAiSummary(
    String studyMaterialId,
  ) async {
    try {
      // Call the remote data source to request AI summary
      final summary = await _remoteDataSource.requestAiSummary(studyMaterialId);
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to generate AI summary: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> requestOcrProcessing(String imagePath) async {
    try {
      // Call the remote data source to request OCR processing
      final extractedText = await _remoteDataSource.requestOcrProcessing(
        imagePath,
      );
      return Right(extractedText);
    } on ServerException catch (e) {
      return Left(ServerFailure('Failed to process OCR: ${e.message}'));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }
}
