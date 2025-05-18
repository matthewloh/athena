import 'package:athena/features/home/domain/entities/dashboard_data.dart';

/// Repository interface for dashboard data
/// This defines the contract for how dashboard data is retrieved
abstract class DashboardRepository {
  /// Get dashboard data for the current user
  Future<DashboardData> getDashboardData();

  /// Get the count of study materials for the current user
  Future<int> getMaterialCount();

  /// Get the count of quiz items for the current user
  Future<int> getQuizItemCount();

  /// Get upcoming study sessions for the current user
  Future<List<UpcomingSession>> getUpcomingSessions();

  /// Get items due for review for the current user
  Future<List<ReviewItem>> getReviewItems();
} 