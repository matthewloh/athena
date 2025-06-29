import 'package:athena/domain/enums/subject.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/usecases/params/create_quiz_params.dart';
import 'package:athena/features/review/domain/usecases/generate_ai_questions_usecase.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/presentation/providers/study_material_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_quiz_viewmodel.g.dart';

@riverpod
class CreateQuizViewModel extends _$CreateQuizViewModel {
  int _tempIdCounter = 0;

  String _generateTempId() {
    return 'temp_${DateTime.now().millisecondsSinceEpoch}_${++_tempIdCounter}';
  }

  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  // Helper method to convert ContentType to display string
  String _getContentTypeDisplayName(ContentType contentType) {
    switch (contentType) {
      case ContentType.typedText:
        return 'Text';
      case ContentType.textFile:
        return 'Text File';
      case ContentType.imageFile:
        return 'Image File';
    }
  }

  @override
  CreateQuizState build() {
    // Initialize with empty state
    return const CreateQuizState();
  }

  // Initialize screen with optional study material and mode
  void initialize({String? studyMaterialId, CreateQuizMode? initialMode}) {
    String? updatedStudyMaterialId = state.selectedStudyMaterialId;
    CreateQuizMode updatedMode = state.mode;

    if (studyMaterialId != null) {
      updatedStudyMaterialId = studyMaterialId;
      // Default to AI generated mode if study material is provided
      updatedMode = CreateQuizMode.aiGenerated;
    }

    if (initialMode != null) {
      updatedMode = initialMode;
    }

    // Update state if anything changed
    if (updatedStudyMaterialId != state.selectedStudyMaterialId ||
        updatedMode != state.mode) {
      state = state.copyWith(
        selectedStudyMaterialId: updatedStudyMaterialId,
        mode: updatedMode,
      );
    }

    _loadStudyMaterials();
  }

