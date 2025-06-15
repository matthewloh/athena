import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateStudyMaterialUsecase {
  final StudyMaterialRepository _repository;

  UpdateStudyMaterialUsecase(this._repository);

  Future<Either<Failure, StudyMaterialEntity>> call(StudyMaterialEntity studyMaterial) async {
    return await _repository.updateStudyMaterial(studyMaterial);
  }
}
