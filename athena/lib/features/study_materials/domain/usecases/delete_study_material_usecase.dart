import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteStudyMaterialUseCase {
  final StudyMaterialRepository repository;

  DeleteStudyMaterialUseCase(this.repository);

  /// Deletes a study material by its ID.
  Future<Either<Failure, void>> call(String studyMaterialId) {
    return repository.deleteStudyMaterial(studyMaterialId);
  }
}