  // Load available study materials
  Future<void> _loadStudyMaterials() async {
    state = state.copyWith(isLoadingStudyMaterials: true, error: null);

    try {
      final userId = _getCurrentUserId();
      if (userId == null) {
        state = state.copyWith(
          isLoadingStudyMaterials: false,
          error: 'User not authenticated',
        );
        return;
      }

      final useCase = ref.read(getAllStudyMaterialsUseCaseProvider);
      final result = await useCase.call(userId);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingStudyMaterials: false,
            error: 'Failed to load study materials: ${failure.message}',
          );
        },
        (studyMaterials) {
          // Convert StudyMaterialEntity to StudyMaterialOption
          final options =
              studyMaterials.map((material) {
                return StudyMaterialOption(
                  id: material.id,
                  title: material.title,
                  subject: material.subject,
                  contentType: _getContentTypeDisplayName(material.contentType),
                );
              }).toList();

          state = state.copyWith(
            isLoadingStudyMaterials: false,
            availableStudyMaterials: options,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingStudyMaterials: false,
        error: 'Failed to load study materials: ${e.toString()}',
      );
    }
  }

  // Form field updates
  void updateTitle(String title) {
    state = state.copyWith(title: title, fieldError: null);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateSubject(Subject? subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  void updateStudyMaterial(String? studyMaterialId) {
    state = state.copyWith(selectedStudyMaterialId: studyMaterialId);
  }

  void updateMode(CreateQuizMode mode) {
    state = state.copyWith(
      mode: mode,
      quizItems: mode == CreateQuizMode.aiGenerated ? [] : state.quizItems,
    );
  }

  void updateQuizType(QuizType quizType) {
    state = state.copyWith(
      selectedQuizType: quizType,
      // Clear existing quiz items when changing type to avoid mixed types
      quizItems: [],
    );
  }

  // Quiz item management
  void addQuizItem() {
    if (!state.canAddMoreItems) return;

    final itemType =
        state.selectedQuizType == QuizType.flashcard
            ? QuizItemType.flashcard
            : QuizItemType.multipleChoice;
    final newItem = QuizItemData(
      id: _generateTempId(),
      type: itemType,
      isExpanded: true,
      mcqOptions:
          itemType == QuizItemType.multipleChoice
              ? ['', '', '', ''] // Initialize with 4 empty options for MCQ
              : [],
    );

    final updatedItems = [...state.quizItems, newItem];
    state = state.copyWith(
      quizItems: updatedItems,
      currentQuizItemIndex: updatedItems.length - 1,
    );
  }

  void removeQuizItem(String itemId) {
    final updatedItems =
        state.quizItems.where((item) => item.id != itemId).toList();
    state = state.copyWith(quizItems: updatedItems);
  }

  void updateQuizItem(String itemId, QuizItemData updatedItem) {
    final updatedItems =
        state.quizItems.map((item) {
          return item.id == itemId ? updatedItem : item;
        }).toList();

    state = state.copyWith(quizItems: updatedItems);
  }

  void toggleQuizItemExpansion(String itemId) {
    final updatedItems =
        state.quizItems.map((item) {
          return item.id == itemId
              ? item.copyWith(isExpanded: !item.isExpanded)
              : item;
        }).toList();

    state = state.copyWith(quizItems: updatedItems);
  }

  void reorderQuizItems(int oldIndex, int newIndex) {
    final items = [...state.quizItems];
    if (newIndex > oldIndex) newIndex--;

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    state = state.copyWith(quizItems: items);
  }

  // AI Generation
  Future<void> generateAiQuestions({int numQuestions = 10}) async {
    // AI determines optimal count up to this maximum
    if (state.selectedStudyMaterialId == null) {
      state = state.copyWith(
        fieldError: 'Please select a study material first',
      );
      return;
    }

    state = state.copyWith(isGeneratingAi: true, error: null);

    try {
      final useCase = ref.read(generateAiQuestionsUseCaseProvider);
      final params = GenerateAiQuestionsParams(
        studyMaterialId: state.selectedStudyMaterialId!,
        quizType:
            state.selectedQuizType == QuizType.flashcard
                ? 'flashcard'
                : 'multiple_choice',
        maxQuestions: numQuestions, // Changed from numQuestions to maxQuestions
        difficultyLevel: 'medium',
      );

      print(
        '🤖 Generating AI questions with params: ${params.studyMaterialId}, ${params.quizType}, ${params.maxQuestions}',
      );

      final result = await useCase.call(params);

      result.fold(
        (failure) {
          // Debug print the detailed error for developers
          print('❌ AI Question Generation Failed:');
          print('   Study Material ID: ${params.studyMaterialId}');
          print('   Quiz Type: ${params.quizType}');
          print('   Max Questions: ${params.maxQuestions}');
          print('   Error Type: ${failure.runtimeType}');
          print('   Error Message: ${failure.toString()}');

          // Provide user-friendly error messages
          String userFriendlyMessage;
          final errorMessage = failure.toString().toLowerCase();

          if (errorMessage.contains('no text content available')) {
            userFriendlyMessage =
                'Unable to generate questions from this study material. The content may be empty or not suitable for quiz generation.';
          } else if (errorMessage.contains('type validation failed') ||
              errorMessage.contains('validation failed')) {
            userFriendlyMessage =
                'AI generated an unexpected response format. Please try again - this usually resolves on retry.';
          } else if (errorMessage.contains('authentication required')) {
            userFriendlyMessage = 'Please sign in again to generate questions.';
          } else if (errorMessage.contains('material not found')) {
            userFriendlyMessage =
                'The selected study material could not be found. Please try selecting a different material.';
          } else if (errorMessage.contains('too short')) {
            userFriendlyMessage =
                'This study material is too short to generate meaningful questions. Please select material with more content.';
          } else if (errorMessage.contains('network') ||
              errorMessage.contains('connection')) {
            userFriendlyMessage =
                'Unable to connect to our AI service. Please check your internet connection and try again.';
          } else if (errorMessage.contains('timeout')) {
            userFriendlyMessage =
                'The AI service is taking too long to respond. Please try again in a moment.';
          } else if (errorMessage.contains('rate limit') ||
              errorMessage.contains('quota')) {
            userFriendlyMessage =
                'AI service is temporarily busy. Please wait a moment and try again.';
          } else {
            userFriendlyMessage =
                'Unable to generate questions at the moment. Please try again or select a different study material.';
          }

          state = state.copyWith(
            isGeneratingAi: false,
            error: userFriendlyMessage,
          );
        },
        (questions) {
          print(
            '✅ AI Question Generation Successful: Generated ${questions.length} questions',
          );

          final generatedItems =
              questions.map<QuizItemData>((q) {
                final itemType =
                    state.selectedQuizType == QuizType.flashcard
                        ? QuizItemType.flashcard
                        : QuizItemType.multipleChoice;

                return QuizItemData(
                  id: q['id']?.toString() ?? _generateTempId(),
                  type: itemType,
                  question: q['question']?.toString() ?? '',
                  answer: q['answer']?.toString() ?? '',
                  mcqOptions:
                      itemType == QuizItemType.multipleChoice
                          ? List<String>.from(q['options'] ?? ['', '', '', ''])
                          : [],
                  correctOptionIndex: q['correct_option_index'] ?? 0,
                  isExpanded: false,
                );
              }).toList();

          state = state.copyWith(
            isGeneratingAi: false,
            quizItems: generatedItems,
          );
        },
      );
    } catch (e) {
      // Debug print unexpected errors
      print('🚨 Unexpected AI Generation Error:');
      print('   Study Material ID: ${state.selectedStudyMaterialId}');
      print('   Quiz Type: ${state.selectedQuizType}');
      print('   Exception Type: ${e.runtimeType}');
      print('   Exception: $e');
      print('   Stack Trace: ${StackTrace.current}');

      // Provide a generic user-friendly message for unexpected errors
      state = state.copyWith(
        isGeneratingAi: false,
        error:
            'An unexpected error occurred while generating questions. Please try again or contact support if the problem persists.',
      );
    }
  }

  // Validation
  void showValidationErrors() {
    state = state.copyWith(showValidationErrors: true);
  }

  void clearErrors() {
    state = state.copyWith(error: null, fieldError: null);
  }

  // Create quiz
  Future<void> createQuiz() async {
    // Validate form
    if (!state.isFormValid) {
      showValidationErrors();
      return;
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isCreating: true, error: null);

    try {
      // Convert QuizItemData to CreateQuizItemParams
      final quizItemParams =
          state.validQuizItems.map((item) {
            final now = DateTime.now();
            return CreateQuizItemParams(
              quizId: '', // Will be set after quiz creation
              userId: userId,
              itemType: item.type,
              questionText: item.question.trim(),
              answerText:
                  item.type == QuizItemType.flashcard
                      ? item.answer.trim()
                      : '', // For MCQ, answer_text can be empty as answer is in mcqCorrectOptionKey
              mcqOptions:
                  item.type == QuizItemType.multipleChoice
                      ? Map<String, dynamic>.fromIterables(
                        ['A', 'B', 'C', 'D'].take(item.mcqOptions.length),
                        item.mcqOptions,
                      )
                      : null,
              mcqCorrectOptionKey:
                  item.type == QuizItemType.multipleChoice
                      ? ['A', 'B', 'C', 'D'][item.correctOptionIndex]
                      : null,
              // Spaced repetition defaults for new items
              easinessFactor: 2.5, // Default SM-2 easiness factor
              intervalDays: 1, // Initial interval
              repetitions: 0, // New item, no repetitions yet
              lastReviewedAt: now, // Set to now for new items
              nextReviewDate: now.add(
                const Duration(days: 1),
              ), // Review tomorrow
            );
          }).toList();

      final params = CreateQuizParams(
        userId: userId,
        title: state.title.trim(),
        quizType: state.selectedQuizType,
        studyMaterialId: state.selectedStudyMaterialId,
        subject: state.selectedSubject,
        description:
            state.description.trim().isEmpty ? null : state.description.trim(),
        quizItems: quizItemParams,
      );

      final useCase = ref.read(createQuizUseCaseProvider);
      final result = await useCase.call(params);

      result.fold(
        (failure) {
          state = state.copyWith(isCreating: false, error: failure.message);
        },
        (createdQuiz) {
          // Update state with created quiz
          state = state.copyWith(
            isCreating: false,
            createdQuiz: createdQuiz,
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'Failed to create quiz: ${e.toString()}',
      );
    }
  }

  // Reset state
  void reset() {
    state = const CreateQuizState();
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false, createdQuiz: null);
  }
}
