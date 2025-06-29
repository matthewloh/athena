import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllQuizItemsUseCase {
  final ReviewRepository _repository;

  GetAllQuizItemsUseCase(this._repository);

  Future<Either<Failure, List<QuizItemEntity>>> call(String quizId) {
    return _repository.getAllQuizItems(quizId);
  }
}
