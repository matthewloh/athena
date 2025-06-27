import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/review_session_viewmodel.dart';
import 'package:athena/features/review/presentation/widgets/flashcard_widget.dart';
import 'package:athena/features/review/presentation/widgets/multiple_choice_widget.dart';
import 'package:athena/features/review/presentation/widgets/session_progress_widget.dart';
import 'package:athena/features/review/presentation/widgets/difficulty_rating_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for conducting review sessions with spaced repetition.
///
/// This screen manages the review session flow including:
/// - Displaying flashcards and multiple choice questions
/// - Collecting user responses and difficulty ratings
/// - Applying spaced repetition algorithm
/// - Tracking session progress and completion
class ReviewSessionScreen extends ConsumerStatefulWidget {
  /// ID of the quiz to review
  final String quizId;

  /// Type of session (optional, defaults to mixed)
  final SessionType? sessionType;

  /// Maximum number of items (optional)
  final int? maxItems;

  const ReviewSessionScreen({
    super.key,
    required this.quizId,
    this.sessionType,
    this.maxItems,
  });

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  @override
  void initState() {
    super.initState();
    // Start the review session when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startReviewSession();
    });
  }

  void _startReviewSession() {
    ref
        .read(reviewSessionViewModelProvider.notifier)
        .startReviewSession(
          quizId: widget.quizId,
          sessionType: widget.sessionType ?? SessionType.mixed,
          maxItems: widget.maxItems,
        );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(reviewSessionViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: _buildAppBar(context, sessionState),
      body: _buildBody(context, sessionState),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, state) {
    return AppBar(
      backgroundColor: AppColors.athenaSupportiveGreen,
      foregroundColor: Colors.white,
      title: const Text(
        'Review Session',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18, // Slightly smaller to prevent overflow
        ),
      ),
      elevation: 0,
      centerTitle: true, // Center the title to balance the layout
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _handleBackPress(context),
      ),
      // Remove the bottom progress bar from app bar to prevent overflow
      // We'll add it to the body instead
    );
  }

  Widget _buildBody(BuildContext context, state) {
    if (state.isLoadingSession) {
      return _buildLoadingState();
    }

    if (state.error != null) {
      return _buildErrorState(context, state.error!);
    }

    if (state.isSessionCompleted) {
      return _buildCompletionState(context, state);
    }

    if (state.isSessionAbandoned) {
      return _buildAbandonedState(context);
    }

    if (!state.hasItems) {
      return _buildNoItemsState(context);
    }

    return _buildReviewState(context, state);
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.athenaSupportiveGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Preparing your review session...',
              style: TextStyle(fontSize: 16, color: AppColors.athenaMediumGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.athenaDarkGrey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.athenaMediumGrey,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                  ElevatedButton(
                    onPressed: _startReviewSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.athenaSupportiveGreen,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoItemsState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.athenaSupportiveGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'All caught up!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.athenaDarkGrey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No items are due for review right now.\nGreat job staying on top of your studies!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.athenaMediumGrey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.athenaSupportiveGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Back to Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionState(BuildContext context, state) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.athenaSupportiveGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  size: 64,
                  color: AppColors.athenaSupportiveGreen,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Session Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.athenaDarkGrey,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatsCard(state),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.athenaSupportiveGreen,
                        ),
                        foregroundColor: AppColors.athenaSupportiveGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back to Review'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startReviewSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.athenaSupportiveGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Review Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Items Reviewed',
                '${state.completedItems}',
                Icons.quiz_outlined,
                AppColors.athenaBlue,
              ),
              _buildStatItem(
                'Accuracy',
                '${state.accuracyPercentage.toStringAsFixed(0)}%',
                Icons.track_changes,
                AppColors.athenaSupportiveGreen,
              ),
              _buildStatItem(
                'Duration',
                _formatDuration(state.sessionDurationSeconds),
                Icons.timer_outlined,
                AppColors.athenaPurple,
              ),
            ],
          ),
          if (state.averageDifficulty > 0) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology,
                  color: AppColors.athenaMediumGrey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Average Difficulty: ${state.averageDifficulty.toStringAsFixed(1)}/4.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.athenaMediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.athenaDarkGrey,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.athenaMediumGrey),
        ),
      ],
    );
  }

  Widget _buildAbandonedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 80,
              color: AppColors.athenaMediumGrey,
            ),
            const SizedBox(height: 24),
            Text(
              'Session Paused',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.athenaDarkGrey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your progress has been saved.\nYou can continue later or start a new session.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.athenaMediumGrey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaSupportiveGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Back to Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewState(BuildContext context, state) {
    if (state.currentItem == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      bottom:
          true, // Ensure content doesn't get obstructed by bottom navigation
      child: Column(
        children: [
          // Progress bar at top of body content
          if (state.hasItems)
            Container(
              color: AppColors.athenaSupportiveGreen,
              child: SessionProgressWidget(
                currentIndex: state.currentItemIndex,
                totalItems: state.items.length,
                completedItems: state.completedItems,
              ),
            ),

          // Content area - maximized for better flashcard visibility
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                8,
              ), // Reduced bottom padding
              child: Column(
                children: [
                  // Item counter and navigation
                  _buildItemHeader(state),
                  const SizedBox(height: 20), // Reduced spacing
                  // Quiz item content - takes up maximum available space
                  Expanded(child: _buildQuizItemContent(state)),

                  // Action buttons for flashcards (show answer)
                  if (!state.isSubmittingResponse) ...[
                    const SizedBox(height: 16), // Reduced spacing
                    _buildActionButtons(context, state),
                  ],
                ],
              ),
            ),
          ),

          // Compact difficulty rating (shows after showing answer/selecting option)
          if (_shouldShowDifficultyRating(state))
            DifficultyRatingWidget(
              onRatingSelected: (rating) => _submitResponse(rating),
              isLoading: state.isSubmittingResponse,
            ),
        ],
      ),
    );
  }

  Widget _buildItemHeader(state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Item ${state.currentItemIndex + 1} of ${state.items.length}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.athenaMediumGrey,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.athenaSupportiveGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            state.isCurrentItemFlashcard ? 'Flashcard' : 'Multiple Choice',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.athenaSupportiveGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizItemContent(state) {
    if (state.isCurrentItemFlashcard) {
      return FlashcardWidget(
        question: state.currentItem!.questionText,
        answer: state.currentItem!.answerText,
        isShowingAnswer: state.isShowingAnswer,
        onFlip:
            () =>
                ref.read(reviewSessionViewModelProvider.notifier).showAnswer(),
      );
    } else {
      return MultipleChoiceWidget(
        question: state.currentItem!.questionText,
        options: state.currentMcqOptions,
        selectedOption: state.selectedMcqOption,
        correctOption: state.correctMcqOption,
        showCorrectAnswer: state.hasMcqAnswered,
        onOptionSelected:
            (option) => ref
                .read(reviewSessionViewModelProvider.notifier)
                .selectMcqOption(option),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, state) {
    if (state.isCurrentItemFlashcard && !state.isShowingAnswer) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              () =>
                  ref
                      .read(reviewSessionViewModelProvider.notifier)
                      .showAnswer(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaSupportiveGreen,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ), // Slightly reduced padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Show Answer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  bool _shouldShowDifficultyRating(state) {
    if (state.isCurrentItemFlashcard) {
      return state.isShowingAnswer;
    } else {
      return state.hasMcqAnswered;
    }
  }

  void _submitResponse(DifficultyRating rating) {
    ref.read(reviewSessionViewModelProvider.notifier).submitResponse(rating);
  }

  void _handleBackPress(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End Review Session?'),
            content: const Text(
              'Your progress will be saved, but the current session will end. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue Session'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(reviewSessionViewModelProvider.notifier)
                      .abandonSession();
                  context.pop();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('End Session'),
              ),
            ],
          ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}
