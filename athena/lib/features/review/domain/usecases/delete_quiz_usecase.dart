import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteQuizUseCase {
  final ReviewRepository _repository;

  DeleteQuizUseCase(this._repository);

  Future<Either<Failure, void>> call(String quizId) {
    return _repository.deleteQuiz(quizId);
  }
}
