// ignore_for_file: avoid_print

import 'dart:async';

import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/auth/presentation/views/auth_callback_screen.dart';
import 'package:athena/features/auth/presentation/views/landing_screen.dart';
import 'package:athena/features/auth/presentation/views/login_screen.dart';
import 'package:athena/features/auth/presentation/views/profile_screen.dart';
import 'package:athena/features/auth/presentation/views/signup_screen.dart';
import 'package:athena/features/auth/presentation/views/custom_update_password_screen.dart';
import 'package:athena/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:athena/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:athena/features/errors/presentation/views/not_found_screen.dart';
import 'package:athena/features/home/presentation/views/home_screen.dart';
import 'package:athena/features/navigation/main_navigation_screen.dart';
import 'package:athena/features/planner/presentation/views/planner_screen.dart';
import 'package:athena/features/planner/presentation/views/progress_insights_screen.dart';
import 'package:athena/features/review/presentation/views/create_quiz_screen.dart';
import 'package:athena/features/review/presentation/views/edit_quiz_screen.dart';
import 'package:athena/features/review/presentation/views/quiz_detail_screen.dart';
import 'package:athena/features/review/presentation/views/review_screen.dart';
import 'package:athena/features/review/presentation/views/review_session_screen.dart';
import 'package:athena/features/review/presentation/views/quiz_results_screen.dart';
import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/study_materials/presentation/views/materials_screen.dart';
import 'package:athena/features/study_materials/presentation/views/material_detail_screen.dart';
import 'package:athena/features/study_materials/presentation/views/add_edit_material_screen.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
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
  // final authState = ref.watch(appAuthProvider);

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
      print('GoRouter redirect: state.uri.path = ${state.uri.path}');

      final String rawPath = state.uri.path;
      String derivedPath = rawPath;
      if (rawPath.startsWith('//')) {
        derivedPath = rawPath.substring(1);
      } else if (!rawPath.startsWith('/')) {
        derivedPath = '/$rawPath';
      }
      final String currentLocation = state.matchedLocation;
      print('GoRouter redirect: derivedPath for matching = $derivedPath');

      final authStateValue = ref.watch(appAuthProvider);
      final bool isAuthenticated = authStateValue.maybeWhen(
        data: (user) => user != null,
        orElse:
            () =>
                false, // Treat loading and error as not authenticated for this check
      );
      final bool isAuthLoading = authStateValue.isLoading;
      // Get the last event from the AppAuth notifier
      final AuthChangeEvent? lastAuthEvent =
          ref.read(appAuthProvider.notifier).lastAuthEvent;

      // Check for password recovery event FIRST, regardless of location
      // This ensures recovery links always go to update password screen
      if (lastAuthEvent == AuthChangeEvent.passwordRecovery) {
        print(
          'GoRouter redirect: Password Recovery event detected, redirecting to /update-password',
        );
        // Check if user has a valid session from the recovery link
        if (Supabase.instance.client.auth.currentSession?.accessToken != null) {
          return '/${AppRouteNames.updatePassword}';
        } else {
          print(
            'GoRouter redirect: Password Recovery event, but no access token found in session. Going to /update-password anyway.',
          );
          return '/${AppRouteNames.updatePassword}';
        }
      }

      // Explicitly handle the auth callback path (for email verification, magic links)
      if (currentLocation == '/${AppRouteNames.authCallback}') {
        // If authenticated (e.g. after email verification or magic link)
        if (isAuthenticated) {
          print(
            'GoRouter redirect: AuthCallback -> Authenticated, redirecting to /home',
          );
          return '/${AppRouteNames.home}';
        }

        print(
          'GoRouter redirect: AuthCallback -> Not authenticated or loading, staying on /auth/callback',
        );
        return null;
      }

      // Route for actually updating the password (requires a valid session from recovery link)
      if (currentLocation == '/${AppRouteNames.updatePassword}') {
        // Ensure there's an active session, typically set by the recovery link
        if (Supabase.instance.client.auth.currentSession?.accessToken != null) {
          print(
            'GoRouter redirect: On /update-password with active session, allowing access.',
          );
          return null; // Allow access to update password screen
        }
        // If somehow on this path without a session from recovery, redirect to login
        print(
          'GoRouter redirect: On /update-password WITHOUT active session, redirecting to /login',
        );
        return '/${AppRouteNames.login}';
      }

      final bool onAuthRelevantScreen =
          currentLocation == '/${AppRouteNames.login}' ||
          currentLocation == '/${AppRouteNames.signup}' ||
          currentLocation == '/${AppRouteNames.landing}' ||
          currentLocation == '/${AppRouteNames.forgotPassword}' ||
          currentLocation == '/${AppRouteNames.updatePassword}';

      // If authenticated (and not on auth callback screen):
      if (isAuthenticated) {
        if (onAuthRelevantScreen) {
          print(
            'GoRouter redirect: Authenticated on auth screen ($currentLocation), redirecting to /home',
          );
          return '/${AppRouteNames.home}';
        }
        print(
          'GoRouter redirect: Authenticated on $currentLocation, no redirect needed.',
        );
        return null; // Already authenticated and on a protected route, or on a public route they can access
      }
      // If NOT authenticated (and not on auth callback screen):
      else {
        // If auth is loading and we are trying to access a non-auth screen,
        // it might be too early to redirect to login.
        // However, for simplicity, current logic redirects.
        // Consider showing a global loading indicator if isAuthLoading is true here.
        if (isAuthLoading && !onAuthRelevantScreen && currentLocation != '/') {
          // If actively loading auth state and trying to go somewhere other than root or auth pages,
          // maybe wait or show loading. For now, let it fall through to login if not on auth relevant screen.
          print(
            'GoRouter redirect: Auth loading, on $currentLocation. Current logic will likely redirect to login if not on auth screen.',
          );
        }

        if (!onAuthRelevantScreen) {
          print(
            'GoRouter redirect: Not authenticated, not on auth screen ($currentLocation), redirecting to /login',
          );
          return '/${AppRouteNames.login}';
        }
        print(
          'GoRouter redirect: Not authenticated, but on auth screen ($currentLocation), no redirect needed.',
        );
        return null; // On login, signup, or landing screen, allow access
      }
    },
    errorBuilder: (context, state) {
      print(
        'GoRouter errorBuilder: Navigating to ${state.uri.toString()} caused an error.',
      );
      print('GoRouter errorBuilder: state.uri.path = ${state.uri.path}');
      print('GoRouter errorBuilder: state.error = ${state.error}');
      // Use the new NotFoundScreen
      return NotFoundScreen(routerState: state);
    },
    routes: [
      // Authentication shell route to prevent back button from exiting app
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return child;
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
            path: '/${AppRouteNames.forgotPassword}',
            name: AppRouteNames.forgotPassword,
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
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
      GoRoute(
        path: '/${AppRouteNames.updatePassword}',
        name: AppRouteNames.updatePassword,
        builder: (context, state) => const CustomUpdatePasswordScreen(),
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
          GoRoute(
            path: '/${AppRouteNames.progressInsights}',
            name: AppRouteNames.progressInsights,
            builder: (context, state) => const ProgressInsightsScreen(),
          ),
        ],
      ),

      // Materials routes
      GoRoute(
        path: '/${AppRouteNames.materialDetail}/:materialId',
        name: AppRouteNames.materialDetail,
        builder: (context, state) {
          final materialId = state.pathParameters['materialId']!;
          final tabParam = state.uri.queryParameters['tab'];
          final initialTab = tabParam == 'summary' ? 1 : 0;
          return MaterialDetailScreen(
            materialId: materialId,
            initialTabIndex: initialTab,
          );
        },
      ),
      GoRoute(
        path: '/${AppRouteNames.addEditMaterial}',
        name: AppRouteNames.addEditMaterial,
        builder: (context, state) {
          // Get optional query parameters
          final contentType = state.uri.queryParameters['contentType'];
          final materialId = state.uri.queryParameters['materialId'];

          return AddEditMaterialScreen(
            materialId: materialId,
            initialContentType:
                contentType != null
                    ? ContentType.values.firstWhere(
                      (e) => e.toString().split('.').last == contentType,
                      orElse: () => ContentType.typedText,
                    )
                    : null,
          );
        },
      ),

      // Review routes
      GoRoute(
        path: '/${AppRouteNames.createQuiz}',
        name: AppRouteNames.createQuiz,
        builder:
            (context, state) => CreateQuizScreen(
              studyMaterialId: state.uri.queryParameters['studyMaterialId'],
              initialMode: state.uri.queryParameters['mode'],
            ),
      ),
      GoRoute(
        path: '/${AppRouteNames.quizDetail}/:quizId',
        name: AppRouteNames.quizDetail,
        builder:
            (context, state) =>
                QuizDetailScreen(quizId: state.pathParameters['quizId']!),
      ),
      GoRoute(
        path: '/${AppRouteNames.editQuiz}/:quizId',
        name: AppRouteNames.editQuiz,
        builder:
            (context, state) =>
                EditQuizScreen(quizId: state.pathParameters['quizId']!),
      ),
      GoRoute(
        path: '/${AppRouteNames.reviewSession}/:quizId',
        name: AppRouteNames.reviewSession,
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          final sessionType = state.uri.queryParameters['sessionType'];
          final maxItems = state.uri.queryParameters['maxItems'];

          SessionType? parsedSessionType;
          if (sessionType != null) {
            switch (sessionType.toLowerCase()) {
              case 'due':
              case 'dueonly':
                parsedSessionType = SessionType.dueOnly;
                break;
              case 'new':
              case 'newonly':
                parsedSessionType = SessionType.newOnly;
                break;
              case 'mixed':
              default:
                parsedSessionType = SessionType.mixed;
                break;
            }
          }

          return ReviewSessionScreen(
            quizId: quizId,
            sessionType: parsedSessionType,
            maxItems: maxItems != null ? int.tryParse(maxItems) : null,
          );
        },
      ),
      GoRoute(
        path: '/${AppRouteNames.quizResults}',
        name: AppRouteNames.quizResults,
        builder: (context, state) {
          final session = state.extra as ReviewSessionEntity;
          return QuizResultsScreen(session: session);
        },
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
