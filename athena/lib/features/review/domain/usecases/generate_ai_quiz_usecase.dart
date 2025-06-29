import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class GenerateAiQuizUseCase {
  final ReviewRepository _repository;

  GenerateAiQuizUseCase(this._repository);

  Future<Either<Failure, QuizEntity>> call(String? studyMaterialId) {
    return _repository.generateAiQuiz(studyMaterialId);
  }
}
