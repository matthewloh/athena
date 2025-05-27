import 'package:athena/features/study_materials/presentation/widgets/material_action_button.dart';
import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';

class MaterialListItemCard extends StatelessWidget {
  final StudyMaterialEntity material;
  final VoidCallback onTap;
  final VoidCallback onSummarize;
  final VoidCallback onQuiz;

  const MaterialListItemCard({
    super.key,
    required this.material,
    required this.onTap,
    required this.onSummarize,
    required this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final (subjectColor, subjectIcon) = _getSubjectAttributes(material.subject);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(subjectColor, subjectIcon, material),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: Temporary hardcoded subject attributes
  (Color, IconData) _getSubjectAttributes(String subject) {
    Color subjectColor;
    IconData subjectIcon;

    switch (subject) {
      case 'Biology':
        subjectColor = Colors.green;
        subjectIcon = Icons.science_rounded;
        break;
      case 'Mathematics':
        subjectColor = Colors.blue;
        subjectIcon = Icons.calculate_rounded;
        break;
      case 'History':
        subjectColor = Colors.amber[700]!;
        subjectIcon = Icons.history_edu_rounded;
        break;
      case 'Literature':
        subjectColor = Colors.purple;
        subjectIcon = Icons.menu_book_rounded;
        break;
      default:
        subjectColor = Colors.grey;
        subjectIcon = Icons.subject;
    }

    return (subjectColor, subjectIcon);
  }

  Widget _buildHeader(Color subjectColor, IconData subjectIcon, StudyMaterialEntity material) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: subjectColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(subjectIcon, color: subjectColor, size: 24),
        ),
        const SizedBox(width: 16),
        // Title and description
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                material.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      material.subject,
                      style: TextStyle(
                        color: subjectColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (material.hasAiSummary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.athenaPurple.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: AppColors.athenaPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Summary',
                            style: TextStyle(
                              color: AppColors.athenaPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MaterialActionButton(
            icon: Icons.summarize_outlined,
            label: 'Summarize',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI summarization coming soon!'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MaterialActionButton(
            icon: Icons.quiz_outlined,
            label: 'Quiz Me',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quiz generation coming soon!'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}