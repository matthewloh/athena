import 'package:athena/core/enums/subject.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/usecases/params/create_quiz_params.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
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

  @override
  CreateQuizState build() {
    // Initialize with empty state
    return const CreateQuizState();
  }

  // Initialize screen with optional study material
  void initialize({String? studyMaterialId}) {
    if (studyMaterialId != null) {
      state = state.copyWith(
        selectedStudyMaterialId: studyMaterialId,
        mode: CreateQuizMode.aiGenerated,
      );
    }
    _loadStudyMaterials();
  }

  // Load available study materials
  Future<void> _loadStudyMaterials() async {
    state = state.copyWith(isLoadingStudyMaterials: true, error: null);

    try {
      // TODO: Implement GetAllStudyMaterialsUseCase call
      // final useCase = ref.read(getAllStudyMaterialsUseCaseProvider);
      // final result = await useCase.call(userId);

      // For now, simulate loading with empty list
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        isLoadingStudyMaterials: false,
        availableStudyMaterials: [], // TODO: Replace with actual data
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
  Future<void> generateAiQuestions({int numQuestions = 5}) async {
    if (state.selectedStudyMaterialId == null) {
      state = state.copyWith(
        fieldError: 'Please select a study material first',
      );
      return;
    }

    state = state.copyWith(isGeneratingAi: true, error: null);

    try {
      // TODO: Implement GenerateAiQuizUseCase call
      // final useCase = ref.read(generateAiQuizUseCaseProvider);
      // final result = await useCase.call(GenerateAiQuizParams(
      //   studyMaterialId: state.selectedStudyMaterialId!,
      //   numQuestions: numQuestions,
      //   quizType: state.selectedQuizType!,
      // ));

      // Simulate AI generation for now
      await Future.delayed(const Duration(seconds: 2));

      final itemType =
          state.selectedQuizType == QuizType.flashcard
              ? QuizItemType.flashcard
              : QuizItemType.multipleChoice;
      final generatedItems = List.generate(numQuestions, (index) {
        return QuizItemData(
          id: _generateTempId(),
          type: itemType,
          question: 'Generated Question ${index + 1}',
          answer:
              itemType == QuizItemType.flashcard
                  ? 'Generated Answer ${index + 1}'
                  : '', // For MCQ, answer field is not used
          mcqOptions:
              itemType == QuizItemType.multipleChoice
                  ? ['Option A', 'Option B', 'Option C', 'Option D']
                  : [],
          correctOptionIndex: 0,
          isExpanded: false,
        );
      });

      state = state.copyWith(isGeneratingAi: false, quizItems: generatedItems);
    } catch (e) {
      state = state.copyWith(
        isGeneratingAi: false,
        error: 'Failed to generate AI questions: ${e.toString()}',
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
