import 'package:athena/domain/enums/subject.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_quiz_state.freezed.dart';

@freezed
abstract class EditQuizState with _$EditQuizState {
  const EditQuizState._();
  
  const factory EditQuizState({
    // Core data
    QuizEntity? originalQuiz,
    @Default([]) List<QuizItemEntity> originalQuizItems,
    
    // Form fields
    @Default('') String title,
    @Default('') String description,
    Subject? selectedSubject,
    String? selectedStudyMaterialId,
    
    // Quiz items being edited
    @Default([]) List<QuizItemData> quizItems,
    
    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingQuizData,
    @Default(false) bool isUpdating,
    @Default(false) bool isLoadingStudyMaterials,
    
    // UI states
    @Default(false) bool showValidationErrors,
    @Default(false) bool hasUnsavedChanges,
    
    // Data
    @Default([]) List<StudyMaterialOption> availableStudyMaterials,
    
    // Error handling
    String? error,
    String? fieldError,
    
    // Success state
    QuizEntity? updatedQuiz,
    @Default(false) bool isSuccess,
  }) = _EditQuizState;

  // Computed properties
  bool get hasError => error != null || fieldError != null;
  bool get hasAnyLoading => isLoading || isLoadingQuizData || isUpdating || isLoadingStudyMaterials;
  bool get hasOriginalQuiz => originalQuiz != null;
  
  bool get isFormValid {
    return title.trim().isNotEmpty &&
        title.trim().length >= 3 &&
        title.trim().length <= 100 &&
        quizItems.isNotEmpty &&
        quizItems.every((item) => item.isValid) && // All items must be valid
        _areAllItemsOfSelectedType;
  }

  bool get _areAllItemsOfSelectedType {
    if (quizItems.isEmpty || originalQuiz == null) return true;

    final expectedItemType = originalQuiz!.quizType == QuizType.flashcard
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

  // Check if any changes have been made
  bool get _hasBasicInfoChanges {
    if (originalQuiz == null) return false;
    
    return title.trim() != originalQuiz!.title ||
        description.trim() != (originalQuiz!.description ?? '') ||
        selectedSubject != originalQuiz!.subject ||
        selectedStudyMaterialId != originalQuiz!.studyMaterialId;
  }

  bool get _hasQuizItemsChanges {
    if (originalQuizItems.length != quizItems.length) return true;
    
    for (int i = 0; i < originalQuizItems.length; i++) {
      if (i >= quizItems.length) return true;
      
      final original = originalQuizItems[i];
      final current = quizItems[i];
      
      if (original.questionText != current.question ||
          original.answerText != current.answer) {
        return true;
      }
      
      // Check MCQ options if it's a multiple choice item
      if (original.itemType == QuizItemType.multipleChoice) {
        final originalOptions = original.mcqOptions;
        if (originalOptions != null) {
          final originalOptionsList = originalOptions.values.toList();
          if (originalOptionsList.length != current.mcqOptions.length) return true;
          
          for (int j = 0; j < originalOptionsList.length; j++) {
            if (j >= current.mcqOptions.length) return true;
            if (originalOptionsList[j] != current.mcqOptions[j]) return true;
          }
          
          // Check correct option
          final originalCorrectKey = original.mcqCorrectOptionKey;
          if (originalCorrectKey != null) {
            final originalCorrectIndex = originalOptions.keys.toList().indexOf(originalCorrectKey);
            if (originalCorrectIndex != current.correctOptionIndex) return true;
          }
        }
      }
    }
    
    return false;
  }

  bool get hasActualChanges => _hasBasicInfoChanges || _hasQuizItemsChanges;

  // Validation error getters
  String? get titleError {
    if (!showValidationErrors) return null;
    if (title.trim().isEmpty) {
      return 'Title is required';
    }
    if (title.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (title.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  String? get quizItemsError {
    if (!showValidationErrors) return null;
    if (quizItems.isEmpty) {
      return 'At least one quiz item is required';
    }
    if (validQuizItemsCount == 0) {
      return 'At least one valid quiz item is required';
    }
    return null;
  }
}
