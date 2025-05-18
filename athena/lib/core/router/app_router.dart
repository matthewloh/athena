import 'package:athena/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:athena/features/auth/presentation/views/landing_screen.dart';
import 'package:athena/features/auth/presentation/views/login_screen.dart';
import 'package:athena/features/auth/presentation/views/profile_screen.dart';
import 'package:athena/features/auth/presentation/views/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Required for WidgetRef in builder and ProviderScope access
import 'package:go_router/go_router.dart';
import 'package:athena/core/constants/app_route_names.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _shellNavigatorKey = GlobalKey<NavigatorState>(); // Example for ShellRoute if needed later

// It's good practice to make the router a provider itself so it can access other providers.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch the AuthState. When it changes, GoRouter is rebuilt.
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/${AppRouteNames.landing}',
    debugLogDiagnostics: true,
    // No refreshListenable needed; GoRouter rebuilds on authState change.
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.isAuthenticated;

      final loggingIn = state.matchedLocation == '/${AppRouteNames.login}';
      final signingUp = state.matchedLocation == '/${AppRouteNames.signup}';
      final onLanding = state.matchedLocation == '/${AppRouteNames.landing}';

      if (isAuthenticated && (loggingIn || signingUp || onLanding)) {
        return '/${AppRouteNames.home}';
      }

      if (!isAuthenticated && !loggingIn && !signingUp && !onLanding) {
        return '/${AppRouteNames.login}';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/${AppRouteNames.landing}',
        name: AppRouteNames.landing,
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/${AppRouteNames.login}',
        name: AppRouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/${AppRouteNames.signup}',
        name: AppRouteNames.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/${AppRouteNames.home}',
        name: AppRouteNames.home,
        builder:
            (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Athena Home'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      context.go('/${AppRouteNames.profile}');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      ref.read(authViewModelProvider.notifier).logout();
                    },
                  ),
                ],
              ),
              body: const Center(child: Text('Home Screen - Protected')),
            ),
      ),
      GoRoute(
        path: '/${AppRouteNames.profile}',
        name: AppRouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
