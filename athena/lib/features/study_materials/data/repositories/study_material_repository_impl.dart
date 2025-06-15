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
    // TODO: implement getAllStudyMaterials
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, StudyMaterialEntity>> getStudyMaterialById(
    String studyMaterialId,
  ) async {
    // TODO: implement getStudyMaterialById
    throw UnimplementedError();
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
    // TODO: implement updateStudyMaterial
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteStudyMaterial(
    String studyMaterialId,
  ) async {
    // TODO: implement deleteStudyMaterial
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> requestAiSummary(
    String studyMaterialId,
  ) async {
    // TODO: implement requestAiSummary
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> requestOcrProcessing(String imagePath) async {
    // TODO: implement requestOcrProcessing
    throw UnimplementedError();
  }
}
