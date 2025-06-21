import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:athena/features/study_materials/domain/usecases/params/update_study_material_params.dart';
import 'package:dartz/dartz.dart';

class UpdateStudyMaterialUseCase {
  final StudyMaterialRepository _repository;

  UpdateStudyMaterialUseCase(this._repository);

  Future<Either<Failure, StudyMaterialEntity>> call(
    UpdateStudyMaterialParams params,
  ) async {
    // Get the existing material first
    final existingResult = await _repository.getStudyMaterialById(params.id);

    return existingResult.fold((failure) => Left(failure), (
      existingMaterial,
    ) async {
      // Create updated entity with only the fields that are provided
      final updatedMaterial = existingMaterial.copyWith(
        title: params.title ?? existingMaterial.title,
        description: params.description ?? existingMaterial.description,
        subject: params.subject ?? existingMaterial.subject,
        originalContentText:
            params.originalContentText ?? existingMaterial.originalContentText,
        fileStoragePath:
            params.fileStoragePath ?? existingMaterial.fileStoragePath,
        ocrExtractedText:
            params.ocrExtractedText ?? existingMaterial.ocrExtractedText,
        summaryText: params.summaryText ?? existingMaterial.summaryText,
        hasAiSummary: params.hasAiSummary,
        updatedAt: DateTime.now(),
      );

      return await _repository.updateStudyMaterial(updatedMaterial);
    });
  }
}
