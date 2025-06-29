import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';

/// Service implementing the simplified SM-2 (SuperMemo 2) spaced repetition algorithm.
///
/// This service calculates the next review date and updates spaced repetition metadata
/// based on user's self-assessment during review sessions.
///
/// ## Algorithm Overview
///
/// The SM-2 algorithm uses three key parameters per quiz item:
///
/// 1. **Easiness Factor (EF)**: Determines how easy an item is to remember
///    - Range: 1.3 to 3.0 (default: 2.5)
///    - Higher values = easier to remember = longer intervals
///
/// 2. **Interval**: Number of days until the next review
///    - Starts at 1 day for new items
///    - Calculated based on EF and repetition count
///
/// 3. **Repetitions**: Number of consecutive successful reviews
///    - Resets to 0 when user struggles with an item (rating < 3)
///    - Increases by 1 for each successful review
///
/// ## Difficulty Rating Scale
///
/// Users rate their performance on a 4-point scale:
/// - **Forgot (0)**: Complete failure, didn't remember at all
/// - **Hard (1)**: Remembered with serious difficulty
/// - **Good (2)**: Remembered with some difficulty
/// - **Easy (3)**: Remembered easily
///
/// ## Algorithm Logic
///
/// ### For ratings < 2 (Forgot/Hard):
/// - Reset repetitions to 0
/// - Reset interval to 1 day
/// - Slightly decrease EF (but keep it >= 1.3)
///
/// ### For ratings >= 2 (Good/Easy):
/// - Increase repetitions by 1
/// - Calculate new interval:
///   - If repetitions = 1: interval = 1 day
///   - If repetitions = 2: interval = 6 days
///   - If repetitions > 2: interval = previous_interval * EF
/// - Adjust EF based on rating quality
///
/// ## References
/// - Original SM-2 Algorithm: https://supermemo.com/en/archives1990-2015/english/ol/sm2
/// - Anki's modifications: https://docs.ankiweb.net/deck-options.html#reviews
class SpacedRepetitionService {
  /// Default easiness factor for new items
  static const double defaultEasinessFactor = 2.5;

  /// Minimum allowed easiness factor
  static const double minEasinessFactor = 1.3;

  /// Maximum allowed easiness factor
  static const double maxEasinessFactor = 3.0;

  /// Initial interval for first review (1 day)
  static const int initialInterval = 1;

  /// Interval for second successful review (6 days)
  static const int secondInterval = 6;

  /// Calculates the next review date and spaced repetition metadata based on user's response.
  ///
  /// This method implements the core SM-2 algorithm logic and returns updated
  /// spaced repetition parameters that should be saved to the quiz item.
  ///
  /// [currentItem] - The quiz item being reviewed with current spaced repetition data
  /// [difficultyRating] - User's self-assessment of how well they knew the answer
  /// [responseTime] - Optional response time in seconds for analytics
  /// [isCorrect] - For MCQs, whether the answer was objectively correct (optional)
  ///
  /// Returns [SpacedRepetitionResult] containing the calculated next review parameters
  SpacedRepetitionResult calculateNextReview({
    required QuizItemEntity currentItem,
    required DifficultyRating difficultyRating,
    int? responseTime,
    bool? isCorrect,
  }) {
    // Store previous values for analytics
    final previousEF = currentItem.easinessFactor;
    final previousInterval = currentItem.intervalDays;
    final previousRepetitions = currentItem.repetitions;

    // Adjust difficulty rating for MCQs based on objective correctness
    final adjustedRating = isCorrect != null
        ? adjustRatingForObjectiveCorrectness(
            userRating: difficultyRating,
            isCorrect: isCorrect,
            itemType: currentItem.itemType,
          )
        : difficultyRating;

    // Convert difficulty rating to numeric scale (0-3)
    final int rating = adjustedRating.index;

    // Initialize new values with current state
    double newEF = previousEF;
    int newRepetitions = previousRepetitions;
    int newInterval = previousInterval;

    // Apply SM-2 algorithm logic
    if (rating < 2) {
      // Poor performance (Forgot = 0, Hard = 1)
      // Reset the learning process
      newRepetitions = 0;
      newInterval = initialInterval;

      // Decrease easiness factor for harder items, but don't go below minimum
      newEF = _adjustEasinessFactor(newEF, rating);
    } else {
      // Good performance (Good = 2, Easy = 3)
      // Progress in the learning sequence
      newRepetitions = previousRepetitions + 1;

      // Calculate new interval based on repetition count
      if (newRepetitions == 1) {
        newInterval = initialInterval; // 1 day
      } else if (newRepetitions == 2) {
        newInterval = secondInterval; // 6 days
      } else {
        // For subsequent reviews: interval = previous_interval * EF
        newInterval = (previousInterval * newEF).round();
      }

      // Adjust easiness factor based on performance quality
      newEF = _adjustEasinessFactor(newEF, rating);
    }

    // Ensure EF stays within bounds
    newEF = newEF.clamp(minEasinessFactor, maxEasinessFactor);

    // Ensure minimum interval of 1 day
    newInterval = newInterval.clamp(1, double.infinity).toInt();

    // Calculate next review date
    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    return SpacedRepetitionResult(
      newEasinessFactor: newEF,
      newIntervalDays: newInterval,
      newRepetitions: newRepetitions,
      nextReviewDate: nextReviewDate,
      previousEasinessFactor: previousEF,
      previousIntervalDays: previousInterval,
      previousRepetitions: previousRepetitions,
      responseTimeSeconds: responseTime,
    );
  }

