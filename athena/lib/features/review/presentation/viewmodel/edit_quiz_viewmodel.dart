import 'package:athena/domain/enums/subject.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/usecases/params/update_quiz_params.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
import 'package:athena/features/review/presentation/viewmodel/edit_quiz_state.dart';
import 'package:athena/features/review/presentation/viewmodel/quiz_detail_viewmodel.dart';
import 'package:athena/features/review/presentation/viewmodel/review_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_quiz_viewmodel.g.dart';

@riverpod
class EditQuizViewModel extends _$EditQuizViewModel {
  int _tempIdCounter = 0;

  String _generateTempId() {
    return 'temp_edit_${DateTime.now().millisecondsSinceEpoch}_${++_tempIdCounter}';
  }

  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  @override
  EditQuizState build(String quizId) {
    // Initialize with loading state and start loading quiz data
    Future.microtask(() => _loadQuizData(quizId));
    return const EditQuizState(isLoadingQuizData: true);
  }

  // Load quiz data for editing
  Future<void> _loadQuizData(String quizId) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(
        isLoadingQuizData: false,
        error: 'User not authenticated',
      );
      return;
    }

    try {
      state = state.copyWith(isLoadingQuizData: true, error: null);

      // Get quiz details
      final getQuizUseCase = ref.read(getQuizDetailUseCaseProvider);
      final quizResult = await getQuizUseCase(quizId);

      if (quizResult.isLeft()) {
        final failure = quizResult.fold((l) => l, (r) => null);
        state = state.copyWith(
          isLoadingQuizData: false,
          error: failure?.message ?? 'Failed to load quiz',
        );
        return;
      }

      final quiz = quizResult.fold((l) => null, (r) => r)!;

      // Get quiz items
      final getQuizItemsUseCase = ref.read(getAllQuizItemsUseCaseProvider);
      final itemsResult = await getQuizItemsUseCase(quizId);

      if (itemsResult.isLeft()) {
        final failure = itemsResult.fold((l) => l, (r) => null);
        state = state.copyWith(
          isLoadingQuizData: false,
          error: failure?.message ?? 'Failed to load quiz items',
        );
        return;
      }

      final quizItems = itemsResult.fold((l) => <QuizItemEntity>[], (r) => r);

      // Convert quiz items to editable format
      final editableItems = quizItems.map((item) {
        return QuizItemData(
          id: item.id,
          type: item.itemType,
          question: item.questionText,
          answer: item.answerText,
          mcqOptions: _extractMcqOptions(item),
          correctOptionIndex: _extractCorrectOptionIndex(item),
          isExpanded: false,
        );
      }).toList();

      // Update state with loaded data
      state = state.copyWith(
        isLoadingQuizData: false,
        originalQuiz: quiz,
        originalQuizItems: quizItems,
        title: quiz.title,
        description: quiz.description ?? '',
        selectedSubject: quiz.subject,
        selectedStudyMaterialId: quiz.studyMaterialId,
        quizItems: editableItems,
        error: null,
      );

      // Load study materials
      _loadStudyMaterials();
    } catch (e) {
      state = state.copyWith(
        isLoadingQuizData: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Extract MCQ options from quiz item entity
  List<String> _extractMcqOptions(QuizItemEntity item) {
    if (item.itemType != QuizItemType.multipleChoice || item.mcqOptions == null) {
      return [];
    }

    final options = item.mcqOptions as Map<String, dynamic>;
    // Sort by key to maintain order (a, b, c, d)
    final sortedKeys = options.keys.toList();
    sortedKeys.sort();
    return sortedKeys.map((key) => options[key]?.toString() ?? '').toList();
  }

  // Extract correct option index from quiz item entity
  int _extractCorrectOptionIndex(QuizItemEntity item) {
    if (item.itemType != QuizItemType.multipleChoice || 
        item.mcqOptions == null || 
        item.mcqCorrectOptionKey == null) {
      return 0;
    }

    final options = item.mcqOptions as Map<String, dynamic>;
    final sortedKeys = options.keys.toList();
    sortedKeys.sort();
    return sortedKeys.indexOf(item.mcqCorrectOptionKey!).clamp(0, sortedKeys.length - 1);
  }

  // Load available study materials
  Future<void> _loadStudyMaterials() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      state = state.copyWith(isLoadingStudyMaterials: true);

      // TODO: Load study materials from repository
      // For now, we'll use empty list
      final studyMaterials = <StudyMaterialOption>[];

      state = state.copyWith(
        isLoadingStudyMaterials: false,
        availableStudyMaterials: studyMaterials,
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
    state = state.copyWith(
      title: title,
      fieldError: null,
      hasUnsavedChanges: true,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(
      description: description,
      hasUnsavedChanges: true,
    );
  }

  void updateSubject(Subject? subject) {
    state = state.copyWith(
      selectedSubject: subject,
      hasUnsavedChanges: true,
    );
  }

  void updateStudyMaterial(String? studyMaterialId) {
    state = state.copyWith(
      selectedStudyMaterialId: studyMaterialId,
      hasUnsavedChanges: true,
    );
  }

  // Quiz item management
  void addQuizItem() {
    if (!state.canAddMoreItems || state.originalQuiz == null) return;

    final itemType = state.originalQuiz!.quizType == QuizType.flashcard
        ? QuizItemType.flashcard
        : QuizItemType.multipleChoice;

    final newItem = QuizItemData(
      id: _generateTempId(),
      type: itemType,
      question: '',
      answer: '',
      mcqOptions: itemType == QuizItemType.multipleChoice 
          ? ['', '', '', ''] 
          : [],
      correctOptionIndex: 0,
      isExpanded: true,
    );

    final updatedItems = [...state.quizItems, newItem];
    state = state.copyWith(
      quizItems: updatedItems,
      hasUnsavedChanges: true,
    );
  }

  void removeQuizItem(String itemId) {
    final updatedItems = state.quizItems.where((item) => item.id != itemId).toList();
    state = state.copyWith(
      quizItems: updatedItems,
      hasUnsavedChanges: true,
    );
  }

  void updateQuizItem(String itemId, QuizItemData updatedItem) {
    final updatedItems = state.quizItems.map((item) {
      return item.id == itemId ? updatedItem : item;
    }).toList();

    state = state.copyWith(
      quizItems: updatedItems,
      hasUnsavedChanges: true,
    );
  }

  void toggleQuizItemExpansion(String itemId) {
    final updatedItems = state.quizItems.map((item) {
      return item.id == itemId ? item.copyWith(isExpanded: !item.isExpanded) : item;
    }).toList();

    state = state.copyWith(quizItems: updatedItems);
  }

  void reorderQuizItems(int oldIndex, int newIndex) {
    final items = [...state.quizItems];
    if (newIndex > oldIndex) newIndex--;

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    state = state.copyWith(
      quizItems: items,
      hasUnsavedChanges: true,
    );
  }

  // Validation
  void showValidationErrors() {
    state = state.copyWith(showValidationErrors: true);
  }

  void clearErrors() {
    state = state.copyWith(error: null, fieldError: null);
  }

  // Update quiz
  Future<void> updateQuiz() async {
    final userId = _getCurrentUserId();
    final originalQuiz = state.originalQuiz;

    if (userId == null || originalQuiz == null) {
      state = state.copyWith(error: 'Missing required data for update');
      return;
    }

    // Validate form
    if (!state.isFormValid) {
      showValidationErrors();
      return;
    }

    // Check if there are actual changes
    if (!state.hasActualChanges) {
      state = state.copyWith(error: 'No changes to save');
      return;
    }

    try {
      state = state.copyWith(isUpdating: true, error: null);

      // Update basic quiz info
      final updateQuizParams = UpdateQuizParams(
        id: originalQuiz.id,
        userId: userId,
        title: state.title.trim(),
        studyMaterialId: state.selectedStudyMaterialId,
        subject: state.selectedSubject,
        description: state.description.trim().isEmpty ? null : state.description.trim(),
      );

      final updateQuizUseCase = ref.read(updateQuizUseCaseProvider);
      final updateResult = await updateQuizUseCase(updateQuizParams);

      if (updateResult.isLeft()) {
        final failure = updateResult.fold((l) => l, (r) => null);
        state = state.copyWith(
          isUpdating: false,
          error: failure?.message ?? 'Failed to update quiz',
        );
        return;
      }

      final updatedQuiz = updateResult.fold((l) => null, (r) => r)!;

      // Update quiz items if there are changes
      await _updateQuizItems(originalQuiz.id);

      // Invalidate related providers to refresh other screens
      ref.invalidate(quizDetailViewModelProvider(originalQuiz.id));
      ref.invalidate(reviewViewModelProvider);

      state = state.copyWith(
        isUpdating: false,
        updatedQuiz: updatedQuiz,
        isSuccess: true,
        hasUnsavedChanges: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Update quiz items (create, update, delete)
  Future<void> _updateQuizItems(String quizId) async {
    final originalItems = state.originalQuizItems;
    final currentItems = state.quizItems;
    
    // Maps to track items by ID
    final originalItemsMap = {for (var item in originalItems) item.id: item};
    final currentItemsMap = {for (var item in currentItems) item.id: item};
    
    // Find items to delete (in original but not in current)
    final itemsToDelete = originalItems
        .where((item) => !currentItemsMap.containsKey(item.id))
        .toList();
    
    // Find items to create (temp IDs in current)
    final itemsToCreate = currentItems
        .where((item) => item.id.startsWith('temp_'))
        .toList();
    
    // Find items to update (in both but different content)
    final itemsToUpdate = currentItems
        .where((item) => 
            !item.id.startsWith('temp_') && 
            originalItemsMap.containsKey(item.id) &&
            _hasQuizItemChanged(originalItemsMap[item.id]!, item))
        .toList();

    try {
      // Delete items
      final deleteUseCase = ref.read(deleteQuizItemUseCaseProvider);
      for (final item in itemsToDelete) {
        final deleteResult = await deleteUseCase(item.id);
        if (deleteResult.isLeft()) {
          final failure = deleteResult.fold((l) => l, (r) => null);
          throw Exception('Failed to delete item: ${failure?.message}');
        }
      }

      // Create new items
      final createUseCase = ref.read(createQuizItemUseCaseProvider);
      for (final item in itemsToCreate) {
        final quizItemEntity = _convertToQuizItemEntity(item, quizId);
        final createResult = await createUseCase(quizItemEntity);
        if (createResult.isLeft()) {
          final failure = createResult.fold((l) => l, (r) => null);
          throw Exception('Failed to create item: ${failure?.message}');
        }
      }

      // Update existing items
      final updateUseCase = ref.read(updateQuizItemUseCaseProvider);
      for (final item in itemsToUpdate) {
        final originalItem = originalItemsMap[item.id]!;
        final updatedEntity = _convertToQuizItemEntity(item, quizId, originalItem);
        final updateResult = await updateUseCase(updatedEntity);
        if (updateResult.isLeft()) {
          final failure = updateResult.fold((l) => l, (r) => null);
          throw Exception('Failed to update item: ${failure?.message}');
        }
      }
    } catch (e) {
      throw Exception('Failed to update quiz items: ${e.toString()}');
    }
  }

  // Check if a quiz item has changed
  bool _hasQuizItemChanged(QuizItemEntity original, QuizItemData current) {
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

        for (int i = 0; i < originalOptionsList.length; i++) {
          if (i >= current.mcqOptions.length) return true;
          if (originalOptionsList[i] != current.mcqOptions[i]) return true;
        }

        // Check correct option
        final originalCorrectKey = original.mcqCorrectOptionKey;
        if (originalCorrectKey != null) {
          final originalKeysList = originalOptions.keys.toList();
          originalKeysList.sort();
          final originalCorrectIndex = originalKeysList.indexOf(originalCorrectKey);
          if (originalCorrectIndex != current.correctOptionIndex) return true;
        }
      }
    }

    return false;
  }

  // Convert QuizItemData to QuizItemEntity
  QuizItemEntity _convertToQuizItemEntity(QuizItemData item, String quizId, [QuizItemEntity? original]) {
    final now = DateTime.now();
    
    // For MCQ, create options map and correct key
    Map<String, dynamic>? mcqOptions;
    String? mcqCorrectOptionKey;
    
    if (item.type == QuizItemType.multipleChoice) {
      mcqOptions = {};
      final keys = ['a', 'b', 'c', 'd'];
      for (int i = 0; i < item.mcqOptions.length && i < keys.length; i++) {
        if (item.mcqOptions[i].trim().isNotEmpty) {
          mcqOptions[keys[i]] = item.mcqOptions[i].trim();
        }
      }
      
      if (item.correctOptionIndex >= 0 && item.correctOptionIndex < keys.length) {
        mcqCorrectOptionKey = keys[item.correctOptionIndex];
      }
    }

    return QuizItemEntity(
      id: original?.id ?? '', // Will be generated by database for new items
      quizId: quizId,
      userId: _getCurrentUserId() ?? '',
      itemType: item.type,
      questionText: item.question.trim(),
      answerText: item.answer.trim(),
      mcqOptions: mcqOptions,
      mcqCorrectOptionKey: mcqCorrectOptionKey,
      easinessFactor: original?.easinessFactor ?? 2.5, // Default easiness factor
      intervalDays: original?.intervalDays ?? 1, // Default interval
      repetitions: original?.repetitions ?? 0, // Default repetitions
      lastReviewedAt: original?.lastReviewedAt ?? now,
      nextReviewDate: original?.nextReviewDate ?? now,
      metadata: original?.metadata,
      createdAt: original?.createdAt ?? now,
      updatedAt: now,
    );
  }

  // Reset state
  void reset() {
    final originalQuiz = state.originalQuiz;
    if (originalQuiz != null) {
      _loadQuizData(originalQuiz.id);
    } else {
      state = const EditQuizState();
    }
  }

  void clearSuccess() {
    state = state.copyWith(isSuccess: false, updatedQuiz: null);
  }

  // Check for unsaved changes before leaving
  bool hasUnsavedChanges() {
    return state.hasUnsavedChanges && state.hasActualChanges;
  }
}
