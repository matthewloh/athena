import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateReviewSessionUseCase {
  final ReviewRepository _repository;

  UpdateReviewSessionUseCase(this._repository);

  Future<Either<Failure, ReviewSessionEntity>> call(
    ReviewSessionEntity session,
  ) async {
    try {
      return await _repository.updateReviewSession(session);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
