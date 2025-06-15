import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class GetStudyMaterialUseCase {
  final StudyMaterialRepository repository;

  GetStudyMaterialUseCase(this.repository);

  /// Gets a specific study material by its ID.
  Future<Either<Failure, StudyMaterialEntity>> call(String studyMaterialId) {
    return repository.getStudyMaterialById(studyMaterialId);
  }
}
