import 'dart:async';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:dartz/dartz.dart';

abstract class StudyMaterialRepository {
  /// Getst all study materials for the given user ID.
  Future<Either<Failure, List<StudyMaterialEntity>>> getAllStudyMaterials(String userId);

  /// Gets a specific study material by its ID.
  Future<Either<Failure, StudyMaterialEntity>> getStudyMaterialById(String studyMaterialId);

  /// Creates a new study material.
  Future<Either<Failure, StudyMaterialEntity>> createStudyMaterial(StudyMaterialEntity studyMaterial);

  /// Updates an existing study material.
  Future<Either<Failure, StudyMaterialEntity>> updateStudyMaterial(StudyMaterialEntity studyMaterial);

  /// Deletes a study material by its ID.
  Future<Either<Failure, void>> deleteStudyMaterial(String studyMaterialId);

  /// Requests an AI-generated summary for a study material.
  Future<Either<Failure, String>> requestAiSummary(String studyMaterialId);

  /// Requests OCR processing for a study material by passing an image file path.
  Future<Either<Failure, String>> requestOcrProcessing(String imagePath);

  /// Gets a signed download URL for a study material file.
  Future<Either<Failure, String>> getSignedDownloadUrl(String fileStoragePath);
}
