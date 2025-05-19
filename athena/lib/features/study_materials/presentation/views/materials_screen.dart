import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy data for UI scaffolding
    final materials = [
      StudyMaterial(
        id: '1',
        title: 'Biology Notes - Chapter 4',
        description: 'Cell structure and function',
        subject: 'Biology',
        dateAdded: DateTime.now().subtract(const Duration(days: 2)),
        hasAiSummary: true,
      ),
      StudyMaterial(
        id: '2',
        title: 'Math Formulas',
        description: 'Calculus reference sheet',
        subject: 'Mathematics',
        dateAdded: DateTime.now().subtract(const Duration(days: 5)),
        hasAiSummary: false,
      ),
      StudyMaterial(
        id: '3',
        title: 'History Timeline',
        description: 'Important dates and events',
        subject: 'History',
        dateAdded: DateTime.now().subtract(const Duration(days: 8)),
        hasAiSummary: true,
      ),
    ];

    final subjects = ['All', 'Biology', 'Mathematics', 'History', 'Literature'];

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        backgroundColor: AppColors.athenaPurple,
        title: const Text(
          'Study Materials',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon!'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter functionality coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject filter tabs
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final isSelected =
                    index == 0; // First tab (All) is selected by default

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: FilterChip(
                    label: Text(subject),
                    selected: isSelected,
                    showCheckmark: false,
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.athenaPurple.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? AppColors.athenaPurple : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    onSelected: (selected) {
                      // In real implementation, would filter by subject
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Filtering by $subject'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Material cards
          Expanded(
            child:
                materials.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        return _buildMaterialCard(context, material);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.athenaPurple,
        heroTag: 'materials_fab',
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddMaterialDialog(context);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No study materials yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first study material to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddMaterialDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Material'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.athenaBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, StudyMaterial material) {
    Color subjectColor;
    IconData subjectIcon;

    switch (material.subject) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Would navigate to material detail view
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material detail view coming soon!')),
          );
        },
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
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context: context,
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
                    child: _buildActionButton(
                      context: context,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.athenaPurple,
        side: BorderSide(color: AppColors.athenaPurple),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Study Material',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose how you want to add your study material:',
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildAddOption(
                      context: context,
                      icon: Icons.text_fields_rounded,
                      title: 'Type or Paste',
                      description: 'Enter text directly',
                      color: AppColors.athenaBlue,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Text entry coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAddOption(
                      context: context,
                      icon: Icons.file_upload_outlined,
                      title: 'Upload File',
                      description: 'PDF, Word, Text...',
                      color: AppColors.athenaPurple,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File upload coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAddOption(
                      context: context,
                      icon: Icons.camera_alt_outlined,
                      title: 'Take Photo',
                      description: 'Capture text with camera',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Camera functionality coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAddOption(
                      context: context,
                      icon: Icons.photo_library_outlined,
                      title: 'From Gallery',
                      description: 'Select from your photos',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gallery selection coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime dateAdded;
  final bool hasAiSummary;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dateAdded,
    required this.hasAiSummary,
  });
}
