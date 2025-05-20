import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
        name: 'authCallback',
        path: '/auth/callback', 
        builder: (context, state) {
          // This route is hit when Supabase redirects back with a code.
          // The Supabase SDK should automatically handle the code exchange in the background
          // when Supabase.initialize() is called with autoSessionRestore: true.
          // The onAuthStateChange stream will then fire, and GoRouter's redirect logic
          // will navigate the user to the correct page (e.g., home).
          // We just need to show a loading indicator here briefly.
          debugPrint('[GoRouter /auth/callback] Arrived. SDK should handle code. Query: ${state.uri.queryParameters}');
          return const LoadingScreen(); // Show loading while SDK processes the code
        },
      ),
      // Remove the old GoRoute for path: '/' that had the code exchange logic
    ],
  );
}
