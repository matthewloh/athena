/// A simple entity that represents the dashboard data shown on the home screen.
/// This is currently a placeholder with dummy data, but in a real implementation
/// it would be populated from actual data sources.
class DashboardData {
  final int materialCount;
  final int quizItemsCount;
  final List<UpcomingSession> upcomingSessions;
  final List<ReviewItem> reviewItems;

  const DashboardData({
    this.materialCount = 0,
    this.quizItemsCount = 0,
    this.upcomingSessions = const [],
    this.reviewItems = const [],
  });

  // Factory method to create a dummy dashboard with sample data
  factory DashboardData.dummy() {
    return DashboardData(
      materialCount: 3,
      quizItemsCount: 12,
      upcomingSessions: [
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
      ],
      reviewItems: [
        ReviewItem(title: 'Biology Terms', count: 3, type: ReviewItemType.biology),
        ReviewItem(title: 'History Dates', count: 2, type: ReviewItemType.history),
      ],
    );
  }
}

/// Represents an upcoming study session on the dashboard
class UpcomingSession {
  final String title;
  final String time;
  final SessionIconType iconType;

  const UpcomingSession({
    required this.title,
    required this.time,
    required this.iconType,
  });
}

/// Represents a quiz or flashcard set with items due for review
class ReviewItem {
  final String title;
  final int count;
  final ReviewItemType type;

  const ReviewItem({
    required this.title,
    required this.count,
    required this.type,
  });
}

/// Icon types for study sessions
enum SessionIconType {
  science,
  math,
  literature,
  history,
  language,
  generic
}

/// Types of review items for color coding
enum ReviewItemType {
  biology,
  chemistry,
  physics,
  math,
  literature,
  history,
  language,
  other
} 