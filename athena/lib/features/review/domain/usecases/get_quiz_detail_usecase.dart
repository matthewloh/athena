import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class GetQuizDetailUseCase {
  final ReviewRepository _repository;

  GetQuizDetailUseCase(this._repository);

  Future<Either<Failure, QuizEntity>> call(String quizId) {
    return _repository.getQuizById(quizId);
  }
}
