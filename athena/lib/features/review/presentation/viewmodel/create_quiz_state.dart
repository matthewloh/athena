import 'package:athena/core/enums/subject.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_quiz_state.freezed.dart';

enum CreateQuizMode { manual, aiGenerated }

@freezed
abstract class CreateQuizState with _$CreateQuizState {
  const CreateQuizState._();
  const factory CreateQuizState({
    // Form fields
    @Default('') String title,
    @Default('') String description,
    Subject? selectedSubject,
    String? selectedStudyMaterialId,
    @Default(CreateQuizMode.manual) CreateQuizMode mode,
    @Default(QuizType.flashcard) QuizType selectedQuizType,

    // Quiz items being created
    @Default([]) List<QuizItemData> quizItems,

    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    @Default(false) bool isGeneratingAi,
    @Default(false) bool isLoadingStudyMaterials,

    // UI states
    @Default(false) bool showValidationErrors,
    @Default(0) int currentQuizItemIndex,
    @Default(false) bool isExpanded,

    // Data
    @Default([]) List<StudyMaterialOption> availableStudyMaterials,

    // Error handling
    String? error,
    String? fieldError,

    // Success state
    QuizEntity? createdQuiz,
    @Default(false) bool isSuccess,
  }) = _CreateQuizState;
  // Computed properties
  bool get hasError => error != null || fieldError != null;
  bool get hasAnyLoading =>
      isLoading || isCreating || isGeneratingAi || isLoadingStudyMaterials;
  bool get isFormValid {
    return title.trim().isNotEmpty &&
        quizItems.isNotEmpty &&
        quizItems.every((item) => item.isValid) &&
        _areAllItemsOfSelectedType &&
        (mode == CreateQuizMode.manual || selectedStudyMaterialId != null);
  }

  bool get _areAllItemsOfSelectedType {
    if (quizItems.isEmpty) return true;

    final expectedItemType =
        selectedQuizType == QuizType.flashcard
            ? QuizItemType.flashcard
            : QuizItemType.multipleChoice;

    return quizItems.every((item) => item.type == expectedItemType);
  }

  bool get canAddMoreItems => quizItems.length < 50; // Max 50 items per quiz

  bool get hasQuizItems => quizItems.isNotEmpty;

  int get validQuizItemsCount => quizItems.where((item) => item.isValid).length;

  bool get hasLinkedStudyMaterial => selectedStudyMaterialId != null;

  List<QuizItemData> get validQuizItems =>
      quizItems.where((item) => item.isValid).toList();
  String? get titleError {
    if (!showValidationErrors) return null;
    if (title.trim().isEmpty) {
      return 'Quiz title is required';
    }
    if (title.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (title.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  String? get studyMaterialError {
    if (!showValidationErrors) return null;
    if (mode == CreateQuizMode.aiGenerated && selectedStudyMaterialId == null) {
      return 'Please select a study material for AI generation';
    }
    return null;
  }

  String? get quizItemsError {
    if (!showValidationErrors) return null;
    if (mode == CreateQuizMode.manual && quizItems.isEmpty) {
      return 'Please add at least one quiz item';
    }
    if (mode == CreateQuizMode.manual && validQuizItemsCount == 0) {
      return 'Please complete at least one quiz item';
    }
    return null;
  }
}

@freezed
abstract class QuizItemData with _$QuizItemData {
  const QuizItemData._();

  const factory QuizItemData({
    required String id,
    @Default(QuizItemType.flashcard) QuizItemType type,
    @Default('') String question,
    @Default('') String answer,
    @Default([]) List<String> mcqOptions,
    @Default(0) int correctOptionIndex,
    @Default(false) bool isExpanded,
  }) = _QuizItemData;
  bool get isValid {
    // Question is always required
    if (question.trim().isEmpty) return false;

    if (type == QuizItemType.flashcard) {
      // For flashcards, answer is required
      if (answer.trim().isEmpty) return false;
    } else if (type == QuizItemType.multipleChoice) {
      // For MCQ, need at least 2 non-empty options and valid correct option index
      final nonEmptyOptions =
          mcqOptions.where((option) => option.trim().isNotEmpty).toList();
      if (nonEmptyOptions.length < 2) return false;
      if (correctOptionIndex >= mcqOptions.length || correctOptionIndex < 0)
        return false;
      // The correct option must not be empty
      if (correctOptionIndex < mcqOptions.length &&
          mcqOptions[correctOptionIndex].trim().isEmpty)
        return false;
    }

    return true;
  }

  String? get questionError {
    if (question.trim().isEmpty) {
      return 'Question is required';
    }
    if (question.trim().length < 3) {
      return 'Question must be at least 3 characters';
    }
    return null;
  }

  String? get answerError {
    if (type == QuizItemType.flashcard) {
      if (answer.trim().isEmpty) {
        return 'Answer is required';
      }
      if (answer.trim().length < 1) {
        return 'Answer must be at least 1 character';
      }
    }
    return null;
  }

  List<String?> get mcqOptionErrors {
    if (type != QuizItemType.multipleChoice) return [];

    return mcqOptions.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      // Only show error for required options (at least first 2) or if it's the selected correct answer
      final isRequired = index < 2 || index == correctOptionIndex;

      if (isRequired && option.trim().isEmpty) {
        if (index == correctOptionIndex) {
          return 'The correct answer option cannot be empty';
        }
        return 'Option is required';
      }
      return null;
    }).toList();
  }

  bool get hasMcqErrors {
    return mcqOptionErrors.any((error) => error != null);
  }
}

@freezed
abstract class StudyMaterialOption with _$StudyMaterialOption {
  const factory StudyMaterialOption({
    required String id,
    required String title,
    Subject? subject,
    required String contentType,
  }) = _StudyMaterialOption;
}
