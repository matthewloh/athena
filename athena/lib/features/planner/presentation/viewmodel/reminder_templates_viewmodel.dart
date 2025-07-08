import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';
import 'package:athena/features/planner/domain/usecases/get_reminder_templates_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class for reminder templates
class ReminderTemplatesState {
  final List<ReminderTemplateEntity> templates;
  final List<ReminderTemplateEntity> defaultTemplates;
  final bool isLoading;
  final String? errorMessage;

  const ReminderTemplatesState({
    this.templates = const [],
    this.defaultTemplates = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReminderTemplatesState copyWith({
    List<ReminderTemplateEntity>? templates,
    List<ReminderTemplateEntity>? defaultTemplates,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReminderTemplatesState(
      templates: templates ?? this.templates,
      defaultTemplates: defaultTemplates ?? this.defaultTemplates,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ViewModel for managing reminder templates
class ReminderTemplatesViewModel extends StateNotifier<ReminderTemplatesState> {
  final GetReminderTemplatesUseCase _getReminderTemplatesUseCase;

  ReminderTemplatesViewModel(this._getReminderTemplatesUseCase)
    : super(const ReminderTemplatesState());

  /// Loads all reminder templates
  Future<void> loadReminderTemplates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getReminderTemplatesUseCase.call();

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (templates) =>
          state = state.copyWith(
            isLoading: false,
            templates: templates,
            errorMessage: null,
          ),
    );
  }

  /// Loads only default reminder templates
  Future<void> loadDefaultReminderTemplates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getReminderTemplatesUseCase.getDefaults();

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (defaultTemplates) =>
          state = state.copyWith(
            isLoading: false,
            defaultTemplates: defaultTemplates,
            errorMessage: null,
          ),
    );
  }

  /// Loads both all templates and default templates
  Future<void> loadAllTemplates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Load all templates
    final allTemplatesResult = await _getReminderTemplatesUseCase.call();

    // Load default templates
    final defaultTemplatesResult =
        await _getReminderTemplatesUseCase.getDefaults();

    if (allTemplatesResult.isLeft() || defaultTemplatesResult.isLeft()) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load reminder templates',
      );
      return;
    }

    allTemplatesResult.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (templates) => defaultTemplatesResult.fold(
        (failure) =>
            state = state.copyWith(
              isLoading: false,
              errorMessage: failure.message,
            ),
        (defaultTemplates) =>
            state = state.copyWith(
              isLoading: false,
              templates: templates,
              defaultTemplates: defaultTemplates,
              errorMessage: null,
            ),
      ),
    );
  }

  /// Gets templates grouped by time periods for UI display
  Map<String, List<ReminderTemplateEntity>> getTemplatesGroupedByTimePeriod() {
    final grouped = <String, List<ReminderTemplateEntity>>{};

    for (final template in state.templates) {
      final period = template.offsetMinutes.toString();
      if (!grouped.containsKey(period)) {
        grouped[period] = [];
      }
      grouped[period]!.add(template);
    }

    return grouped;
  }

  /// Gets a template by ID
  ReminderTemplateEntity? getTemplateById(String templateId) {
    try {
      return state.templates.firstWhere(
        (template) => template.id == templateId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clear current state
  void clearState() {
    state = const ReminderTemplatesState();
  }
}
