import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class GetReviewSessionsUseCase {
  final ReviewRepository _repository;

  GetReviewSessionsUseCase(this._repository);

  Future<Either<Failure, List<ReviewSessionEntity>>> call(String quizId) async {
    try {
      return await _repository.getAllReviewSessions(quizId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
