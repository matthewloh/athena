import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/data/datasources/reminder_remote_datasource.dart';
import 'package:athena/features/planner/data/models/reminder_template_model.dart';
import 'package:athena/features/planner/data/models/session_reminder_model.dart';
import 'package:athena/features/planner/data/models/user_reminder_preferences_model.dart';
import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';
import 'package:athena/features/planner/domain/entities/session_reminder_entity.dart';
import 'package:athena/features/planner/domain/entities/user_reminder_preferences_entity.dart';
import 'package:athena/features/planner/domain/repositories/reminder_repository.dart';
import 'package:dartz/dartz.dart';

/// Concrete implementation of ReminderRepository using remote data source
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDataSource _remoteDataSource;

  const ReminderRepositoryImpl(this._remoteDataSource);

  // ============================================================================
  // REMINDER TEMPLATES OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<ReminderTemplateEntity>>> getReminderTemplates() async {
    try {
      final models = await _remoteDataSource.getReminderTemplates();
      final entities = models.cast<ReminderTemplateEntity>();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ReminderTemplateEntity>>> getDefaultReminderTemplates() async {
    try {
      final models = await _remoteDataSource.getDefaultReminderTemplates();
      final entities = models.cast<ReminderTemplateEntity>();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // ============================================================================
  // SESSION REMINDERS OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<SessionReminderEntity>>> getSessionReminders(String userId) async {
    try {
      final models = await _remoteDataSource.getSessionReminders(userId);
      final entities = models.cast<SessionReminderEntity>();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<SessionReminderEntity>>> getSessionRemindersBySession(String sessionId) async {
    try {
      final models = await _remoteDataSource.getSessionRemindersBySession(sessionId);
      final entities = models.cast<SessionReminderEntity>();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SessionReminderEntity>> getSessionReminderById(String reminderId) async {
    try {
      final model = await _remoteDataSource.getSessionReminderById(reminderId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SessionReminderEntity>> createSessionReminder(SessionReminderEntity reminder) async {
    try {
      final model = SessionReminderModel.fromEntity(reminder);
      final resultModel = await _remoteDataSource.createSessionReminder(model);
      return Right(resultModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SessionReminderEntity>> updateSessionReminder(SessionReminderEntity reminder) async {
    try {
      final model = SessionReminderModel.fromEntity(reminder);
      final resultModel = await _remoteDataSource.updateSessionReminder(model);
      return Right(resultModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSessionReminder(String reminderId) async {
    try {
      await _remoteDataSource.deleteSessionReminder(reminderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, SessionReminderEntity>> updateReminderDeliveryStatus(
    String reminderId,
    String deliveryStatus,
    {String? errorMessage}
  ) async {
    try {
      final resultModel = await _remoteDataSource.updateReminderDeliveryStatus(
        reminderId,
        deliveryStatus,
        errorMessage: errorMessage,
      );
      return Right(resultModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  // ============================================================================
  // USER REMINDER PREFERENCES OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, UserReminderPreferencesEntity>> getUserReminderPreferences(String userId) async {
    try {
      final model = await _remoteDataSource.getUserReminderPreferences(userId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserReminderPreferencesEntity>> createUserReminderPreferences(
    UserReminderPreferencesEntity preferences
  ) async {
    try {
      final model = UserReminderPreferencesModel.fromEntity(preferences);
      final resultModel = await _remoteDataSource.createUserReminderPreferences(model);
      return Right(resultModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserReminderPreferencesEntity>> updateUserReminderPreferences(
    UserReminderPreferencesEntity preferences
  ) async {
    try {
      final model = UserReminderPreferencesModel.fromEntity(preferences);
      final resultModel = await _remoteDataSource.updateUserReminderPreferences(model);
      return Right(resultModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
} 