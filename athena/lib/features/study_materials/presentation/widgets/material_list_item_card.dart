import 'package:athena/features/shared/utils/subject_utils.dart';
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
    final (subjectColor, subjectIcon) = SubjectUtils.getSubjectAttributes(
      material.subject,
    );

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

  Widget _buildHeader(
    Color subjectColor,
    IconData subjectIcon,
    StudyMaterialEntity material,
  ) {
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
                material.description ?? "No Description",
                style: TextStyle(color: Colors.grey[600]),
              ),              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
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
                      SubjectUtils.getDisplayName(material.subject),
                      style: TextStyle(
                        color: subjectColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getContentTypeIcon(material.contentType),
                          size: 12,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getContentTypeLabel(material.contentType),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (material.hasAiSummary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.athenaPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildCompactActionButton(
          icon: Icons.summarize_outlined,
          label: 'Summary',
          color: AppColors.athenaPurple,
          onPressed: onSummarize,
        ),
        const SizedBox(width: 8),
        _buildCompactActionButton(
          icon: Icons.quiz_outlined,
          label: 'Quiz',
          color: AppColors.athenaSupportiveGreen,
          onPressed: onQuiz,
        ),
      ],
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.75)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getContentTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.typedText:
        return Icons.text_fields_rounded;
      case ContentType.imageFile:
        return Icons.image_rounded;
      case ContentType.textFile:
        return Icons.description_rounded;
    }
  }

  String _getContentTypeLabel(ContentType type) {
    switch (type) {
      case ContentType.typedText:
        return 'Text';
      case ContentType.imageFile:
        return 'Image';
      case ContentType.textFile:
        return 'File';
    }
  }
}
