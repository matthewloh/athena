import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class RequestOcrProcessingUsecase {
  final StudyMaterialRepository repository;

  RequestOcrProcessingUsecase(this.repository);

  /// Requests OCR processing for a study material.
  Future<Either<Failure, void>> call(String studyMaterialId) {
    return repository.requestOcrProcessing(studyMaterialId);
  }
}
