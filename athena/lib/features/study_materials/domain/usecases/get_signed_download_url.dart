import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/study_materials/domain/repositories/study_material_repository.dart';
import 'package:dartz/dartz.dart';

class GetSignedDownloadUrlUseCase {
  final StudyMaterialRepository repository;

  GetSignedDownloadUrlUseCase(this.repository);

  /// Gets a public download URL for a study material file.
  Future<Either<Failure, String>> call(String fileStoragePath) {
    return repository.getSignedDownloadUrl(fileStoragePath);
  }
}