import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_session_state.freezed.dart';

/// State for the review session screen.
///
/// Manages the current review session flow including:
/// - Session metadata and progress
/// - Current quiz item being reviewed
/// - Review history and responses
/// - UI state (loading, errors, completion)
@freezed
abstract class ReviewSessionState with _$ReviewSessionState {
  const factory ReviewSessionState({
    // Session data
    ReviewSessionEntity? session,
    @Default([]) List<QuizItemEntity> items,
    @Default([]) List<ReviewResponseEntity> responses,

    // Current review state
    @Default(0) int currentItemIndex,
    QuizItemEntity? currentItem,

    // UI state for current item
    @Default(false) bool isShowingAnswer,
    DateTime? responseStartTime,

    // Session progress
    @Default(0) int completedItems,
    @Default(0) int correctResponses,
    @Default(0.0) double averageDifficulty,

    // Loading and error states
    @Default(false) bool isLoadingSession,
    @Default(false) bool isSubmittingResponse,
    String? error,

    // Session completion
    @Default(false) bool isSessionCompleted,
    @Default(false) bool isSessionAbandoned,

    // Multiple choice specific state
    String? selectedMcqOption,
    @Default(false) bool hasMcqAnswered,

    // Statistics
    @Default(0) int totalTimeSpent, // in seconds
    @Default(0) int averageResponseTime, // in seconds
  }) = _ReviewSessionState;

  const ReviewSessionState._();

  /// Whether there are items to review
  bool get hasItems => items.isNotEmpty;

  /// Whether the session is active
  bool get isActive => session?.status == SessionStatus.active;

  /// Progress percentage (0-100)
  double get progressPercentage {
    if (items.isEmpty) return 0;
    return (currentItemIndex / items.length) * 100;
  }

  /// Whether there's a next item to review
  bool get hasNextItem => currentItemIndex < items.length - 1;

  /// Whether there's a previous item (for navigation)
  bool get hasPreviousItem => currentItemIndex > 0;

  /// Number of remaining items
  int get remainingItems => items.length - currentItemIndex;

  /// Whether the current item is a flashcard
  bool get isCurrentItemFlashcard =>
      currentItem?.itemType == QuizItemType.flashcard;

  /// Whether the current item is multiple choice
  bool get isCurrentItemMcq =>
      currentItem?.itemType == QuizItemType.multipleChoice;

  /// Accuracy percentage for completed items
  double get accuracyPercentage {
    if (completedItems == 0) return 0;
    return (correctResponses / completedItems) * 100;
  }

  /// Whether we can show the answer (for flashcards)
  bool get canShowAnswer => isCurrentItemFlashcard && !isShowingAnswer;

  /// Whether we can submit a response
  bool get canSubmitResponse {
    if (isSubmittingResponse) return false;
    if (isCurrentItemFlashcard) return isShowingAnswer;
    if (isCurrentItemMcq) return hasMcqAnswered;
    return false;
  }

  /// Get MCQ options for the current item
  List<MapEntry<String, String>> get currentMcqOptions {
    if (!isCurrentItemMcq || currentItem?.mcqOptions == null) {
      return [];
    }

    final options = currentItem!.mcqOptions!;
    return options.entries
        .map((e) => MapEntry(e.key, e.value.toString()))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // Sort by key (A, B, C, D)
  }

  /// Get the correct MCQ option
  String? get correctMcqOption => currentItem?.mcqCorrectOptionKey;

  /// Whether the selected MCQ option is correct
  bool get isMcqSelectionCorrect => selectedMcqOption == correctMcqOption;

  /// Session duration in seconds
  int get sessionDurationSeconds {
    if (session?.startedAt == null) return 0;
    final start = session!.startedAt;
    final end = session?.completedAt ?? DateTime.now();
    return end.difference(start).inSeconds;
  }

  /// Time spent on current item in seconds
  int get currentItemTimeSeconds {
    if (responseStartTime == null) return 0;
    return DateTime.now().difference(responseStartTime!).inSeconds;
  }
}
