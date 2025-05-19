import 'dart:async';

import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/auth/presentation/views/landing_screen.dart';
import 'package:athena/features/auth/presentation/views/login_screen.dart';
import 'package:athena/features/auth/presentation/views/profile_screen.dart';
import 'package:athena/features/auth/presentation/views/signup_screen.dart';
import 'package:athena/features/navigation/main_navigation_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:athena/core/constants/app_route_names.dart';
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
      final bool isAuthenticated = authState.when(
        data: (user) => user != null,
        loading:
            () =>
                false, // Or handle as per your app's desired behavior during auth loading
        error:
            (_, __) =>
                false, // Treat errors as not authenticated for redirection
      );

      final loggingIn = state.matchedLocation == '/${AppRouteNames.login}';
      final signingUp = state.matchedLocation == '/${AppRouteNames.signup}';
      final onLanding = state.matchedLocation == '/${AppRouteNames.landing}';
      final onAuthCallback =
          state.matchedLocation == '/${AppRouteNames.authCallback}';

      // If on auth callback, don't redirect (needed for web auth flow)
      if (onAuthCallback) {
        return null;
      }

      // If authenticated and on an auth/landing page, redirect to home
      if (isAuthenticated && (loggingIn || signingUp || onLanding)) {
        return '/${AppRouteNames.home}';
      }

      // If not authenticated and not on an auth/landing page, redirect to login
      if (!isAuthenticated && !loggingIn && !signingUp && !onLanding) {
        return '/${AppRouteNames.login}';
      }

      return null; // No redirect needed
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
      // Auth callback route for web authentication flow
      GoRoute(
        path: '/${AppRouteNames.authCallback}',
        name: AppRouteNames.authCallback,
        builder: (context, state) {
          if (kIsWeb) {
            // Process the auth token if present in URL
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Get auth code from URL using GoRouter's state object
              final code = state.uri.queryParameters['code'];

              if (code != null) {
                try {
                  // Exchange auth code for session
                  await Supabase.instance.client.auth.exchangeCodeForSession(
                    code,
                  );

                  // If successful, navigate to home
                  if (context.mounted) {
                    context.go('/${AppRouteNames.home}');
                  }
                } catch (e) {
                  debugPrint('Error processing auth token: $e');
                  // If there's an error, still show the loading indicator
                  // The redirect will eventually take them to login
                }
              } else {
                // If no code is found, redirect to login
                if (context.mounted) {
                  context.go('/${AppRouteNames.login}');
                }
              }
            });

            // Show loading UI during processing
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Completing authentication...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Redirect to home if somehow this route is accessed on mobile
            return const Scaffold(body: Center(child: Text('Redirecting...')));
          }
        },
      ),
      // Main navigation shell that contains the bottom navigation bar
      // This is the key change - using a ShellRoute for the main navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => const MainNavigationScreen(),
        routes: [
          GoRoute(
            path: '/${AppRouteNames.home}',
            name: AppRouteNames.home,
            builder:
                (context, state) =>
                    const SizedBox(), // Placeholder, the actual view is managed by IndexedStack
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
