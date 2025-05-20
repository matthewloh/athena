import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers/auth_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';

part 'router_service.g.dart';

// This is crucial for making sure that the same navigator is used when rebuilding the GoRouter
final navigatorKey = GlobalKey<NavigatorState>();
// Uri? initUrl = Uri.base; // Let's try to simplify and remove explicit initUrl handling first.

// Helper class for GoRouter to listen to Riverpod stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter router(Ref ref) {
  // final authState = ref.watch(authProvider); // Watching the provider directly
  // For refresh and redirect, it's often better to listen to the core auth state changes
  final authNotifier = ref.watch(appAuthProvider.notifier);

  return GoRouter(
    // initialLocation: initUrl?.path ?? '/', // Default initialLocation is usually fine
    navigatorKey: navigatorKey,
    refreshListenable: GoRouterRefreshStream(
      authNotifier.authStateChanges, // Use the public authStateChanges stream
    ),
    redirect: (context, state) {
      final isAuthenticated = authNotifier.currentUser != null;
      // Use state.uri.path for more precise path matching, ignoring query parameters for the check
      final currentPath = state.uri.path;
      final isLoggingIn = currentPath == '/login';
      final isProcessingAuthCallback = currentPath == '/auth/callback';
      final isLoading = currentPath == '/loading';

      // Log current state for debugging
      debugPrint('[GoRouter Redirect] Path: $currentPath, Query: ${state.uri.queryParameters}, IsAuthenticated: $isAuthenticated');

      if (isLoading) return null; 
      if (isProcessingAuthCallback) return null; 

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }
      if (isAuthenticated && isLoggingIn) {
        return '/'; // Redirect to home
      }
      return null; // No redirect needed
    },
    routes: <RouteBase>[
      GoRoute(
        name: 'loading',
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        name: 'home', // Keep a named route for home
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: 'authCallback', // Name for the callback route
        path: '/auth/callback', // Define the actual callback path
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          final error = state.uri.queryParameters['error'];
          final errorDescription =
              state.uri.queryParameters['error_description'];

          if (error != null) {
            // Handle error, maybe show a specific error screen or message
            debugPrint('Auth Callback Error: $error - $errorDescription');
            // Optionally, redirect to login with an error message
            // Or show an error page: return ErrorScreen(message: errorDescription);
            return const AuthScreen(); // Or redirect to login
          }

          if (code != null) {
            // Perform the code exchange.
            // This builder might get called multiple times during widget rebuilds.
            // The actual auth state change will trigger the main redirect.
            // It's often better to do this in a way that doesn't block rendering or cause loops.
            // A common pattern is to show a loading indicator on this screen
            // and trigger the exchange once.

            // Since this is a builder, avoid async work directly here if it can be triggered multiple times.
            // The session should ideally be handled by Supabase SDK on load or via a dedicated handler.
            // For PKCE flow, exchangeCodeForSession is needed.

            // One way to handle: show a loading screen, and call exchange code.
            // Auth state change will redirect.

            // Simple immediate attempt (might need refinement for robustness):
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.microtask(() async {
                try {
                  final supabase = Supabase.instance.client;
                  await supabase.auth.exchangeCodeForSession(code);
                  // Successful exchange will trigger onAuthStateChange,
                  // and the main redirect logic will navigate to '/'.
                  // No explicit context.go('/') needed here if redirect is set up correctly.
                } catch (e) {
                  debugPrint('Error exchanging code for session: $e');
                  // If error, redirect to login or show error
                  if (context.mounted) context.goNamed('login');
                }
              });
            });
            return const LoadingScreen(); // Show loading while code is exchanged
          }

          // If no code and no error, something is wrong, redirect to login.
          return const AuthScreen();
        },
      ),
      // Remove the old GoRoute for path: '/' that had the code exchange logic
    ],
  );
}
