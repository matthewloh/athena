import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class RequestAiSummaryUseCase {
  final StudyMaterialRepository repository;

  RequestAiSummaryUseCase(this.repository);

  /// Requests an AI-generated summary for a study material.
  Future<Either<Failure, String>> call(String studyMaterialId) {
    return repository.requestAiSummary(studyMaterialId);
  }
}
