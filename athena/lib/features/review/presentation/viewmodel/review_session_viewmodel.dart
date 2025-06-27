import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/domain/usecases/start_review_session_usecase.dart';
import 'package:athena/features/review/domain/usecases/submit_review_response_usecase.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:athena/features/review/presentation/viewmodel/review_session_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_session_viewmodel.g.dart';

/// ViewModel for managing review session state and operations.
///
/// Handles the complete review session flow:
/// - Starting and managing review sessions
/// - Presenting quiz items (flashcards and MCQs)
/// - Processing user responses and applying spaced repetition
/// - Tracking session progress and performance
@riverpod
class ReviewSessionViewModel extends _$ReviewSessionViewModel {
  @override
  ReviewSessionState build() {
    return const ReviewSessionState();
  }

  /// Gets the current user ID from auth provider
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  /// Starts a new review session for the specified quiz.
  ///
  /// [quizId] - The ID of the quiz to review
  /// [sessionType] - Type of session (mixed, dueOnly, newOnly)
  /// [maxItems] - Optional limit on number of items to review
  Future<void> startReviewSession({
    required String quizId,
    SessionType sessionType = SessionType.mixed,
    int? maxItems,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(
        error: 'User not authenticated',
        isLoadingSession: false,
      );
      return;
    }

    state = state.copyWith(
      isLoadingSession: true,
      error: null,
      isSessionCompleted: false,
      isSessionAbandoned: false,
    );

    try {
      final startSessionUseCase = ref.read(startReviewSessionUseCaseProvider);

      final params = StartReviewSessionParams(
        quizId: quizId,
        userId: userId,
        sessionType: sessionType,
        maxItems: maxItems,
      );

      final result = await startSessionUseCase.call(params);

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoadingSession: false,
            error: 'Failed to start review session: ${failure.message}',
          );
        },
        (sessionResult) {
          state = state.copyWith(
            isLoadingSession: false,
            session: sessionResult.session,
            items: sessionResult.items,
            currentItemIndex: 0,
            currentItem:
                sessionResult.items.isNotEmpty
                    ? sessionResult.items.first
                    : null,
            responseStartTime: DateTime.now(),
            error: null,
          );

          debugPrint(
            'Review session started: ${sessionResult.items.length} items',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSession: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Shows the answer for a flashcard.
  void showAnswer() {
    if (!state.isCurrentItemFlashcard || state.isShowingAnswer) return;

    state = state.copyWith(isShowingAnswer: true);
  }

  /// Selects an option for a multiple choice question.
  ///
  /// [optionKey] - The key of the selected option (e.g., "A", "B", "C", "D")
  void selectMcqOption(String optionKey) {
    if (!state.isCurrentItemMcq) return;

    // Validate that the option exists and is within allowed range
    final currentOptions = state.currentMcqOptions;
    if (currentOptions.isEmpty) return;

    // Check if the selected option exists in the current item's options
    final validOptionKeys = currentOptions.map((e) => e.key).toSet();
    if (!validOptionKeys.contains(optionKey)) {
      // Invalid option selected - ignore the selection
      debugPrint('Warning: Attempted to select invalid MCQ option: $optionKey');
      debugPrint('Valid options: ${validOptionKeys.join(', ')}');
      return;
    }

    // Validate option count (2-4 options allowed)
    if (currentOptions.length < 2 || currentOptions.length > 4) {
      debugPrint(
        'Warning: MCQ has invalid number of options: ${currentOptions.length}',
      );
      return;
    }

    state = state.copyWith(selectedMcqOption: optionKey, hasMcqAnswered: true);
  }

  /// Submits a response for the current quiz item.
  ///
  /// [difficultyRating] - User's self-assessment of difficulty
  Future<void> submitResponse(DifficultyRating difficultyRating) async {
    if (!state.canSubmitResponse ||
        state.session == null ||
        state.currentItem == null) {
      return;
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isSubmittingResponse: true, error: null);

    try {
      final submitResponseUseCase = ref.read(
        submitReviewResponseUseCaseProvider,
      );

      // Calculate response time
      final responseTime =
          state.responseStartTime != null
              ? DateTime.now().difference(state.responseStartTime!).inSeconds
              : null;

      // Determine if answer is correct (for MCQ)
      bool? isCorrect;
      String? userAnswer;

      if (state.isCurrentItemMcq) {
        isCorrect = state.isMcqSelectionCorrect;
        userAnswer = state.selectedMcqOption;
      } else {
        // For flashcards, correctness is subjective based on difficulty rating
        isCorrect = difficultyRating.index >= 2; // Good or Easy
      }

      final params = SubmitReviewResponseParams(
        sessionId: state.session!.id,
        quizItemId: state.currentItem!.id,
        userId: userId,
        difficultyRating: difficultyRating,
        responseTimeSeconds: responseTime,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
      );

      final result = await submitResponseUseCase.call(params);

      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null)!;
        state = state.copyWith(
          isSubmittingResponse: false,
          error: 'Failed to submit response: ${failure.message}',
        );
      } else {
        final responseResult = result.fold((l) => null, (r) => r)!;

        // Update responses list
        final updatedResponses = [
          ...state.responses,
          responseResult.reviewResponse,
        ];

        // Update progress
        final newCompletedItems = state.completedItems + 1;
        final newCorrectResponses =
            state.correctResponses + (isCorrect == true ? 1 : 0);

        // Calculate new average difficulty
        final difficultyValue =
            difficultyRating.index + 1; // Convert 0-3 to 1-4
        final newAverageDifficulty =
            state.completedItems == 0
                ? difficultyValue.toDouble()
                : ((state.averageDifficulty * state.completedItems) +
                        difficultyValue) /
                    newCompletedItems;

        state = state.copyWith(
          isSubmittingResponse: false,
          responses: updatedResponses,
          completedItems: newCompletedItems,
          correctResponses: newCorrectResponses,
          averageDifficulty: newAverageDifficulty,
          error: null,
        );

        debugPrint('Response submitted for item ${state.currentItem!.id}');

        // Move to next item or complete session
        await _moveToNextItem();
      }
    } catch (e) {
      state = state.copyWith(
        isSubmittingResponse: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Moves to the next item in the review session.
  Future<void> _moveToNextItem() async {
    if (state.hasNextItem) {
      final nextIndex = state.currentItemIndex + 1;
      state = state.copyWith(
        currentItemIndex: nextIndex,
        currentItem: state.items[nextIndex],
        isShowingAnswer: false,
        selectedMcqOption: null,
        hasMcqAnswered: false,
        responseStartTime: DateTime.now(),
      );
    } else {
      // Session completed
      await _completeSession();
    }
  }

  /// Marks the session as completed and updates it in the database.
  Future<void> _completeSession() async {
    final currentSession = state.session;
    if (currentSession == null) {
      debugPrint('Cannot complete session: no active session found');
      return;
    }

    final now = DateTime.now();
    final sessionDurationSeconds =
        now.difference(currentSession.startedAt).inSeconds;

    // Update session with completion data
    final updatedSession = ReviewSessionEntity(
      id: currentSession.id,
      userId: currentSession.userId,
      quizId: currentSession.quizId,
      sessionType: currentSession.sessionType,
      totalItems: currentSession.totalItems,
      completedItems: state.completedItems,
      correctResponses: state.correctResponses,
      averageDifficulty:
          state.averageDifficulty > 0 ? state.averageDifficulty : null,
      sessionDurationSeconds: sessionDurationSeconds,
      status: SessionStatus.completed,
      startedAt: currentSession.startedAt,
      completedAt: now,
    );

    // Update session in database
    try {
      final updateUseCase = ref.read(updateReviewSessionUseCaseProvider);
      final result = await updateUseCase.call(updatedSession);

      result.fold(
        (failure) {
          debugPrint('Failed to update completed session: ${failure.message}');
          // Still mark as completed locally even if database update fails
          state = state.copyWith(
            isSessionCompleted: true,
            responseStartTime: null,
            session: updatedSession,
          );
        },
        (session) {
          debugPrint('Session completed and saved: ${session.id}');
          state = state.copyWith(
            isSessionCompleted: true,
            responseStartTime: null,
            session: session,
          );
        },
      );
    } catch (e) {
      debugPrint('Error completing session: $e');
      // Still mark as completed locally even if database update fails
      state = state.copyWith(
        isSessionCompleted: true,
        responseStartTime: null,
        session: updatedSession,
      );
    }

    debugPrint(
      'Review session completed: ${state.completedItems} items reviewed in ${sessionDurationSeconds}s',
    );
  }

  /// Moves to the previous item (for navigation purposes).
  void moveToPreviousItem() {
    if (state.hasPreviousItem && !state.isSubmittingResponse) {
      final prevIndex = state.currentItemIndex - 1;
      state = state.copyWith(
        currentItemIndex: prevIndex,
        currentItem: state.items[prevIndex],
        isShowingAnswer: false,
        selectedMcqOption: null,
        hasMcqAnswered: false,
        responseStartTime: DateTime.now(),
      );
    }
  }

  /// Abandons the current review session.
  void abandonSession() {
    state = state.copyWith(isSessionAbandoned: true, responseStartTime: null);

    debugPrint('Review session abandoned');
  }

  /// Resets the state (for starting a new session).
  void resetState() {
    state = const ReviewSessionState();
  }

  /// Retries the current operation (for error recovery).
  void retry() {
    if (state.session == null) {
      // Retry starting session - this would need the original parameters
      // For now, just clear the error
      state = state.copyWith(error: null);
    } else if (state.isSubmittingResponse) {
      // Retry submitting response - would need the original difficulty rating
      // For now, just clear the error
      state = state.copyWith(error: null, isSubmittingResponse: false);
    }
  }
}
