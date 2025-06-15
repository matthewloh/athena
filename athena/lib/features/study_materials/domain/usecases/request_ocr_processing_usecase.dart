import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class RequestOcrProcessingUseCase {
  final StudyMaterialRepository repository;

  RequestOcrProcessingUseCase(this.repository);

  /// Requests OCR processing for a study material.
  Future<Either<Failure, String>> call(String studyMaterialId) {
    return repository.requestOcrProcessing(studyMaterialId);
  }
}
