import 'package:athena/domain/enums/subject.dart';
import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:athena/features/home/domain/repositories/dashboard_repository.dart';

/// Dummy implementation of the dashboard repository
/// This implementation returns mock data for development purposes
class DashboardRepositoryImpl implements DashboardRepository {
  
  @override
  Future<DashboardData> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return DashboardData.dummy();
  }

  @override
  Future<int> getMaterialCount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return 3;
  }

  @override
  Future<int> getQuizItemCount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return 12;
  }

  @override
  Future<List<UpcomingSession>> getUpcomingSessions() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      UpcomingSession(
        title: 'Review Biology Notes',
        time: 'Today, 14:00 - 15:30',
        iconType: SessionIconType.science,
      ),
      UpcomingSession(
        title: 'Math Practice Quiz',
        time: 'Today, 17:00 - 18:00',
        iconType: SessionIconType.math,
      ),
    ];
  }

  @override
  Future<List<ReviewItem>> getReviewItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ReviewItem(title: 'Biology Terms', count: 3, subject: Subject.biology),
      ReviewItem(title: 'History Dates', count: 2, subject: Subject.history),
    ];
  }
} 