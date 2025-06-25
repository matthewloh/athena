import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/data/datasources/planner_remote_datasource.dart';
import 'package:athena/features/planner/data/models/study_goal_model.dart';
import 'package:athena/features/planner/data/models/study_session_model.dart';
import 'package:athena/features/planner/domain/entities/study_goal_entity.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:athena/features/planner/domain/repositories/planner_repository.dart';
import 'package:dartz/dartz.dart';

/// Concrete implementation of PlannerRepository that coordinates data operations
class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDataSource remoteDataSource;

  const PlannerRepositoryImpl(this.remoteDataSource);

  // ============================================================================
  // STUDY GOALS OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<StudyGoalEntity>>> getStudyGoals(
    String userId,
  ) async {
    try {
      final goalModels = await remoteDataSource.getStudyGoals(userId);
      final goalEntities = goalModels.map((model) => model.toEntity()).toList();
      return Right(goalEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudyGoalEntity>> getStudyGoalById(
    String goalId,
  ) async {
    try {
      final goalModel = await remoteDataSource.getStudyGoalById(goalId);
      return Right(goalModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudyGoalEntity>> createStudyGoal(
    StudyGoalEntity goal,
  ) async {
    try {
      final goalModel = StudyGoalModel.fromEntity(goal);
      final createdGoal = await remoteDataSource.createStudyGoal(goalModel);
      return Right(createdGoal.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudyGoalEntity>> updateStudyGoal(
    StudyGoalEntity goal,
  ) async {
    try {
      final goalModel = StudyGoalModel.fromEntity(goal);
      final updatedGoal = await remoteDataSource.updateStudyGoal(goalModel);
      return Right(updatedGoal.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudyGoal(String goalId) async {
    try {
      await remoteDataSource.deleteStudyGoal(goalId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudyGoalEntity>> updateGoalProgress(
    String goalId,
    double progress,
  ) async {
    try {
      final goalModel = await remoteDataSource.getStudyGoalById(goalId);
      final updatedGoal = goalModel.copyWith(
        progress: progress,
        updatedAt: DateTime.now(),
      );
      final result = await remoteDataSource.updateStudyGoal(updatedGoal);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudyGoalEntity>> markGoalCompleted(
    String goalId,
  ) async {
    try {
      final goalModel = await remoteDataSource.getStudyGoalById(goalId);
      final updatedGoal = goalModel.copyWith(
        isCompleted: true,
        progress: 1.0,
        updatedAt: DateTime.now(),
      );
      final result = await remoteDataSource.updateStudyGoal(updatedGoal);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // ============================================================================
  // STUDY SESSIONS OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getStudySessions(
    String userId,
  ) async {
    try {
      final sessionModels = await remoteDataSource.getStudySessions(userId);
      final sessionEntities =
          sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessionEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getStudySessionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessionModels = await remoteDataSource.getStudySessionsByDateRange(
        userId,
        startDate,
        endDate,
      );
      final sessionEntities =
          sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessionEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getSessionsByGoal(
    String goalId,
  ) async {
    try {
      final sessionModels = await remoteDataSource.getSessionsByGoal(goalId);
      final sessionEntities =
          sessionModels.map((model) => model.toEntity()).toList();
      return Right(sessionEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> getStudySessionById(
    String sessionId,
  ) async {
    try {
      final sessionModel = await remoteDataSource.getStudySessionById(
        sessionId,
      );
      return Right(sessionModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> createStudySession(
    StudySessionEntity session,
  ) async {
    try {
      final sessionModel = StudySessionModel.fromEntity(session);
      final createdSession = await remoteDataSource.createStudySession(
        sessionModel,
      );
      return Right(createdSession.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> updateStudySession(
    StudySessionEntity session,
  ) async {
    try {
      final sessionModel = StudySessionModel.fromEntity(session);
      final updatedSession = await remoteDataSource.updateStudySession(
        sessionModel,
      );
      return Right(updatedSession.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudySession(String sessionId) async {
    try {
      await remoteDataSource.deleteStudySession(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> updateSessionStatus(
    String sessionId,
    StudySessionStatus status,
  ) async {
    try {
      final sessionModel = await remoteDataSource.getStudySessionById(
        sessionId,
      );
      final updatedSession = sessionModel.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      final result = await remoteDataSource.updateStudySession(updatedSession);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StudySessionEntity>> completeStudySession(
    String sessionId,
    int actualDurationMinutes,
  ) async {
    try {
      final sessionModel = await remoteDataSource.getStudySessionById(
        sessionId,
      );
      final updatedSession = sessionModel.copyWith(
        status: StudySessionStatus.completed,
        actualDurationMinutes: actualDurationMinutes,
        updatedAt: DateTime.now(),
      );
      final result = await remoteDataSource.updateStudySession(updatedSession);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // ============================================================================
  // ANALYTICS & INSIGHTS OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getUpcomingSessions(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final sevenDaysFromNow = now.add(const Duration(days: 7));

      final sessions = await remoteDataSource.getStudySessionsByDateRange(
        userId,
        now,
        sevenDaysFromNow,
      );

      final upcomingSessions =
          sessions
              .where(
                (session) => session.status == StudySessionStatus.scheduled,
              )
              .map((model) => model.toEntity())
              .toList();

      return Right(upcomingSessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getOverdueSessions(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final oneMonthAgo = now.subtract(const Duration(days: 30));

      final sessions = await remoteDataSource.getStudySessionsByDateRange(
        userId,
        oneMonthAgo,
        now,
      );

      final overdueSessions =
          sessions
              .where(
                (session) =>
                    session.status == StudySessionStatus.scheduled &&
                    session.startTime.isBefore(now),
              )
              .map((model) => model.toEntity())
              .toList();

      return Right(overdueSessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<StudySessionEntity>>> getTodaySessions(
    String userId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final sessions = await remoteDataSource.getStudySessionsByDateRange(
        userId,
        startOfDay,
        endOfDay,
      );

      final todaySessions = sessions.map((model) => model.toEntity()).toList();
      return Right(todaySessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<StudyGoalEntity>>> getGoalsNearingDeadline(
    String userId,
    int daysThreshold,
  ) async {
    try {
      final goals = await remoteDataSource.getStudyGoals(userId);
      final now = DateTime.now();
      final threshold = now.add(Duration(days: daysThreshold));

      final nearingDeadline =
          goals
              .where(
                (goal) =>
                    !goal.isCompleted &&
                    goal.targetDate != null &&
                    goal.targetDate!.isBefore(threshold) &&
                    goal.targetDate!.isAfter(now),
              )
              .map((model) => model.toEntity())
              .toList();

      return Right(nearingDeadline);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalStudyTimeForPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sessions = await remoteDataSource.getStudySessionsByDateRange(
        userId,
        startDate,
        endDate,
      );

      final totalMinutes = sessions
          .where(
            (session) =>
                session.status == StudySessionStatus.completed &&
                session.actualDurationMinutes != null,
          )
          .fold(0, (sum, session) => sum + session.actualDurationMinutes!);

      return Right(totalMinutes);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getGoalCompletionRate(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final goals = await remoteDataSource.getStudyGoals(userId);

      final goalsInPeriod =
          goals
              .where(
                (goal) =>
                    goal.createdAt.isAfter(startDate) &&
                    goal.createdAt.isBefore(endDate),
              )
              .toList();

      if (goalsInPeriod.isEmpty) {
        return const Right(0.0);
      }

      final completedGoals =
          goalsInPeriod.where((goal) => goal.isCompleted).length;
      final completionRate = completedGoals / goalsInPeriod.length;

      return Right(completionRate);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
