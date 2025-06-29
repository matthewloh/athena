import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class CreateQuizItemUseCase {
  final ReviewRepository _repository;

  CreateQuizItemUseCase(this._repository);

  Future<Either<Failure, QuizItemEntity>> call(QuizItemEntity quizItem) async {
    return _repository.createQuizItem(quizItem);
  }
}
