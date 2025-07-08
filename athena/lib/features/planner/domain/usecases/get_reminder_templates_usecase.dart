import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';
import 'package:athena/features/planner/domain/repositories/reminder_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for getting reminder templates
class GetReminderTemplatesUseCase {
  final ReminderRepository _repository;

  const GetReminderTemplatesUseCase(this._repository);

  /// Gets all active reminder templates
  Future<Either<Failure, List<ReminderTemplateEntity>>> call() {
    return _repository.getReminderTemplates();
  }

  /// Gets only default reminder templates
  Future<Either<Failure, List<ReminderTemplateEntity>>> getDefaults() {
    return _repository.getDefaultReminderTemplates();
  }
} 