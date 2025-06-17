import 'package:athena/features/study_materials/presentation/utils/subject_utils.dart';
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
  (Color, IconData) _getSubjectAttributes(Subject? subject) {
    if (subject == null) {
      return (Colors.grey, Icons.subject);
    }

    switch (subject) {
      // STEM & Technology
      case Subject.mathematics:
        return (Colors.blue, Icons.calculate_rounded);
      case Subject.physics:
        return (Colors.indigo, Icons.science_rounded);
      case Subject.chemistry:
        return (Colors.green, Icons.science_rounded);
      case Subject.biology:
        return (Colors.teal, Icons.biotech_rounded);
      case Subject.computerScience:
        return (Colors.deepPurple, Icons.computer_rounded);
      case Subject.engineering:
        return (Colors.orange, Icons.engineering_rounded);
      case Subject.statistics:
        return (Colors.blueGrey, Icons.bar_chart_rounded);
      case Subject.dataScience:
        return (Colors.cyan, Icons.analytics_rounded);
      case Subject.informationTechnology:
        return (Colors.purple, Icons.devices_rounded);
      case Subject.cybersecurity:
        return (Colors.red, Icons.security_rounded);

      // Languages & Literature
      case Subject.englishLiterature:
      case Subject.englishLanguage:
        return (Colors.purple, Icons.menu_book_rounded);
      case Subject.spanish:
      case Subject.french:
      case Subject.german:
      case Subject.chinese:
      case Subject.japanese:
        return (Colors.deepOrange, Icons.language_rounded);
      case Subject.linguistics:
        return (Colors.pink, Icons.translate_rounded);
      case Subject.creativeWriting:
        return (Colors.indigo, Icons.edit_rounded);

      // Social Sciences
      case Subject.history:
        return (Colors.amber.shade700, Icons.history_edu_rounded);
      case Subject.geography:
        return (Colors.green, Icons.map_rounded);
      case Subject.psychology:
        return (Colors.purple, Icons.psychology_rounded);
      case Subject.sociology:
        return (Colors.blue, Icons.groups_rounded);
      case Subject.politicalScience:
        return (Colors.red, Icons.account_balance_rounded);
      case Subject.economics:
        return (Colors.green, Icons.trending_up_rounded);
      case Subject.anthropology:
        return (Colors.brown, Icons.diversity_3_rounded);
      case Subject.internationalRelations:
        return (Colors.blue, Icons.public_rounded);
      case Subject.philosophy:
        return (Colors.grey, Icons.psychology_alt_rounded);
      case Subject.ethics:
        return (Colors.teal, Icons.gavel_rounded);

      // Business & Management
      case Subject.businessStudies:
        return (Colors.blue, Icons.business_rounded);
      case Subject.marketing:
        return (Colors.orange, Icons.campaign_rounded);
      case Subject.finance:
        return (Colors.green, Icons.attach_money_rounded);
      case Subject.accounting:
        return (Colors.teal, Icons.receipt_long_rounded);
      case Subject.management:
        return (Colors.purple, Icons.manage_accounts_rounded);
      case Subject.humanResources:
        return (Colors.pink, Icons.people_rounded);
      case Subject.operationsManagement:
        return (Colors.indigo, Icons.settings_rounded);
      case Subject.entrepreneurship:
        return (Colors.orange, Icons.lightbulb_rounded);

      // Arts & Creative
      case Subject.art:
        return (Colors.pink, Icons.palette_rounded);
      case Subject.music:
        return (Colors.purple, Icons.music_note_rounded);
      case Subject.drama:
        return (Colors.red, Icons.theater_comedy_rounded);
      case Subject.filmStudies:
        return (Colors.indigo, Icons.movie_rounded);
      case Subject.photography:
        return (Colors.grey, Icons.camera_alt_rounded);
      case Subject.graphicDesign:
        return (Colors.cyan, Icons.design_services_rounded);
      case Subject.architecture:
        return (Colors.brown, Icons.architecture_rounded);

      // Health & Medical
      case Subject.medicine:
        return (Colors.red, Icons.local_hospital_rounded);
      case Subject.nursing:
        return (Colors.pink, Icons.medical_services_rounded);
      case Subject.publicHealth:
        return (Colors.green, Icons.health_and_safety_rounded);
      case Subject.nutrition:
        return (Colors.orange, Icons.restaurant_rounded);
      case Subject.physicalEducation:
        return (Colors.blue, Icons.fitness_center_rounded);
      case Subject.sportsScience:
        return (Colors.indigo, Icons.sports_soccer_rounded);

      // Law & Legal Studies
      case Subject.law:
        return (Colors.brown, Icons.gavel_rounded);
      case Subject.criminalJustice:
        return (Colors.red, Icons.security_rounded);
      case Subject.legalStudies:
        return (Colors.grey, Icons.balance_rounded);

      // Environmental & Earth Sciences
      case Subject.environmentalScience:
        return (Colors.green, Icons.eco_rounded);
      case Subject.geology:
        return (Colors.brown, Icons.terrain_rounded);
      case Subject.climateScience:
        return (Colors.blue, Icons.cloud_rounded);
      case Subject.marineBiology:
        return (Colors.cyan, Icons.waves_rounded);

      // Education & Teaching
      case Subject.education:
        return (Colors.amber, Icons.school_rounded);
      case Subject.pedagogy:
        return (Colors.orange, Icons.school_rounded);
      case Subject.educationalPsychology:
        return (Colors.purple, Icons.psychology_rounded);

      // Default case
      case Subject.none:
        return (Colors.grey, Icons.subject);
    }
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
                      SubjectUtils.getDisplayName(material.subject),
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
                        color: AppColors.athenaPurple.withValues(alpha: 0.1),
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
                const SnackBar(content: Text('AI summarization coming soon!')),
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
                const SnackBar(content: Text('Quiz generation coming soon!')),
              );
            },
          ),
        ),
      ],
    );
  }
}
