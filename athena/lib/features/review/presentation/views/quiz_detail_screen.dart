import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/quiz_detail_viewmodel.dart';
import 'package:athena/features/shared/utils/subject_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizDetailScreen extends ConsumerWidget {
  final String quizId;

  const QuizDetailScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quizDetailViewModelProvider(quizId));
    final viewModel = ref.read(quizDetailViewModelProvider(quizId).notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          state.quiz?.title ?? 'Quiz Details',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (state.hasQuiz) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black87),
              onPressed: () {
                // TODO: Navigate to edit quiz screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit quiz - Coming soon')),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteConfirmation(context);
                    break;
                  case 'export':
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export quiz - Coming soon'),
                      ),
                    );
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 8),
                          Text('Export'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.refreshQuizData(quizId),
        child: _buildBody(context, state, viewModel),
      ),
      floatingActionButton:
          state.isReadyForReview
              ? FloatingActionButton.extended(
                backgroundColor: AppColors.athenaSupportiveGreen,
                onPressed: () {
                  // TODO: Navigate to review session
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Start review - Coming soon')),
                  );
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'Start Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildBody(BuildContext context, state, viewModel) {
    if (state.hasError) {
      return _buildErrorState(context, state.error!, viewModel);
    }

    if (state.hasAnyLoading && !state.hasQuiz) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.athenaSupportiveGreen,
        ),
      );
    }

    if (!state.hasQuiz) {
      return const Center(
        child: Text(
          'Quiz not found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildQuizHeader(context, state),
          _buildStatsCards(context, state),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(context, state),
                _buildItemsTab(context, state),
                _buildHistoryTab(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.refreshQuizData(quizId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaSupportiveGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHeader(BuildContext context, state) {
    final quiz = state.quiz!;
    final (subjectColor, subjectIcon) = SubjectUtils.getSubjectAttributes(
      quiz.subject,
    );
    final subjectDisplayName = SubjectUtils.getDisplayName(quiz.subject);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subjectIcon, color: subjectColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subjectDisplayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: subjectColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (quiz.description != null) ...[
            const SizedBox(height: 16),
            Text(
              quiz.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Created ${_formatTimestamp(quiz.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              if (quiz.studyMaterialId != null) ...[
                Icon(Icons.library_books, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Linked to material',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Items',
              state.totalItems.toString(),
              Icons.quiz,
              AppColors.athenaSupportiveGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Due',
              state.dueItems.toString(),
              Icons.schedule,
              state.hasDueItems ? Colors.orange : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Accuracy',
              state.formattedAccuracy,
              Icons.trending_up,
              AppColors.athenaSupportiveGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Mastered',
              state.masteredItems.toString(),
              Icons.star,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TabBar(
        indicatorColor: AppColors.athenaSupportiveGreen,
        labelColor: AppColors.athenaSupportiveGreen,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Items'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, state) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSection(context, state),
          const SizedBox(height: 24),
          _buildQuickActions(context, state),
          const SizedBox(height: 24),
          _buildNextReviewSection(context, state),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar(
            'Completion',
            state.completionPercentage,
            AppColors.athenaSupportiveGreen,
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            'Review Progress',
            state.reviewProgress,
            AppColors.athenaBlue,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressStat(
                  'Total Reviews',
                  state.totalReviews.toString(),
                  Icons.refresh,
                ),
              ),
              Expanded(
                child: _buildProgressStat(
                  'Current Streak',
                  '${state.streak} days',
                  Icons.local_fire_department,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Start Review',
                  Icons.play_arrow,
                  AppColors.athenaSupportiveGreen,
                  state.isReadyForReview,
                  () {
                    // TODO: Navigate to review session
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Start review - Coming soon'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Add Items',
                  Icons.add,
                  AppColors.athenaSupportiveGreen,
                  true,
                  () {
                    // TODO: Navigate to add items screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add items - Coming soon')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey[300],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildNextReviewSection(BuildContext context, state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Next Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                state.hasDueItems ? Icons.schedule : Icons.check_circle,
                color: state.hasDueItems ? Colors.orange : Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.hasDueItems
                          ? '${state.dueItems} items ready for review'
                          : 'All caught up!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    if (state.nextReviewDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Next review: ${_formatDate(state.nextReviewDate!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ] else if (!state.hasDueItems && state.hasItems) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'No upcoming reviews scheduled',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTab(BuildContext context, state) {
    if (state.isLoadingItems) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.athenaSupportiveGreen,
        ),
      );
    }

    if (!state.hasItems) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Items Yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add some flashcards or questions to get started with this quiz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to add items screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add items - Coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.athenaSupportiveGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add Items'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: state.quizItems.length,
      itemBuilder: (context, index) {
        final item = state.quizItems[index];
        return _buildQuizItemCard(context, item);
      },
    );
  }

  Widget _buildQuizItemCard(BuildContext context, item) {
    final isFlashcard = item.itemType == QuizItemType.flashcard;
    final isDue = item.nextReviewDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isFlashcard
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isFlashcard ? 'Flashcard' : 'MCQ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isFlashcard ? Colors.blue : Colors.purple,
                    ),
                  ),
                ),
                const Spacer(),
                if (isDue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Due',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.questionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isFlashcard) ...[
              const SizedBox(height: 8),
              Text(
                item.answerText,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildItemStat(Icons.repeat, '${item.repetitions}', 'Reviews'),
                const SizedBox(width: 16),
                _buildItemStat(
                  Icons.trending_up,
                  item.easinessFactor.toStringAsFixed(1),
                  'Factor',
                ),
                const SizedBox(width: 16),
                _buildItemStat(
                  Icons.schedule,
                  _formatDate(item.nextReviewDate),
                  'Next',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context, state) {
    // TODO: Implement when review session data is available
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Review History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review session history will be available once you start reviewing this quiz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TODO: Review session tracking and analytics will be implemented here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Quiz'),
            content: const Text(
              'Are you sure you want to delete this quiz? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.pop();
                  // TODO: Implement delete functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delete quiz - Coming soon')),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = dateOnly.difference(today).inDays;

    // Handle future dates (positive difference)
    if (difference > 0) {
      if (difference == 1) {
        return 'Tomorrow';
      } else if (difference < 7) {
        return 'In $difference days';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
    // Handle today (zero difference)
    else if (difference == 0) {
      return 'Today';
    }
    // Handle past dates (negative difference)
    else {
      final pastDays = -difference;
      if (pastDays == 1) {
        return 'Yesterday';
      } else if (pastDays < 7) {
        return '${pastDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // Handle very recent timestamps
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
