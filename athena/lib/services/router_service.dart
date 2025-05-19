import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/loading_screen.dart';
import 'auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'router_service.g.dart';

// This is crucial for making sure that the same navigator is used when rebuilding the GoRouter
final navigatorKey = GlobalKey<NavigatorState>();
Uri? initUrl = Uri.base; // Needed to set initial URL state

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
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: initUrl?.path ?? '/',
    navigatorKey: navigatorKey,
    refreshListenable: GoRouterRefreshStream(
      ref.read(authProvider.notifier).authStateController.stream,
    ),
    redirect: (context, state) {
      // Handle redirection based on auth state
      return authState.when(
        data: (user) {
          // Build initial path
          String? path = initUrl?.path;
          final queryString = initUrl?.query.trim() ?? '';
          if (queryString.isNotEmpty && path != null) {
            path += "?$queryString";
          }

          // Redirect logic
          if (user == null && path != '/login' && path != '/loading') {
            return '/login';
          }

          if (user != null && (path == '/login' || path == '/loading')) {
            return '/';
          }

          // After handling initial redirection, clear initUrl
          initUrl = null;
          return path;
        },
        error: (_, __) => '/loading',
        loading: () => '/loading',
      );
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
        name: 'home',
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) {
          // Check for auth code in query parameters
          final code = state.uri.queryParameters['code'];
          if (code != null) {
            // Handle auth code here
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Process the code and then navigate
              Future.microtask(() async {
                try {
                  final supabase = Supabase.instance.client;
                  // Exchange code for session
                  await supabase.auth.exchangeCodeForSession(code);
                  // Navigate to home after successful auth
                  if (context.mounted) {
                    context.go('/home');
                  }
                } catch (e) {
                  // Handle errors
                  debugPrint('Error processing auth code: $e');
                }
              });
            });
          }

          // Return your normal home page
          return MaterialPage(child: HomeScreen());
        },
      ),
    ],
  );
}
