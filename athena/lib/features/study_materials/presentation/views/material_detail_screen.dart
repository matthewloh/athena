import 'package:athena/features/study_materials/presentation/utils/subject_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_viewmodel.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_state.dart';
import 'package:go_router/go_router.dart';

class MaterialDetailScreen extends ConsumerStatefulWidget {
  final String materialId;

  const MaterialDetailScreen({Key? key, required this.materialId})
    : super(key: key);

  @override
  ConsumerState<MaterialDetailScreen> createState() =>
      _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends ConsumerState<MaterialDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyMaterialViewModelProvider);
    final viewModel = ref.read(studyMaterialViewModelProvider.notifier);

    // Load material if not already loaded
    final material = state.getMaterialById(widget.materialId);

    if (material == null) {
      // Try to load the material
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadMaterial(widget.materialId);
      });

      return Scaffold(
        backgroundColor: AppColors.athenaOffWhite,
        appBar: AppBar(
          backgroundColor: AppColors.athenaPurple,
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if any
    if (state.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () => viewModel.clearError(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: _buildAppBar(context, material, viewModel),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOriginalContentTab(material),
                _buildSummaryTab(material, state, viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleEditMaterial(StudyMaterialEntity material) {
    // Navigate to edit screen with the current material's ID
    context.pushNamed(
      AppRouteNames.addEditMaterial,
      queryParameters: {'materialId': material.id},
    );
  }

  void _handleDeleteMaterial(StudyMaterialEntity material, dynamic viewModel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Material'),
            content: const Text(
              'Are you sure you want to delete this study material? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  viewModel.deleteMaterial(material.id);
                  context.pop(); // Close the dialog
                  context.pop(); // Return to the materials list
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    StudyMaterialEntity material,
    dynamic viewModel,
  ) {
    return AppBar(
      backgroundColor: AppColors.athenaPurple,
      title: Text(
        material.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _handleEditMaterial(material),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _handleDeleteMaterial(material, viewModel),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: AppColors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [Tab(text: 'Original Content'), Tab(text: 'AI Summary')],
      ),
    );
  }

  Widget _buildOriginalContentTab(StudyMaterialEntity material) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material title
          Text(
            material.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Material metadata
          Text(
            material.subject == null ? 'No subject' : SubjectUtils.getDisplayName(material.subject),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.athenaPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            material.description ?? 'No description available',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 16),

          // Material content
          material.contentType == ContentType.typedText
              ? Text(
                material.originalContentText ?? 'No content available',
                style: Theme.of(context).textTheme.bodyLarge,
              )
              : material.contentType == ContentType.imageFile
              ? const Center(
                child: Text('Image note preview would appear here'),
              )
              : const Center(child: Text('File content would appear here')),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(
    StudyMaterialEntity material,
    dynamic state,
    dynamic viewModel,
  ) {
    final hasSummary =
        material.summaryText != null && material.summaryText!.isNotEmpty;
    final isGeneratingSummary = state.isGeneratingSummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material title
          Text(
            material.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary content or loading state
          isGeneratingSummary
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating summary...'),
                  ],
                ),
              )
              : hasSummary
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI-Generated Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material.summaryText!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No summary available yet'),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        viewModel.generateAiSummary(material.id);
                        // Navigate to summary tab after starting generation
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _tabController.animateTo(1);
                        });
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Summary'),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
