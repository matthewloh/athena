import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:athena/features/home/presentation/views/home_screen.dart';
import 'package:athena/features/planner/presentation/views/planner_screen.dart';
import 'package:athena/features/review/presentation/views/review_screen.dart';
import 'package:athena/features/study_materials/presentation/views/materials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    // List of screens for bottom navigation
    final screens = [
      const HomeScreen(),
      const ChatbotScreen(),
      const MaterialsScreen(),
      const ReviewScreen(),
      const PlannerScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _getColorForIndex(selectedIndex),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_rounded),
              label: 'Materials',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              label: 'Review',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Planner',
            ),
          ],
          onTap: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return AppColors.athenaBlue;
      case 1:
        return AppColors.athenaBlue;
      case 2:
        return AppColors.athenaPurple;
      case 3:
        return AppColors.athenaSupportiveGreen;
      case 4:
        return Colors.orange;
      default:
        return AppColors.athenaBlue;
    }
  }
}
