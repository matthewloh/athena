import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/auth/presentation/providers/profile_providers.dart';
import 'package:athena/features/home/presentation/providers/home_providers.dart';
import 'package:athena/features/home/presentation/viewmodel/home_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

/// ViewModel for managing home screen state and operations.
///
/// Handles the complete home dashboard flow:
/// - Loading user profile information
/// - Fetching dashboard statistics (materials, quiz items)
/// - Loading upcoming sessions from planner
/// - Fetching review items due for review
/// - Managing edge function demo calls
/// - Coordinating refresh operations
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    // Initialize with empty state
    final initialState = const HomeState();

    // Listen to auth state changes
    ref.listen(appAuthProvider, (previous, next) {
      // Load data when user becomes authenticated
      if (next.hasValue && next.value != null) {
        _loadAllData();
      } else {
        // Clear data when user logs out
        state = const HomeState();
      }
    });

    // Listen to profile provider changes
    ref.listen(currentUserProfileProvider, (previous, next) {
      next.when(
        data: (profile) {
          state = state.copyWith(
            userProfile: profile,
            isLoadingProfile: false,
            profileError: null,
          );
        },
        loading: () {
          state = state.copyWith(isLoadingProfile: true, profileError: null);
        },
        error: (error, stack) {
          state = state.copyWith(
            isLoadingProfile: false,
            profileError: error.toString(),
          );
        },
      );
    });

    // Try to load data immediately if user is already authenticated
    final authState = ref.read(appAuthProvider);
    if (authState.hasValue && authState.value != null) {
      // Use a microtask to avoid calling setState during build
      Future.microtask(() => _loadAllData());
    }

    return initialState;
  }

  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  /// Load all dashboard data
  Future<void> loadAllData() async {
    await _loadAllData();
  }

  /// Refresh all dashboard data
  Future<void> refreshAllData() async {
    debugPrint('HomeViewModel: refreshAllData called');
    state = state.copyWith(isRefreshing: true, error: null);
    
    // Invalidate all providers to force refresh
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(dashboardDataProvider);
    ref.invalidate(materialCountProvider);
    ref.invalidate(quizItemCountProvider);
    ref.invalidate(upcomingSessionsProvider);
    ref.invalidate(reviewItemsProvider);
    
    await _loadAllData();
  }

  /// Internal method to load all dashboard data
  Future<void> _loadAllData() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'User not authenticated',
        showEmptyState: true,
      );
      return;
    }

    // Set loading state if not already refreshing
    if (!state.isRefreshing) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Load data in parallel for better performance
      await Future.wait([
        _loadDashboardData(),
        _loadMaterialCount(),
        _loadQuizItemCount(),
        _loadUpcomingSessions(),
        _loadReviewItems(),
      ]);

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: null,
        showEmptyState: !state.hasAnyData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: 'Failed to load dashboard data: ${e.toString()}',
        showEmptyState: !state.hasAnyData,
      );
    }
  }

  /// Load dashboard data
  Future<void> _loadDashboardData() async {
    state = state.copyWith(isLoadingDashboard: true, dashboardError: null);

    try {
      final dashboardDataAsync = ref.read(dashboardDataProvider.future);
      final dashboardData = await dashboardDataAsync;

      state = state.copyWith(
        isLoadingDashboard: false,
        dashboardData: dashboardData,
        dashboardError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingDashboard: false,
        dashboardError: 'Failed to load dashboard data: ${e.toString()}',
      );
    }
  }

  /// Load material count
  Future<void> _loadMaterialCount() async {
    state = state.copyWith(isLoadingMaterials: true, materialsError: null);

    try {
      final materialCountAsync = ref.read(materialCountProvider.future);
      final materialCount = await materialCountAsync;

      state = state.copyWith(
        isLoadingMaterials: false,
        materialCount: materialCount,
        materialsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMaterials: false,
        materialsError: 'Failed to load material count: ${e.toString()}',
      );
    }
  }

  /// Load quiz item count
  Future<void> _loadQuizItemCount() async {
    state = state.copyWith(isLoadingQuizItems: true, quizItemsError: null);

    try {
      final quizItemCountAsync = ref.read(quizItemCountProvider.future);
      final quizItemCount = await quizItemCountAsync;

      state = state.copyWith(
        isLoadingQuizItems: false,
        quizItemCount: quizItemCount,
        quizItemsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingQuizItems: false,
        quizItemsError: 'Failed to load quiz item count: ${e.toString()}',
      );
    }
  }

  /// Load upcoming sessions
  Future<void> _loadUpcomingSessions() async {
    state = state.copyWith(isLoadingSessions: true, sessionsError: null);

    try {
      final upcomingSessionsAsync = ref.read(upcomingSessionsProvider.future);
      final upcomingSessions = await upcomingSessionsAsync;

      state = state.copyWith(
        isLoadingSessions: false,
        upcomingSessions: upcomingSessions,
        sessionsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSessions: false,
        sessionsError: 'Failed to load upcoming sessions: ${e.toString()}',
      );
    }
  }

  /// Load review items
  Future<void> _loadReviewItems() async {
    state = state.copyWith(isLoadingReviewItems: true, reviewItemsError: null);

    try {
      final reviewItemsAsync = ref.read(reviewItemsProvider.future);
      final reviewItems = await reviewItemsAsync;

      state = state.copyWith(
        isLoadingReviewItems: false,
        reviewItems: reviewItems,
        reviewItemsError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingReviewItems: false,
        reviewItemsError: 'Failed to load review items: ${e.toString()}',
      );
    }
  }

  /// Update edge function name
  void updateEdgeFunctionName(String name) {
    state = state.copyWith(edgeFunctionName: name);
  }

  /// Call edge function with current name
  Future<void> callEdgeFunction() async {
    state = state.copyWith(
      isCallingEdgeFunction: true,
      edgeFunctionError: null,
      edgeFunctionResponse: null,
    );

    try {
      final helloEdgeFunctionAsync = ref.read(
        helloEdgeFunctionProvider(state.edgeFunctionName).future,
      );
      final response = await helloEdgeFunctionAsync;

      state = state.copyWith(
        isCallingEdgeFunction: false,
        edgeFunctionResponse: response,
        edgeFunctionError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isCallingEdgeFunction: false,
        edgeFunctionError: 'Failed to call edge function: ${e.toString()}',
      );
    }
  }

  /// Clear any errors
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear profile error
  void clearProfileError() {
    state = state.copyWith(profileError: null);
  }

  /// Clear dashboard error
  void clearDashboardError() {
    state = state.copyWith(dashboardError: null);
  }

  /// Clear edge function error
  void clearEdgeFunctionError() {
    state = state.copyWith(edgeFunctionError: null);
  }

  /// Get display name for user
  String getDisplayName() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return state.getDisplayName(
      user?.userMetadata?['username'],
      user?.email,
    );
  }

  /// Check if any data needs loading
  bool get needsDataLoad {
    return !state.hasAnyData && !state.hasAnyLoading && !state.hasDisplayableError;
  }

  /// Force reload specific data type
  Future<void> reloadMaterialCount() async {
    ref.invalidate(materialCountProvider);
    await _loadMaterialCount();
  }

  Future<void> reloadQuizItemCount() async {
    ref.invalidate(quizItemCountProvider);
    await _loadQuizItemCount();
  }

  Future<void> reloadUpcomingSessions() async {
    ref.invalidate(upcomingSessionsProvider);
    await _loadUpcomingSessions();
  }

  Future<void> reloadReviewItems() async {
    ref.invalidate(reviewItemsProvider);
    await _loadReviewItems();
  }
}
