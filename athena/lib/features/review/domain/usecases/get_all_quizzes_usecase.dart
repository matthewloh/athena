import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class GetAllQuizzesUseCase {
  final ReviewRepository _repository;

  GetAllQuizzesUseCase(this._repository);

  Future<Either<Failure, List<QuizEntity>>> call(String userId) {
    return _repository.getAllQuizzes(userId);
  }
}
