import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/presentation/viewmodel/review_viewmodel.dart';
import 'package:athena/features/review/presentation/viewmodel/review_state.dart';
import 'package:athena/features/review/presentation/widgets/quiz_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen>
    with WidgetsBindingObserver, RouteAware {
  static final RouteObserver<PageRoute> _routeObserver =
      RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewViewModelProvider.notifier).loadQuizzes();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the user comes back to this screen
    // This handles returning from quiz detail, edit, or create screens
    debugPrint('ReviewScreen: didPopNext called - refreshing quizzes');
    if (mounted) {
      ref.read(reviewViewModelProvider.notifier).refreshQuizzes();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh data when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('ReviewScreen: app resumed - refreshing quizzes');
      // Add a small delay to ensure the navigation is complete
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(reviewViewModelProvider.notifier).refreshQuizzes();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.athenaSupportiveGreen,
        title: const Text(
          'Adaptive Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review analytics coming soon!')),
              );
            },
          ),
        ],
      ),
      body:
          reviewState.hasAnyLoading && reviewState.quizzes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh:
                    () =>
                        ref
                            .read(reviewViewModelProvider.notifier)
                            .refreshQuizzes(),
                child: Column(
                  children: [
                    // Review stats
                    Container(
                      color: AppColors.athenaSupportiveGreen,
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 24,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildStatItem(
                              context,
                              value: reviewState.dueItems.toString(),
                              label: 'Due Today',
                              icon: Icons.timer_outlined,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 16),
                            _buildStatItem(
                              context,
                              value: reviewState.totalItems.toString(),
                              label: 'Total Items',
                              icon: Icons.quiz_outlined,
                              color: AppColors.athenaPurple,
                            ),
                            const SizedBox(width: 16),
                            _buildStatItem(
                              context,
                              value: reviewState.formattedAccuracy,
                              label: 'Mastery',
                              icon: Icons.check_circle_outline,
                              color: AppColors.athenaBlue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Section title with sort button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Your Quizzes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected:
                                (value) =>
                                    _handleSortSelection(context, ref, value),
                            itemBuilder:
                                (context) => [
                                  _buildSortMenuItem(
                                    'Last Updated',
                                    'lastUpdated',
                                    reviewState,
                                  ),
                                  _buildSortMenuItem(
                                    'Title',
                                    'title',
                                    reviewState,
                                  ),
                                  _buildSortMenuItem(
                                    'Item Count',
                                    'itemCount',
                                    reviewState,
                                  ),
                                  _buildSortMenuItem(
                                    'Due Count',
                                    'dueCount',
                                    reviewState,
                                  ),
                                  _buildSortMenuItem(
                                    'Mastery',
                                    'accuracy',
                                    reviewState,
                                  ),
                                  _buildSortMenuItem(
                                    'Subject',
                                    'subject',
                                    reviewState,
                                  ),
                                ],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sort,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Sort',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Icon(
                                  reviewState.sortAscending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error handling
                    if (reviewState.hasError)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          color: Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reviewState.error!,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(reviewViewModelProvider.notifier)
                                        .clearError();
                                  },
                                  child: const Text('Dismiss'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Quiz sets
                    Expanded(
                      child:
                          reviewState.showEmptyState
                              ? _buildEmptyState(context)
                              : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: reviewState.sortedQuizzes.length,
                                itemBuilder: (context, index) {
                                  final quiz = reviewState.sortedQuizzes[index];
                                  final itemCount = reviewState
                                      .getQuizItemCount(quiz.id);
                                  final dueCount = reviewState.getQuizDueCount(
                                    quiz.id,
                                  );
                                  final isRecentlyReviewed = reviewState
                                      .isQuizRecentlyReviewed(quiz.id);

                                  return QuizCard(
                                    quiz: quiz,
                                    itemCount: itemCount,
                                    dueCount: dueCount,
                                    accuracy: reviewState
                                        .getQuizFormattedAccuracy(quiz.id),
                                    isRecentlyReviewed: isRecentlyReviewed,
                                    onTap: () async {
                                      debugPrint(
                                        'ReviewScreen: navigating to quiz detail: ${quiz.id}',
                                      );
                                      await context.pushNamed(
                                        AppRouteNames.quizDetail,
                                        pathParameters: {'quizId': quiz.id},
                                      );
                                      // Refresh data when returning from quiz detail
                                      debugPrint(
                                        'ReviewScreen: returned from quiz detail - refreshing quizzes',
                                      );
                                      if (mounted) {
                                        ref
                                            .read(
                                              reviewViewModelProvider.notifier,
                                            )
                                            .refreshQuizzes();
                                      }
                                    },
                                    onReview: () async {
                                      if (dueCount > 0) {
                                        debugPrint(
                                          'ReviewScreen: starting review session for quiz: ${quiz.id}',
                                        );
                                        await context.push(
                                          '/review-session/${quiz.id}?sessionType=mixed&maxItems=20',
                                        );
                                        // Refresh data when returning from review session
                                        debugPrint(
                                          'ReviewScreen: returned from review session - refreshing quizzes',
                                        );
                                        if (mounted) {
                                          ref
                                              .read(
                                                reviewViewModelProvider
                                                    .notifier,
                                              )
                                              .refreshQuizzes();
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.athenaSupportiveGreen,
        foregroundColor: Colors.white,
        heroTag: 'review_fab',
        child: const Icon(Icons.add),
        onPressed: () {
          _showCreateQuizDialog(context);
        },
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quizzes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a quiz to start reviewing',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showCreateQuizDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Quiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.athenaSupportiveGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateQuizDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Quiz',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose how you want to create your quiz:',
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildCreateOption(
                      context: context,
                      icon: Icons.create_rounded,
                      title: 'Manual Entry',
                      description: 'Create questions & answers yourself',
                      color: AppColors.athenaSupportiveGreen,
                      onTap: () async {
                        context.pop();
                        debugPrint(
                          'ReviewScreen: navigating to create quiz (manual)',
                        );
                        await context.pushNamed(
                          AppRouteNames.createQuiz,
                          queryParameters: {'mode': 'manual'},
                        );
                        // Refresh data when returning from create quiz
                        debugPrint(
                          'ReviewScreen: returned from create quiz (manual) - refreshing quizzes',
                        );
                        if (mounted) {
                          ref
                              .read(reviewViewModelProvider.notifier)
                              .refreshQuizzes();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCreateOption(
                      context: context,
                      icon: Icons.auto_awesome,
                      title: 'AI Generated',
                      description: 'Generate from your study materials',
                      color: AppColors.athenaPurple,
                      onTap: () async {
                        context.pop();
                        debugPrint(
                          'ReviewScreen: navigating to create quiz (AI)',
                        );
                        await context.pushNamed(
                          AppRouteNames.createQuiz,
                          queryParameters: {'mode': 'ai'},
                        );
                        // Refresh data when returning from create quiz
                        debugPrint(
                          'ReviewScreen: returned from create quiz (AI) - refreshing quizzes',
                        );
                        if (mounted) {
                          ref
                              .read(reviewViewModelProvider.notifier)
                              .refreshQuizzes();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Handle sort selection
  void _handleSortSelection(BuildContext context, WidgetRef ref, String value) {
    final viewmodel = ref.read(reviewViewModelProvider.notifier);

    switch (value) {
      case 'lastUpdated':
        viewmodel.setSortCriteria(QuizSortCriteria.lastUpdated);
        break;
      case 'title':
        viewmodel.setSortCriteria(QuizSortCriteria.title);
        break;
      case 'itemCount':
        viewmodel.setSortCriteria(QuizSortCriteria.itemCount);
        break;
      case 'dueCount':
        viewmodel.setSortCriteria(QuizSortCriteria.dueCount);
        break;
      case 'accuracy':
        viewmodel.setSortCriteria(QuizSortCriteria.accuracy);
        break;
      case 'subject':
        viewmodel.setSortCriteria(QuizSortCriteria.subject);
        break;
    }
  }

  // Build sort menu item
  PopupMenuItem<String> _buildSortMenuItem(
    String title,
    String value,
    ReviewState state,
  ) {
    final isSelected = _getSortCriteriaValue(state.sortCriteria) == value;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.athenaSupportiveGreen : null,
              ),
            ),
          ),
          if (isSelected) ...[
            Icon(
              state.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: AppColors.athenaSupportiveGreen,
            ),
          ],
        ],
      ),
    );
  }

  // Get string value for sort criteria
  String _getSortCriteriaValue(QuizSortCriteria criteria) {
    switch (criteria) {
      case QuizSortCriteria.lastUpdated:
        return 'lastUpdated';
      case QuizSortCriteria.title:
        return 'title';
      case QuizSortCriteria.itemCount:
        return 'itemCount';
      case QuizSortCriteria.dueCount:
        return 'dueCount';
      case QuizSortCriteria.accuracy:
        return 'accuracy';
      case QuizSortCriteria.subject:
        return 'subject';
    }
  }
}
