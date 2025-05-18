import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/home/presentation/providers/home_providers.dart';
import 'package:athena/features/navigation/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appAuthProvider).value;
    final userName =
        user?.userMetadata?['username'] ??
        user?.email?.split('@').first ??
        'Scholar';

    // // Watch the dashboard data providers
    // final dashboardDataAsync = ref.watch(dashboardDataProvider);
    // final materialCountAsync = ref.watch(materialCountProvider);
    // final quizItemCountAsync = ref.watch(quizItemCountProvider);
    // final upcomingSessionsAsync = ref.watch(upcomingSessionsProvider);
    // final reviewItemsAsync = ref.watch(reviewItemsProvider);

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
            // Refresh all providers
            ref.invalidate(dashboardDataProvider);
            ref.invalidate(materialCountProvider);
            ref.invalidate(quizItemCountProvider);
            ref.invalidate(upcomingSessionsProvider);
            ref.invalidate(reviewItemsProvider);
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
                        value: '3',
                        color: AppColors.athenaPurple,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        context,
                        icon: Icons.quiz_rounded,
                        title: 'Quiz Items',
                        value: '12',
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
                        children: [
                          _buildFeatureCard(
                            context,
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'AI Chatbot',
                            description: 'Get instant academic support',
                            color: AppColors.athenaBlue.withValues(alpha: 0.9),
                            onTap: () {
                              // Navigate to chatbot using navigation provider instead of GoRouter
                              ref.read(navigationIndexProvider.notifier).state = 1;
                            },
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.note_alt_outlined,
                            title: 'Study Material',
                            description: 'Manage your notes and summaries',
                            color: AppColors.athenaPurple.withValues(
                              alpha: 0.9,
                            ),
                            onTap: () {
                              // Navigate to study materials using navigation provider
                              ref.read(navigationIndexProvider.notifier).state = 2;
                            },
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.timer_outlined,
                            title: 'Adaptive Review',
                            description: 'Test your knowledge effectively',
                            color: AppColors.athenaSupportiveGreen.withValues(
                              alpha: 0.9,
                            ),
                            onTap: () {
                              // Navigate to review system using navigation provider
                              ref.read(navigationIndexProvider.notifier).state = 3;
                            },
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.calendar_today_rounded,
                            title: 'Study Planner',
                            description: 'Schedule your study sessions',
                            color: Colors.orange.withValues(alpha: 0.9),
                            onTap: () {
                              // Navigate to planner using navigation provider
                              ref.read(navigationIndexProvider.notifier).state = 4;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Today's focus section
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
                                  color: AppColors.athenaBlue,
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
                                  '2 today',
                                  style: TextStyle(
                                    color: AppColors.athenaBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSessionItem(
                              time: '14:00 - 15:30',
                              title: 'Review Biology Notes',
                              icon: Icons.science_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildSessionItem(
                              time: '17:00 - 18:00',
                              title: 'Math Practice Quiz',
                              icon: Icons.calculate_rounded,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to planner
                                ref.read(navigationIndexProvider.notifier).state = 4;
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('View Full Schedule'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Review Items Due section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review Items Due',
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
                                Icon(
                                  Icons.loop_rounded,
                                  color: AppColors.athenaSupportiveGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '5 items due for review',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.athenaSupportiveGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuizDueCard(
                                    'Biology Terms',
                                    '3 items',
                                    Colors.green[100]!,
                                    Colors.green[700]!,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuizDueCard(
                                    'History Dates',
                                    '2 items',
                                    Colors.amber[100]!,
                                    Colors.amber[700]!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                // Navigate to review
                                ref.read(navigationIndexProvider.notifier).state = 3;
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: AppColors.athenaSupportiveGreen,
                                ),
                                foregroundColor:
                                    AppColors.athenaSupportiveGreen,
                              ),
                              child: const Text('Start Review Session'),
                            ),
                          ],
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

  Widget _buildQuizDueCard(
    String title,
    String count,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
