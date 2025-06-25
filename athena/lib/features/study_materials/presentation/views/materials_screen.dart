import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/domain/enums/subject.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:athena/features/shared/utils/subject_utils.dart';
import 'package:athena/features/study_materials/presentation/widgets/add_material_bottom_sheet.dart';
import 'package:athena/features/study_materials/presentation/widgets/material_list_item_card.dart';
import 'package:athena/features/study_materials/presentation/viewmodel/study_material_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MaterialsScreen extends ConsumerStatefulWidget {
  const MaterialsScreen({super.key});

  @override
  ConsumerState<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends ConsumerState<MaterialsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    // Load materials when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studyMaterialViewModelProvider.notifier).loadMaterials();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyMaterialViewModelProvider);
    final viewModel = ref.read(studyMaterialViewModelProvider.notifier);
    final materials = state.filteredMaterials;
    final availableSubjects = state.availableSubjects;

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
      appBar: _buildAppBar(context, viewModel, state),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSearchBar ? null : 0,
            child:
                _showSearchBar
                    ? _buildSearchBar(context, viewModel, state)
                    : const SizedBox.shrink(),
          ),
          _buildSubjectFilter(context, availableSubjects, viewModel, state),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => viewModel.loadMaterials(),
              child:
                  state.isLoading && materials.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : materials.isEmpty
                      ? _buildEmptyState(context, state)
                      : Stack(
                        children: [
                          _buildMaterialsList(context, materials, viewModel),
                          if (state.isLoading)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 4,
                                child: const LinearProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
            ),
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

  AppBar _buildAppBar(BuildContext context, dynamic viewModel, dynamic state) {
    return AppBar(
      backgroundColor: AppColors.athenaPurple,
      title: const Text(
        'Study Materials',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(_showSearchBar ? Icons.search_off : Icons.search),
          onPressed: () {
            setState(() {
              _showSearchBar = !_showSearchBar;
              if (!_showSearchBar) {
                _searchController.clear();
                viewModel.setSearchQuery('');
              }
            });
          },
        ),
        if (state.hasFilters)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              viewModel.clearFilters();
              setState(() {
                _showSearchBar = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    dynamic viewModel,
    dynamic state,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search materials...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              state.searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.setSearchQuery('');
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (query) {
          viewModel.setSearchQuery(query);
        },
      ),
    );
  }

  Widget _buildSubjectFilter(
    BuildContext context,
    List<Subject> subjects,
    dynamic viewModel,
    dynamic state,
  ) {
    if (subjects.isEmpty) {
      return const SizedBox.shrink();
    }

    final allSubjects = [null, ...subjects]; // null represents "All"

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Filter status indicator
          if (state.hasFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.athenaPurple.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: AppColors.athenaPurple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Showing ${state.filteredMaterialsCount} of ${state.materialsCount} materials',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.athenaPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          // Subject filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: allSubjects.length,
              itemBuilder: (context, index) {
                final subject = allSubjects[index];
                final subjectName = subject == null ? 'All' : SubjectUtils.getDisplayName(subject);
                final isSelected = state.selectedSubject == subject;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: FilterChip(
                    label: Text(subjectName),
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
                      viewModel.setSubjectFilter(selected ? subject : null);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(
    BuildContext context,
    List<StudyMaterialEntity> materials,
    dynamic viewModel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return MaterialListItemCard(
          material: material,
          onTap: () {
            viewModel.selectMaterial(material.id);
            context.pushNamed(
              AppRouteNames.materialDetail,
              pathParameters: {'materialId': material.id},
            );
          },
          onSummarize: () {
            viewModel.generateAiSummary(material.id);
          },
          onQuiz: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Quiz generation coming soon!')),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic state) {
    // Check if it's empty due to filters vs. actually having no materials
    final hasFilters = state.hasFilters;
    final totalMaterials = state.materialsCount;

    if (hasFilters && totalMaterials > 0) {
      // Empty due to filters
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No materials match your filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                ref
                    .read(studyMaterialViewModelProvider.notifier)
                    .clearFilters();
                setState(() {
                  _showSearchBar = false;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Actually no materials
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
