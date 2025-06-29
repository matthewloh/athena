import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/quiz_results_viewmodel.dart';
import 'package:athena/features/review/presentation/viewmodel/review_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  /// The completed review session data
  final ReviewSessionEntity session;

  const QuizResultsScreen({super.key, required this.session});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the viewmodel with session data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(quizResultsViewModelProvider.notifier)
          .initializeResults(widget.session);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizResultsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.athenaSupportiveGreen,
        foregroundColor: Colors.white,
        title: const Text('Session Complete'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Navigate back to review home and refresh the data
            context.go('/review');
            // Trigger refresh of review screen data
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                ref.read(reviewViewModelProvider.notifier).refreshQuizzes();
              }
            });
          },
        ),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.hasError) {
      return _buildErrorState(context, state.error!);
    }

    if (!state.hasSession) {
      return _buildNoSessionState(context);
    }

    return _buildResultsContent(context, state);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.athenaSupportiveGreen),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Results',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.athenaDarkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.athenaMediumGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaSupportiveGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSessionState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: AppColors.athenaMediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Session Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.athenaDarkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load session results.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.athenaMediumGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaSupportiveGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(BuildContext context, state) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Celebration header
              _buildCelebrationHeader(context),
              const SizedBox(height: 32),

              // Statistics card
              _buildStatsCard(context, state),
              const SizedBox(height: 32),

              // Performance insights (if available)
              if (state.averageDifficulty > 0) ...[
                _buildPerformanceInsights(context, state),
                const SizedBox(height: 32),
              ],

              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader(BuildContext context) {
    return Column(
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
        const SizedBox(height: 24),
        Text(
          'Session Complete!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.athenaDarkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Great job! Here\'s how you performed.',
          style: TextStyle(fontSize: 16, color: AppColors.athenaMediumGrey),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, state) {
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
          // Main statistics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Items Reviewed',
                '${state.itemsReviewed}',
                Icons.quiz_outlined,
                AppColors.athenaBlue,
              ),
              _buildStatItem(
                'Correct',
                state.formattedAccuracy,
                Icons.track_changes,
                AppColors.athenaSupportiveGreen,
              ),
              _buildStatItem(
                'Duration',
                state.formattedDuration,
                Icons.timer_outlined,
                AppColors.athenaPurple,
              ),
            ],
          ),

          // Additional stats if available
          if (state.averageDifficulty > 0) ...[
            const SizedBox(height: 20),
            Divider(color: AppColors.athenaLightGrey),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Confidence: ${state.formattedAverageConfidence}/4.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.athenaMediumGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'How well you knew the answers',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.athenaMediumGrey.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
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

  Widget _buildPerformanceInsights(BuildContext context, state) {
    final accuracy = state.accuracyPercentage;

    String insightTitle;
    String insightDescription;
    IconData insightIcon;
    Color insightColor;

    if (accuracy >= 80) {
      insightTitle = 'Excellent Performance!';
      insightDescription =
          'You\'re mastering this material well. Keep up the great work!';
      insightIcon = Icons.star;
      insightColor = Colors.amber;
    } else if (accuracy >= 60) {
      insightTitle = 'Good Progress!';
      insightDescription =
          'You\'re on the right track. Review challenging items to improve.';
      insightIcon = Icons.trending_up;
      insightColor = AppColors.athenaSupportiveGreen;
    } else {
      insightTitle = 'Keep Practicing!';
      insightDescription =
          'Focus on reviewing these items more frequently to strengthen your knowledge.';
      insightIcon = Icons.fitness_center;
      insightColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: insightColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: insightColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(insightIcon, color: insightColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insightTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.athenaDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insightDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.athenaMediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary action - View Quiz Details
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to quiz detail screen with refresh parameter to ensure data refresh
              final quizId = widget.session.quizId;
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              context.go('/quiz-detail/$quizId?refresh=$timestamp');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.athenaSupportiveGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Quiz Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary action - Go to Review Home
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Navigate back to review home and refresh the data
              context.go('/review');
              // Trigger refresh of review screen data
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  ref.read(reviewViewModelProvider.notifier).refreshQuizzes();
                }
              });
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.athenaSupportiveGreen),
              foregroundColor: AppColors.athenaSupportiveGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Review Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
