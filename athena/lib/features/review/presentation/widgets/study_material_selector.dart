import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
import 'package:flutter/material.dart';

class StudyMaterialSelector extends StatelessWidget {
  final String? selectedMaterialId;
  final List<StudyMaterialOption> availableMaterials;
  final bool isLoading;
  final ValueChanged<String?> onChanged;
  final String? errorText;

  const StudyMaterialSelector({
    super.key,
    required this.selectedMaterialId,
    required this.availableMaterials,
    required this.isLoading,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading study materials...'),
            ],
          ),
        ),
      );
    }

    if (availableMaterials.isEmpty) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                'No study materials available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedMaterialId,
          decoration: InputDecoration(
            labelText: 'Select Study Material *',
            hintText: 'Choose material for AI question generation',
            errorText: errorText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.library_books),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Select a study material...'),
            ),
            ...availableMaterials.map((material) {
              return DropdownMenuItem<String>(
                value: material.id,
                child: _buildMaterialItem(context, material),
              );
            }),
          ],
          onChanged: onChanged,
          isExpanded: true,
        ),
        if (selectedMaterialId != null) ...[
          const SizedBox(height: 8),
          _buildSelectedMaterialInfo(context),
        ],
      ],
    );
  }

  Widget _buildMaterialItem(
    BuildContext context,
    StudyMaterialOption material,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                material.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              if (material.subject != null) ...[
                const SizedBox(height: 2),
                Text(
                  _getSubjectDisplayName(material.subject!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            material.contentType,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedMaterialInfo(BuildContext context) {
    final selectedMaterial =
        availableMaterials
            .where((material) => material.id == selectedMaterialId)
            .firstOrNull;

    if (selectedMaterial == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected: ${selectedMaterial.title}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (selectedMaterial.subject != null)
                  Text(
                    _getSubjectDisplayName(selectedMaterial.subject!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onChanged(null),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  String _getSubjectDisplayName(subject) {
    // Simple implementation - you can expand this based on your Subject enum
    return subject
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim();
  }
}
