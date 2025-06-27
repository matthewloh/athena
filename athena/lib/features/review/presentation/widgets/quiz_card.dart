import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/shared/utils/subject_utils.dart';
import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final int itemCount;
  final int dueCount;
  final String accuracy;
  final bool isRecentlyReviewed;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.itemCount,
    this.dueCount = 0,
    this.accuracy = 'N/A',
    this.isRecentlyReviewed = false,
    this.onTap,
    this.onReview,
  });
  @override
  Widget build(BuildContext context) {
    // Debug logging
    debugPrint(
      'QuizCard for ${quiz.title}: itemCount=$itemCount, dueCount=$dueCount, accuracy=$accuracy',
    );

    // Get subject attributes using SubjectUtils
    final (subjectColor, subjectIcon) = SubjectUtils.getSubjectAttributes(
      quiz.subject,
    );
    final subjectDisplayName = SubjectUtils.getDisplayName(quiz.subject);
    final bool hasDueItems = dueCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(subjectIcon, color: subjectColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Quiz info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (quiz.description != null &&
                            quiz.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            quiz.description!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags and status - Using Wrap to prevent overflow
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Left side tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Subject tag
                      if (quiz.subject != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: subjectColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subjectDisplayName,
                            style: TextStyle(
                              color: subjectColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      // Quiz type tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              quiz.quizType == QuizType.flashcard
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              quiz.quizType == QuizType.flashcard
                                  ? Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    width: 0.5,
                                  )
                                  : Border.all(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              quiz.quizType == QuizType.flashcard
                                  ? Icons.flip_to_front
                                  : Icons.quiz_outlined,
                              size: 12,
                              color:
                                  quiz.quizType == QuizType.flashcard
                                      ? Colors.blue
                                      : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              quiz.quizType == QuizType.flashcard
                                  ? 'Flashcards'
                                  : 'Multiple Choice',
                              style: TextStyle(
                                color:
                                    quiz.quizType == QuizType.flashcard
                                        ? Colors.blue
                                        : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Status tag
                  if (hasDueItems)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$dueCount due',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isRecentlyReviewed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Up to date',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12), // Compact stats and actions
              Row(
                children: [
                  // Compact stats
                  Expanded(
                    flex: 3,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _buildCompactStat(
                          icon: Icons.quiz_outlined,
                          value: itemCount.toString(),
                          label: 'items',
                        ),
                        _buildCompactStat(
                          icon: Icons.update,
                          value: _formatDate(quiz.updatedAt),
                          label: '',
                        ),
                        _buildCompactStat(
                          icon: Icons.check_circle_outline,
                          value: accuracy,
                          label: '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action button
                  ElevatedButton(
                    onPressed: dueCount > 0 ? onReview : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dueCount > 0 
                          ? AppColors.athenaSupportiveGreen 
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: dueCount > 0 ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
