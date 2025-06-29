import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/review_response_entity.dart';
import 'package:flutter/material.dart';

/// Widget for collecting difficulty ratings from users after they've answered a question.
///
/// This widget presents the 4-point spaced repetition difficulty scale:
/// - Forgot (0): Complete failure, didn't remember at all
/// - Hard (1): Remembered with serious difficulty
/// - Good (2): Remembered with some difficulty
/// - Easy (3): Remembered easily
class DifficultyRatingWidget extends StatefulWidget {
  /// Callback when a rating is selected
  final ValueChanged<DifficultyRating> onRatingSelected;

  /// Whether the widget is in loading state (during submission)
  final bool isLoading;

  const DifficultyRatingWidget({
    super.key,
    required this.onRatingSelected,
    required this.isLoading,
  });

  @override
  State<DifficultyRatingWidget> createState() => _DifficultyRatingWidgetState();
}

class _DifficultyRatingWidgetState extends State<DifficultyRatingWidget> {
  DifficultyRating? selectedRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology,
                color: AppColors.athenaSupportiveGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'How well did you know this?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Compact rating buttons
          if (widget.isLoading) _buildCompactLoadingState() else _buildCompactRatingButtons(),
        ],
      ),
    );
  }

  Widget _buildCompactLoadingState() {
    return SizedBox(
      height: 50,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.athenaSupportiveGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Saving response...',
              style: TextStyle(color: AppColors.athenaMediumGrey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactRatingButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactRatingButton(
            rating: DifficultyRating.forgot,
            label: 'Forgot',
            color: Colors.red,
            icon: Icons.refresh,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactRatingButton(
            rating: DifficultyRating.hard,
            label: 'Hard',
            color: Colors.orange,
            icon: Icons.sentiment_dissatisfied,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactRatingButton(
            rating: DifficultyRating.good,
            label: 'Good',
            color: AppColors.athenaSupportiveGreen,
            icon: Icons.sentiment_satisfied,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactRatingButton(
            rating: DifficultyRating.easy,
            label: 'Easy',
            color: Colors.blue,
            icon: Icons.sentiment_very_satisfied,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactRatingButton({
    required DifficultyRating rating,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = selectedRating == rating;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRating = rating;
        });
        widget.onRatingSelected(rating);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.athenaMediumGrey,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.athenaMediumGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
