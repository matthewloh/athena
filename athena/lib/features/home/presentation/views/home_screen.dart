import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:athena/features/home/presentation/viewmodel/home_viewmodel.dart';
import 'package:athena/features/shared/utils/subject_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    
    // Get display name from the viewmodel
    final userName = homeViewModel.getDisplayName();

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.athenaBlue,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Athena',
              style: TextStyle(
                fontFamily: 'Overused Grotesk',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.athenaPurple.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.go('/${AppRouteNames.profile}');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all data through the viewmodel
            await homeViewModel.refreshAllData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header section
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.athenaBlue,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $userName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'What would you like to learn today?',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Dashboard stats overview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildStatCard(
                        context,
                        icon: Icons.article_rounded,
                        title: 'Study Materials',
                        value: homeState.formattedMaterialCount,
                        color: AppColors.athenaPurple,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        context,
                        icon: Icons.quiz_rounded,
                        title: 'Quizzes',
                        value: homeState.formattedQuizItemCount,
                        color: AppColors.athenaSupportiveGreen,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main features grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Study Companion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.9, // Make cards taller to prevent text overflow
                        children: [
                          _buildFeatureCard(
                            context,
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'AI Chatbot',
                            description: 'Get instant academic support',
                            color: AppColors.athenaBlue.withValues(alpha: 0.9),
                            onTap: () {
                              // Navigate to chatbot using GoRouter
                              context.goNamed(AppRouteNames.chat);
                            },
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.library_books_rounded,
                            title: 'Study Material',
                            description: 'Manage your notes and summaries',
                            color: AppColors.athenaPurple.withValues(
                              alpha: 0.9,
                            ),
                            onTap: () {
                              // Navigate to study materials using GoRouter
                              context.goNamed(AppRouteNames.materials);
                            },
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.quiz_outlined,
                            title: 'Adaptive Review',
                            description: 'Test your knowledge effectively',
                            color: AppColors.athenaSupportiveGreen.withValues(
                              alpha: 0.9,
                            ),
                            onTap: () {
                              // Navigate to review system using GoRouter
                              context.goNamed(AppRouteNames.review);
                            },
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.calendar_today_rounded,
                            title: 'Study Planner',
                            description: 'Schedule your study sessions',
                            color: Colors.orange.withValues(alpha: 0.9),
                            onTap: () {
                              // Navigate to planner using GoRouter
                              context.goNamed(AppRouteNames.planner);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Today's focus section (TODO: Hook up to real planner data when available)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Focus',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.task_alt_rounded,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Upcoming Sessions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${homeState.formattedTodaySessionsCount} today',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // TODO: Replace with real upcoming sessions from planner when available
                            // Display actual upcoming sessions from state
                            ...homeState.upcomingSessions.map((session) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSessionItem(
                                  time: session.time,
                                  title: session.title,
                                  icon: _getIconForSession(session.iconType),
                                ),
                              ),
                            ),
                            // If no sessions, show placeholder (currently always shown since planner is WIP)
                            if (homeState.upcomingSessions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.schedule_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No sessions scheduled',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Use the planner to schedule your study sessions',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to planner
                                context.goNamed(AppRouteNames.planner);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                minimumSize: const Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                homeState.upcomingSessions.isEmpty 
                                  ? 'Open Study Planner' 
                                  : 'View Full Schedule',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Review Items Due section with modern compact design
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.loop_rounded,
                            color: AppColors.athenaSupportiveGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Review Items Due',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.athenaSupportiveGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${homeState.formattedDueItemsCount} items',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.athenaSupportiveGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Review items display or empty state
                      if (homeState.reviewItems.isNotEmpty)
                        // Compact grid for review items
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: homeState.reviewItems.take(4).map((item) => 
                            Container(
                              width: (MediaQuery.of(context).size.width - 64) / 2, // 2 columns with spacing
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getColorForReviewItem(item, isBackground: true),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getColorForReviewItem(item, isBackground: false).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getColorForReviewItem(item, isBackground: false),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _getColorForReviewItem(item, isBackground: false),
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${item.count} items due',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getColorForReviewItem(item, isBackground: false).withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        )
                      else
                        // Empty state
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'All caught up!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No items due for review at the moment',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to review screen
                            context.goNamed(AppRouteNames.review);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.athenaSupportiveGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: Text(
                            homeState.reviewItems.isNotEmpty 
                              ? 'Start Review Session' 
                              : 'Browse All Quizzes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a cool bottom sheet to demonstrate edge function with Riverpod
          _showEdgeFunctionDemo(context, ref);
        },
        tooltip: 'Call Edge Function',
        heroTag: 'home_fab',
        child: const Icon(Icons.api),
      ),
    );
  }

  void _showEdgeFunctionDemo(BuildContext context, WidgetRef ref) {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final homeState = ref.read(homeViewModelProvider);
    final textController = TextEditingController(text: homeState.edgeFunctionName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.athenaBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cloudy_snowing,
                            color: AppColors.athenaBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Supabase Edge Function',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            final name = textController.text.trim();
                            if (name.isNotEmpty) {
                              homeViewModel.updateEdgeFunctionName(name);
                              homeViewModel.callEdgeFunction();
                            }
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          homeViewModel.updateEdgeFunctionName(value);
                          homeViewModel.callEdgeFunction();
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Response:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Consumer(
                            builder: (context, ref, child) {
                              final currentState = ref.watch(homeViewModelProvider);

                              if (currentState.isCallingEdgeFunction) {
                                return _buildLoadingState();
                              } else if (currentState.hasEdgeFunctionError) {
                                return _buildErrorState(currentState.edgeFunctionError!);
                              } else if (currentState.hasEdgeFunctionResponse) {
                                return _buildSuccessState({
                                  'message': currentState.edgeFunctionMessage ?? 'Success!'
                                });
                              } else {
                                return const Text('No response yet');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Async State Management:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Riverpod provides typesafe async state handling\n'
                      '• .when() handles all states: data, loading, error\n'
                      '• Edge functions run in isolated environments\n'
                      '• StateProvider tracks user input across rebuilds',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSuccessState(Map<String, dynamic> data) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.athenaBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.athenaBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                data['message'] ?? 'No message received',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16),
          Text('Calling edge function...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Error: ${error.toString()}',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(50),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withAlpha(230),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem({
    required String time,
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.athenaBlue.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.athenaBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to get icon for session type
  IconData _getIconForSession(SessionIconType iconType) {
    switch (iconType) {
      case SessionIconType.science:
        return Icons.science_rounded;
      case SessionIconType.math:
        return Icons.calculate_rounded;
      case SessionIconType.literature:
        return Icons.book_rounded;
      case SessionIconType.history:
        return Icons.history_edu_rounded;
      case SessionIconType.language:
        return Icons.language_rounded;
      case SessionIconType.generic:
        return Icons.school_rounded;
    }
  }

  // Helper method to get colors for review items using SubjectUtils
  Color _getColorForReviewItem(ReviewItem item, {required bool isBackground}) {
    final (Color color, IconData _) = SubjectUtils.getSubjectAttributes(item.subject);
    
    // If subject is null, SubjectUtils returns grey which is hard to see
    // Use a more pronounced grey for better visibility
    final Color finalColor = item.subject == null 
        ? const Color(0xFF616161) // Darker grey for better contrast
        : color;
    
    if (isBackground) {
      // Create a light background version of the subject color
      return finalColor.withValues(alpha: 0.1);
    } else {
      // Use the direct subject color for text and borders
      return finalColor;
    }
  }
}
