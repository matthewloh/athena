import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllStudyMaterialsUseCase {
  final StudyMaterialRepository repository;

  GetAllStudyMaterialsUseCase(this.repository);

  /// Gets all study materials for the given user ID.
  Future<Either<Failure, List<StudyMaterialEntity>>> call(String userId) {
    return repository.getAllStudyMaterials(userId);
  }
}
