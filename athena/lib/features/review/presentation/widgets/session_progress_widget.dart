import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget for displaying session progress during review sessions.
///
/// This widget shows:
/// - Current item position and total items
/// - Visual progress bar
/// - Completed items count
class SessionProgressWidget extends StatelessWidget {
  /// Current item index (0-based)
  final int currentIndex;

  /// Total number of items in the session
  final int totalItems;

  /// Number of completed items
  final int completedItems;

  const SessionProgressWidget({
    super.key,
    required this.currentIndex,
    required this.totalItems,
    required this.completedItems,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalItems > 0 ? (currentIndex + 1) / totalItems : 0.0;
    final completionProgress =
        totalItems > 0 ? completedItems / totalItems : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.athenaSupportiveGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Item ${currentIndex + 1} of $totalItems',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completedItems completed',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress bars
          Stack(
            children: [
              // Background bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // Completion progress (shows answered items)
              FractionallySizedBox(
                widthFactor: completionProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Current progress (shows current position)
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% through session',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
              if (completedItems > 0)
                Text(
                  '${(completionProgress * 100).toInt()}% answered',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
