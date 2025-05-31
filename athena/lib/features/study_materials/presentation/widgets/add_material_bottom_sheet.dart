import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/presentation/views/add_edit_material_screen.dart';
import 'package:flutter/material.dart';

class AddMaterialBottomSheet extends StatelessWidget {
  const AddMaterialBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditMaterialScreen(initialContentType: ContentType.typedText),
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
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditMaterialScreen(initialContentType: ContentType.textFile),
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
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditMaterialScreen(initialContentType: ContentType.imageFile),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditMaterialScreen(initialContentType: ContentType.imageFile),
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