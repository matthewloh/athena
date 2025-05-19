import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        title: const Text(
          'Athena',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.athenaPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Welcome section
            Text(
              'Welcome to Athena',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.athenaPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI-powered study companion',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // Main features
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Feature cards grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFeatureCard(
                  context,
                  title: 'AI Chatbot',
                  description: 'Get answers to your study questions',
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.athenaBlue,
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                ),
                _buildFeatureCard(
                  context,
                  title: 'Study Materials',
                  description: 'Manage your study resources',
                  icon: Icons.book_outlined,
                  color: AppColors.athenaPurple,
                  onTap: () => Navigator.pushNamed(context, '/materials'),
                ),
                _buildFeatureCard(
                  context,
                  title: 'Adaptive Review',
                  description: 'Quizzes and flashcards',
                  icon: Icons.quiz_outlined,
                  color: AppColors.athenaSupportiveGreen,
                  onTap: () => Navigator.pushNamed(context, '/review'),
                ),
                _buildFeatureCard(
                  context,
                  title: 'Study Planner',
                  description: 'Schedule your study sessions',
                  icon: Icons.calendar_today,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/planner'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick actions section
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildQuickActionCard(
              context,
              title: 'Ask AI Assistant',
              icon: Icons.auto_awesome,
              onTap: () => Navigator.pushNamed(context, '/chat'),
            ),

            const SizedBox(height: 12),

            _buildQuickActionCard(
              context,
              title: 'Add Study Material',
              icon: Icons.add_circle_outline,
              onTap: () => Navigator.pushNamed(context, '/materials'),
            ),

            const SizedBox(height: 12),

            _buildQuickActionCard(
              context,
              title: 'Start Quick Review',
              icon: Icons.play_circle_outline,
              onTap: () => Navigator.pushNamed(context, '/review'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.athenaPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.athenaPurple, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