  /// Adjusts the easiness factor based on the user's performance rating.
  ///
  /// The adjustment follows the original SM-2 formula with some modifications:
  /// EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
  ///
  /// Where q is the quality rating (0-5 in original, we map 0-3 to 0-5):
  /// - Forgot (0) → 0 in SM-2 scale
  /// - Hard (1) → 2 in SM-2 scale
  /// - Good (2) → 4 in SM-2 scale
  /// - Easy (3) → 5 in SM-2 scale
  double _adjustEasinessFactor(double currentEF, int rating) {
    // Map our 0-3 scale to SM-2's 0-5 scale
    int sm2Rating;
    switch (rating) {
      case 0: // Forgot
        sm2Rating = 0;
        break;
      case 1: // Hard
        sm2Rating = 2;
        break;
      case 2: // Good
        sm2Rating = 4;
        break;
      case 3: // Easy
        sm2Rating = 5;
        break;
      default:
        sm2Rating = 4; // Default to Good
    }

    // Apply SM-2 easiness factor adjustment formula
    // EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
    final double adjustment =
        0.1 - (5 - sm2Rating) * (0.08 + (5 - sm2Rating) * 0.02);

    return currentEF + adjustment;
  }

  /// Gets all quiz items that are due for review (next review date <= now).
  ///
  /// This is a utility method to filter items that should be presented
  /// in the current review session.
  ///
  /// [allItems] - List of all quiz items from a quiz
  /// [referenceDate] - Date to compare against (defaults to now)
  ///
  /// Returns list of items due for review, sorted by next review date (oldest first)
  List<QuizItemEntity> getDueItems(
    List<QuizItemEntity> allItems, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();

    return allItems
        .where(
          (item) =>
              item.nextReviewDate.isBefore(now) ||
              item.nextReviewDate.isAtSameMomentAs(now),
        )
        .toList()
      ..sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
  }

  /// Gets new items that haven't been reviewed yet.
  ///
  /// New items are those with repetitions = 0 and last reviewed date
  /// is the same as created date (indicating no actual reviews yet).
  ///
  /// [allItems] - List of all quiz items from a quiz
  ///
  /// Returns list of new/unreviewed items
  List<QuizItemEntity> getNewItems(List<QuizItemEntity> allItems) {
    return allItems
        .where(
          (item) =>
              item.repetitions == 0 && item.lastReviewedAt == item.createdAt,
        )
        .toList();
  }

  /// Calculates learning statistics for a set of quiz items.
  ///
  /// Provides insights into learning progress including mastery levels,
  /// review distribution, and performance metrics.
  ///
  /// [items] - List of quiz items to analyze
  ///
  /// Returns [LearningStats] with calculated metrics
  LearningStats calculateLearningStats(List<QuizItemEntity> items) {
    if (items.isEmpty) {
      return LearningStats.empty();
    }

    final now = DateTime.now();

    // Count items by status
    int newItems = 0;
    int learningItems = 0; // 1-2 repetitions
    int masteredItems = 0; // 3+ repetitions
    int dueItems = 0;

    double totalEF = 0;
    int totalRepetitions = 0;

    for (final item in items) {
      // Count by repetition level
      if (item.repetitions == 0) {
        newItems++;
      } else if (item.repetitions < 3) {
        learningItems++;
      } else {
        masteredItems++;
      }

      // Count due items
      if (item.nextReviewDate.isBefore(now) ||
          item.nextReviewDate.isAtSameMomentAs(now)) {
        dueItems++;
      }

      // Accumulate for averages
      totalEF += item.easinessFactor;
      totalRepetitions += item.repetitions;
    }

    return LearningStats(
      totalItems: items.length,
      newItems: newItems,
      learningItems: learningItems,
      masteredItems: masteredItems,
      dueItems: dueItems,
      averageEasinessFactor: totalEF / items.length,
      averageRepetitions: totalRepetitions / items.length,
    );
  }

