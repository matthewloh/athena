import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/domain/entities/study_goal_entity.dart';
import 'package:athena/features/planner/domain/repositories/planner_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving study goals for a user
class GetStudyGoalsUseCase {
  final PlannerRepository _repository;

  const GetStudyGoalsUseCase(this._repository);

  /// Executes the use case to get all study goals for a user
  ///
  /// [userId] - The ID of the user whose goals to retrieve
  ///
  /// Returns: Either a Failure or a List of StudyGoalEntity
  Future<Either<Failure, List<StudyGoalEntity>>> call(String userId) async {
    return await _repository.getStudyGoals(userId);
  }
}
