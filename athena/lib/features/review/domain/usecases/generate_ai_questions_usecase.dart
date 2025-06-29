import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:dartz/dartz.dart';

class GenerateAiQuestionsParams {
  final String studyMaterialId;
  final String quizType;
  final int maxQuestions; // Changed from numQuestions to maxQuestions
  final String difficultyLevel;

  const GenerateAiQuestionsParams({
    required this.studyMaterialId,
    required this.quizType,
    this.maxQuestions = 10, // Updated default value
    this.difficultyLevel = 'medium',
  });
}

class GenerateAiQuestionsUseCase {
  final ReviewRepository _repository;

  GenerateAiQuestionsUseCase(this._repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call(
    GenerateAiQuestionsParams params,
  ) {
    return _repository.generateAiQuestions(
      studyMaterialId: params.studyMaterialId,
      quizType: params.quizType,
      maxQuestions: params.maxQuestions, // Updated parameter name
      difficultyLevel: params.difficultyLevel,
    );
  }
}
