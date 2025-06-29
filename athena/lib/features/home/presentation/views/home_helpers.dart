import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/domain/enums/subject.dart';
import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:athena/features/shared/utils/subject_utils.dart';
import 'package:flutter/material.dart';

// Helper functions that can be used to display loading, error states and data for the HomeScreen

// Loading and error widgets
Widget buildLoadingStatCard(BuildContext context, String title) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 24,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget buildErrorStatCard(BuildContext context, String title) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.error_outline, color: Colors.red),
        ),
        const SizedBox(height: 12),
        const Text(
          '?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget buildLoadingCard({required double height}) {
  return Container(
    height: height,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
}

Widget buildErrorCard(String message) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 36),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(color: Colors.red)),
      ],
    ),
  );
}

// Session and review card builders
Widget buildUpcomingSessionsCard(
  BuildContext context,
  List<UpcomingSession> sessions,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.task_alt_rounded, color: AppColors.athenaBlue),
            const SizedBox(width: 8),
            const Text(
              'Upcoming Sessions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${sessions.length} today',
              style: TextStyle(
                color: AppColors.athenaBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No study sessions scheduled today',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...sessions.map((session) {
            IconData icon;
            switch (session.iconType) {
              case SessionIconType.science:
                icon = Icons.science_rounded;
                break;
              case SessionIconType.math:
                icon = Icons.calculate_rounded;
                break;
              case SessionIconType.history:
                icon = Icons.history_edu_rounded;
                break;
              case SessionIconType.literature:
                icon = Icons.menu_book_rounded;
                break;
              case SessionIconType.language:
                icon = Icons.translate_rounded;
                break;
              case SessionIconType.generic:
                icon = Icons.school_rounded;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildSessionItem(
                time: session.time,
                title: session.title,
                icon: icon,
              ),
            );
          }),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Navigate to planner
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Study Planner coming soon!')),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('View Full Schedule'),
        ),
      ],
    ),
  );
}

Widget buildReviewItemsCard(BuildContext context, List<ReviewItem> items) {
  final totalItemsCount = items.fold(0, (sum, item) => sum + item.count);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.loop_rounded, color: AppColors.athenaSupportiveGreen),
            const SizedBox(width: 8),
            Text(
              '$totalItemsCount items due for review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.athenaSupportiveGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No review items due today',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else if (items.length == 1)
          buildQuizDueCard(
            items.first.title,
            '${items.first.count} items',
            getColorForSubject(items.first.subject)[0],
            getColorForSubject(items.first.subject)[1],
          )
        else
          Row(
            children: [
              for (int i = 0; i < min(items.length, 2); i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == 0 && items.length > 1 ? 12 : 0,
                    ),
                    child: buildQuizDueCard(
                      items[i].title,
                      '${items[i].count} items',
                      getColorForSubject(items[i].subject)[0],
                      getColorForSubject(items[i].subject)[1],
                    ),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            // Navigate to review
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review System coming soon!')),
            );
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: AppColors.athenaSupportiveGreen),
            foregroundColor: AppColors.athenaSupportiveGreen,
          ),
          child: const Text('Start Review Session'),
        ),
      ],
    ),
  );
}

List<Color> getColorForSubject(Subject? subject) {
  final (Color color, IconData _) = SubjectUtils.getSubjectAttributes(subject);
  
  // If subject is null, SubjectUtils returns grey which is hard to see
  // Use a more pronounced grey for better visibility
  if (subject == null) {
    return [const Color(0xFF616161).withValues(alpha: 0.1), const Color(0xFF616161)]; // Darker grey for better contrast
  }
  
  return [color.withValues(alpha: 0.1), color];
}

int min(int a, int b) => a < b ? a : b;

Widget buildSessionItem({
  required String time,
  required String title,
  required IconData icon,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.athenaBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.athenaBlue, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    ],
  );
}

Widget buildQuizDueCard(
  String title,
  String count,
  Color bgColor,
  Color textColor,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
