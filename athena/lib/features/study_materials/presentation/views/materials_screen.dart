import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/presentation/views/material_detail_screen.dart';
import 'package:athena/features/study_materials/presentation/widgets/add_material_bottom_sheet.dart';
import 'package:athena/features/study_materials/presentation/widgets/material_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy data for UI scaffolding
    final materials = [
      StudyMaterialEntity(
        id: '1',
        userId: 'user1',
        title: 'Biology Notes - Chapter 4',
        description: 'Cell structure and function',
        subject: 'Biology',
        contentType: 'text',
        originalContentText: 'Content about cells',
        hasAiSummary: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      StudyMaterialEntity(
        id: '2',
        userId: 'user1',
        title: 'Math Formulas',
        description: 'Calculus reference sheet',
        subject: 'Mathematics',
        contentType: 'text',
        originalContentText: 'Calculus formulas',
        hasAiSummary: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      StudyMaterialEntity(
        id: '3',
        userId: 'user1',
        title: 'History Timeline',
        description: 'Important dates and events',
        subject: 'History',
        contentType: 'text',
        originalContentText: 'History timeline content',
        hasAiSummary: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];

    final subjects = ['All', 'Biology', 'Mathematics', 'History', 'Literature'];

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSubjectFilter(context, subjects),
          Expanded(
            child: materials.isEmpty
                ? _buildEmptyState(context)
                : _buildMaterialsList(context, materials),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.athenaPurple,
        foregroundColor: Colors.white,
        heroTag: 'materials_fab',
        child: const Icon(Icons.add),
        onPressed: () => _showAddMaterialDialog(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _buildSubjectFilter(BuildContext context, List<String> subjects) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = index == 0; // First tab (All) is selected by default

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
                color: isSelected ? AppColors.athenaPurple : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }

  Widget _buildMaterialsList(BuildContext context, List<StudyMaterialEntity> materials) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return MaterialListItemCard(
          material: material,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaterialDetailScreen(materialId: 'foo'),
              ),
            );
          },
          onSummarize: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('AI summarization coming soon!'),
              ),
            );
          },
          onQuiz: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quiz generation coming soon!'),
              ),
            );
          },
        );
      },
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
            onPressed: () => _showAddMaterialDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Material'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.athenaPurple,
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

  void _showAddMaterialDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddMaterialBottomSheet(),
    );
  }
}
