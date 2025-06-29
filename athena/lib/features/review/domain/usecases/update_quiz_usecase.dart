import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:athena/features/review/domain/usecases/params/update_quiz_params.dart';
import 'package:dartz/dartz.dart';

class UpdateQuizUseCase {
  final ReviewRepository _repository;

  UpdateQuizUseCase(this._repository);

  Future<Either<Failure, QuizEntity>> call(UpdateQuizParams params) async {
    // Get the existing quiz first
    final existingResult = await _repository.getQuizById(params.id);

    return existingResult.fold((failure) => Left(failure), (existingQuiz) {
      // Create updated quiz with only the fields that are provided
      final updatedQuiz = existingQuiz.copyWith(
        title: params.title,
        studyMaterialId: params.studyMaterialId ?? existingQuiz.studyMaterialId,
        subject: params.subject ?? existingQuiz.subject,
        description: params.description ?? existingQuiz.description,
      );

      // Call the repository to update the quiz
      return _repository.updateQuiz(updatedQuiz);
    });
  }
}
