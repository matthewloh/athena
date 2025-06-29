import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteQuizItemUseCase {
  final ReviewRepository _repository;

  DeleteQuizItemUseCase(this._repository);

  Future<Either<Failure, void>> call(String quizItemId) async {
    return _repository.deleteQuizItem(quizItemId);
  }
}
