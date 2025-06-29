import 'package:athena/features/auth/domain/entities/profile_entity.dart';
import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_state.freezed.dart';

/// State for the home screen dashboard.
///
/// Manages all the data and UI state for the home dashboard including:
/// - User profile information
/// - Dashboard statistics (material count, quiz items)
/// - Upcoming sessions from planner
/// - Review items due for review
/// - Loading states and error handling
@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    // User data
    ProfileEntity? userProfile,
    
    // Dashboard data
    DashboardData? dashboardData,
    
    // Individual data components
    @Default(0) int materialCount,
    @Default(0) int quizItemCount,
    @Default([]) List<UpcomingSession> upcomingSessions,
    @Default([]) List<ReviewItem> reviewItems,
    
    // Loading states
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    @Default(false) bool isLoadingProfile,
    @Default(false) bool isLoadingDashboard,
    @Default(false) bool isLoadingMaterials,
    @Default(false) bool isLoadingQuizItems,
    @Default(false) bool isLoadingSessions,
    @Default(false) bool isLoadingReviewItems,

    // Error handling
    String? error,
    String? profileError,
    String? dashboardError,
    String? materialsError,
    String? quizItemsError,
    String? sessionsError,
    String? reviewItemsError,

    // UI states
    @Default(false) bool showEmptyState,
    
    // Edge function demo state
    @Default('Scholar') String edgeFunctionName,
    Map<String, dynamic>? edgeFunctionResponse,
    @Default(false) bool isCallingEdgeFunction,
    String? edgeFunctionError,
  }) = _HomeState;

  // Computed properties
  bool get hasError => error != null;
  bool get hasProfileError => profileError != null;
  bool get hasDashboardError => dashboardError != null;
  bool get hasProfile => userProfile != null;
  bool get hasDashboardData => dashboardData != null;
  bool get hasUpcomingSessions => upcomingSessions.isNotEmpty;
  bool get hasReviewItems => reviewItems.isNotEmpty;
  bool get hasAnyData => hasDashboardData || materialCount > 0 || quizItemCount > 0;
  
  // Check if any loading is in progress
  bool get hasAnyLoading => 
      isLoading || 
      isRefreshing || 
      isLoadingProfile || 
      isLoadingDashboard || 
      isLoadingMaterials || 
      isLoadingQuizItems || 
      isLoadingSessions || 
      isLoadingReviewItems ||
      isCallingEdgeFunction;

  // Get display name with priority: fullName from profile > fallback
  String getDisplayName(String? authUserName, String? authEmail) {
    if (userProfile?.fullName?.trim().isNotEmpty == true) {
      return userProfile!.fullName!;
    }
    
    return authUserName ?? 
           authEmail?.split('@').first ?? 
           'Scholar';
  }

  // Get formatted material count as string
  String get formattedMaterialCount {
    return materialCount.toString();
  }

  // Get formatted quiz item count as string
  String get formattedQuizItemCount {
    return quizItemCount.toString();
  }

  // Get total due items count
  int get totalDueItems {
    return reviewItems.fold(0, (total, item) => total + item.count);
  }

  // Get formatted due items count
  String get formattedDueItemsCount {
    return totalDueItems.toString();
  }

  // Get today's sessions count
  int get todaySessionsCount {
    // In a real implementation, this would filter sessions by date
    return upcomingSessions.length;
  }

  // Get formatted today's sessions count
  String get formattedTodaySessionsCount {
    return todaySessionsCount.toString();
  }

  // Check if there are any errors that should be displayed
  bool get hasDisplayableError {
    return hasError || hasProfileError || hasDashboardError;
  }

  // Get the most relevant error message to display
  String? get displayError {
    return error ?? profileError ?? dashboardError;
  }

  // Check if data is empty and should show empty state
  bool get shouldShowEmptyState {
    return showEmptyState && 
           !hasAnyLoading && 
           !hasAnyData &&
           !hasDisplayableError;
  }

  // Check if initial loading is complete
  bool get isInitialLoadComplete {
    return !isLoading && !isLoadingProfile && !isLoadingDashboard;
  }

  // Get edge function response message
  String? get edgeFunctionMessage {
    return edgeFunctionResponse?['message'] as String?;
  }

  // Check if edge function has been called successfully
  bool get hasEdgeFunctionResponse {
    return edgeFunctionResponse != null && edgeFunctionError == null;
  }

  // Check if edge function call failed
  bool get hasEdgeFunctionError {
    return edgeFunctionError != null;
  }
}