  /// Adjusts difficulty rating for MCQ responses based on objective correctness.
  ///
  /// For MCQs, we combine objective correctness with subjective difficulty:
  /// - If answer is WRONG: Automatically set to "Forgot" (0) regardless of user rating
  /// - If answer is CORRECT: Use user's subjective difficulty rating, but ensure minimum of "Hard" (1)
  ///   This prevents gaming the system by selecting "Easy" on lucky guesses
  ///
  /// [userRating] - User's subjective difficulty assessment
  /// [isCorrect] - Whether the MCQ answer was objectively correct
  /// [itemType] - Type of quiz item (flashcard vs MCQ)
  ///
  /// Returns adjusted difficulty rating for the algorithm
  DifficultyRating adjustRatingForObjectiveCorrectness({
    required DifficultyRating userRating,
    required bool isCorrect,
    required QuizItemType itemType,
  }) {
    // For flashcards, use user rating as-is (subjective assessment)
    if (itemType == QuizItemType.flashcard) {
      return userRating;
    }

    // For MCQs, adjust based on objective correctness
    if (!isCorrect) {
      // Wrong answer always maps to "Forgot" to reset learning progress
      return DifficultyRating.forgot;
    }

    // Correct answer: ensure minimum difficulty of "Hard" to prevent gaming
    // This accounts for lucky guesses while still allowing subjective assessment
    switch (userRating) {
      case DifficultyRating.forgot:
        return DifficultyRating.hard; // Upgrade from Forgot to Hard if correct
      case DifficultyRating.hard:
      case DifficultyRating.good:
      case DifficultyRating.easy:
        return userRating; // Keep user's assessment if reasonable
    }
  }
}

/// Result of spaced repetition calculation containing new parameters.
class SpacedRepetitionResult {
  /// New easiness factor after applying SM-2 algorithm
  final double newEasinessFactor;

  /// New interval in days until next review
  final int newIntervalDays;

  /// New repetition count
  final int newRepetitions;

  /// Calculated next review date
  final DateTime nextReviewDate;

  /// Previous easiness factor (for analytics)
  final double previousEasinessFactor;

  /// Previous interval (for analytics)
  final int previousIntervalDays;

  /// Previous repetitions (for analytics)
  final int previousRepetitions;

  /// Response time in seconds (for analytics)
  final int? responseTimeSeconds;

  const SpacedRepetitionResult({
    required this.newEasinessFactor,
    required this.newIntervalDays,
    required this.newRepetitions,
    required this.nextReviewDate,
    required this.previousEasinessFactor,
    required this.previousIntervalDays,
    required this.previousRepetitions,
    this.responseTimeSeconds,
  });
}

/// Learning statistics for a collection of quiz items.
class LearningStats {
  /// Total number of items
  final int totalItems;

  /// Items that haven't been reviewed yet
  final int newItems;

  /// Items in learning phase (1-2 successful reviews)
  final int learningItems;

  /// Items that are mastered (3+ successful reviews)
  final int masteredItems;

  /// Items currently due for review
  final int dueItems;

  /// Average easiness factor across all items
  final double averageEasinessFactor;

  /// Average number of repetitions across all items
  final double averageRepetitions;

  const LearningStats({
    required this.totalItems,
    required this.newItems,
    required this.learningItems,
    required this.masteredItems,
    required this.dueItems,
    required this.averageEasinessFactor,
    required this.averageRepetitions,
  });

  /// Creates empty learning stats (for when there are no items)
  factory LearningStats.empty() {
    return const LearningStats(
      totalItems: 0,
      newItems: 0,
      learningItems: 0,
      masteredItems: 0,
      dueItems: 0,
      averageEasinessFactor: 0,
      averageRepetitions: 0,
    );
  }

  /// Calculate accuracy/mastery percentage
  double get masteryPercentage {
    if (totalItems == 0) return 0;
    return (masteredItems / totalItems) * 100;
  }

  /// Calculate percentage of items due for review
  double get duePercentage {
    if (totalItems == 0) return 0;
    return (dueItems / totalItems) * 100;
  }
}
