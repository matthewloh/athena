import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends ConsumerWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String currentRouteName =
        GoRouter.of(
              context,
            ).routeInformationProvider.value.uri.pathSegments.isNotEmpty
            ? GoRouter.of(
              context,
            ).routeInformationProvider.value.uri.pathSegments.last
            : AppRouteNames.home;

    int selectedIndex = 0;
    if (currentRouteName == AppRouteNames.chat) {
      selectedIndex = 1;
    } else if (currentRouteName == AppRouteNames.materials) {
      selectedIndex = 2;
    } else if (currentRouteName == AppRouteNames.review) {
      selectedIndex = 3;
    } else if (currentRouteName == AppRouteNames.planner) {
      selectedIndex = 4;
    } else if (currentRouteName == AppRouteNames.home) {
      selectedIndex = 0;
    }

    return Scaffold(
      body: child,
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
            switch (index) {
              case 0:
                context.goNamed(AppRouteNames.home);
                break;
              case 1:
                context.goNamed(AppRouteNames.chat);
                break;
              case 2:
                context.goNamed(AppRouteNames.materials);
                break;
              case 3:
                context.goNamed(AppRouteNames.review);
                break;
              case 4:
                context.goNamed(AppRouteNames.planner);
                break;
            }
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
