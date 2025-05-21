import 'dart:async';

import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/auth/presentation/views/auth_callback_screen.dart';
import 'package:athena/features/auth/presentation/views/landing_screen.dart';
import 'package:athena/features/auth/presentation/views/login_screen.dart';
import 'package:athena/features/auth/presentation/views/profile_screen.dart';
import 'package:athena/features/auth/presentation/views/signup_screen.dart';
import 'package:athena/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:athena/features/home/presentation/views/home_screen.dart';
import 'package:athena/features/navigation/main_navigation_screen.dart';
import 'package:athena/features/planner/presentation/views/planner_screen.dart';
import 'package:athena/features/review/presentation/views/review_screen.dart';
import 'package:athena/features/study_materials/presentation/views/materials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// It's good practice to make the router a provider itself so it can access other providers.
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch the AppAuth provider. It provides AsyncValue<User?>
  final authState = ref.watch(appAuthProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/${AppRouteNames.landing}',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      // Use a safer way to get the auth stream
      Supabase.instance.client.auth.onAuthStateChange.map(
        (data) => data.session?.user,
      ),
    ),

    redirect: (BuildContext context, GoRouterState state) {
      print('GoRouter redirect: state.uri = ${state.uri.toString()}');
      print(
        'GoRouter redirect: state.matchedLocation = ${state.matchedLocation}',
      );
      print('GoRouter redirect: state.fullPath = ${state.fullPath}');

      final String rawPath = state.uri.path;
      String derivedPath = rawPath;
      if (rawPath.startsWith('//')) {
        derivedPath = rawPath.substring(1);
      } else if (!rawPath.startsWith('/')) {
        derivedPath = '/$rawPath';
      }
      final String currentLocation = state.matchedLocation;
      print('GoRouter redirect: derivedPath for matching = $derivedPath');

      final bool isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final bool onAuthRelevantScreen =
          currentLocation == '/${AppRouteNames.login}' ||
          currentLocation == '/${AppRouteNames.signup}' ||
          currentLocation == '/${AppRouteNames.landing}';

      // If on the auth callback route (HTTPS link)
      if (currentLocation == '/${AppRouteNames.authCallback}') {
        if (isAuthenticated) {
          return '/${AppRouteNames.home}';
        }
        return null; // Stay on AuthCallbackScreen while processing
      }

      // If authenticated:
      if (isAuthenticated) {
        if (onAuthRelevantScreen) {
          return '/${AppRouteNames.home}';
        }
        return null;
      }
      // If NOT authenticated:
      else {
        // If not on login, signup, landing, or authCallback, redirect to login.
        if (!onAuthRelevantScreen) {
          return '/${AppRouteNames.login}';
        }
        return null;
      }
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
        path: '/${AppRouteNames.profile}',
        name: AppRouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // Route for Loading Screen
      // Route for HTTPS Auth Callback
      GoRoute(
        path: '/${AppRouteNames.authCallback}',
        name: AppRouteNames.authCallback,
        builder: (context, state) => const AuthCallbackScreen(),
      ),
      // Main navigation shell that contains the bottom navigation bar
      // This is the key change - using a ShellRoute for the main navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // MainNavigationScreen now receives the active screen as a child
          return MainNavigationScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/${AppRouteNames.home}',
            name: AppRouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/${AppRouteNames.chat}',
            name: AppRouteNames.chat,
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/${AppRouteNames.materials}',
            name: AppRouteNames.materials,
            builder: (context, state) => const MaterialsScreen(),
          ),
          GoRoute(
            path: '/${AppRouteNames.review}',
            name: AppRouteNames.review,
            builder: (context, state) => const ReviewScreen(),
          ),
          GoRoute(
            path: '/${AppRouteNames.planner}',
            name: AppRouteNames.planner,
            builder: (context, state) => const PlannerScreen(),
          ),
        ],
      ),
    ],
  );
});

// Helper class for GoRouter to listen to Riverpod stream changes (Riverpod 2.0+)
// This is crucial for GoRouter to react to auth state changes from a StreamProvider.
class GoRouterRefreshStream extends ChangeNotifier {
  final Stream<User?> _stream;
  StreamSubscription<User?>? _subscription;

  GoRouterRefreshStream(this._stream) {
    _subscription = _stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
