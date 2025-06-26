import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/edit_quiz_state.dart';
import 'package:athena/features/review/presentation/viewmodel/edit_quiz_viewmodel.dart';
import 'package:athena/features/review/presentation/widgets/quiz_item_editor.dart';
import 'package:athena/features/review/presentation/widgets/study_material_selector.dart';
import 'package:athena/features/shared/widgets/subject_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditQuizScreen extends ConsumerStatefulWidget {
  final String quizId;

  const EditQuizScreen({super.key, required this.quizId});

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final viewModel = ref.read(editQuizViewModelProvider(widget.quizId).notifier);
    
    if (!viewModel.hasUnsavedChanges()) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editQuizViewModelProvider(widget.quizId));
    final viewModel = ref.read(editQuizViewModelProvider(widget.quizId).notifier);

    // Listen for success state
    ref.listen<EditQuizState>(editQuizViewModelProvider(widget.quizId), (previous, next) {
      if (next.isSuccess && next.updatedQuiz != null) {
        _showSuccessDialog(context, next.updatedQuiz!.title);
      }

      if (next.hasError && next.error != null) {
        _showErrorSnackBar(context, next.error!);
      }
    });

    // Update controllers when state changes
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
    }
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.description;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            state.hasOriginalQuiz ? 'Edit Quiz' : 'Loading...',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                context.pop();
              }
            },
          ),
          actions: [
            if (state.hasOriginalQuiz && !state.hasAnyLoading)
              TextButton(
                onPressed: state.hasActualChanges && state.isFormValid
                    ? () => viewModel.updateQuiz()
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.athenaSupportiveGreen,
                  backgroundColor: state.hasActualChanges && state.isFormValid
                      ? AppColors.athenaSupportiveGreen.withOpacity(0.1)
                      : null,
                ),
                child: state.isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.athenaSupportiveGreen,
                        ),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
        body: _buildBody(context, state, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, EditQuizState state, EditQuizViewModel viewModel) {
    if (state.hasError && !state.hasOriginalQuiz) {
      return _buildErrorState(context, state.error!, viewModel);
    }

    if (state.isLoadingQuizData && !state.hasOriginalQuiz) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.athenaSupportiveGreen,
        ),
      );
    }

    if (!state.hasOriginalQuiz) {
      return const Center(
        child: Text(
          'Quiz not found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuizTypeInfo(state),
                const SizedBox(height: 16),
                _buildBasicInfoCard(state, viewModel),
                const SizedBox(height: 16),
                _buildStudyMaterialCard(state, viewModel),
                const SizedBox(height: 16),
                _buildQuizItemsHeader(state, viewModel),
                const SizedBox(height: 8),
              ]),
            ),
          ),
          _buildQuizItemsList(state, viewModel),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, EditQuizViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.reset(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaSupportiveGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeInfo(EditQuizState state) {
    final quizType = state.originalQuiz!.quizType;
    final icon = quizType == QuizType.flashcard ? Icons.auto_awesome : Icons.quiz;
    final label = quizType == QuizType.flashcard ? 'Flashcard Quiz' : 'Multiple Choice Quiz';
    final description = quizType == QuizType.flashcard
        ? 'Question and answer format for memorization'
        : 'Multiple choice questions with selectable options';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.athenaSupportiveGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.athenaSupportiveGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(EditQuizState state, EditQuizViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.athenaSupportiveGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Basic Information',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Quiz Title *',
                hintText: 'Enter a descriptive title for your quiz',
                prefixIcon: const Icon(Icons.title),
                errorText: state.titleError,
                border: const OutlineInputBorder(),
              ),
              onChanged: viewModel.updateTitle,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add a description for your quiz',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              onChanged: viewModel.updateDescription,
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            SubjectSearchableDropdown(
              selectedSubject: state.selectedSubject,
              onChanged: viewModel.updateSubject,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyMaterialCard(EditQuizState state, EditQuizViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.library_books,
                  color: AppColors.athenaSupportiveGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Study Material',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Link this quiz to study material for better organization',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            StudyMaterialSelector(
              selectedMaterialId: state.selectedStudyMaterialId,
              availableMaterials: state.availableStudyMaterials,
              onChanged: viewModel.updateStudyMaterial,
              isLoading: state.isLoadingStudyMaterials,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizItemsHeader(EditQuizState state, EditQuizViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Items (${state.quizItems.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              if (state.quizItemsError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    state.quizItemsError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (state.canAddMoreItems)
          TextButton.icon(
            onPressed: viewModel.addQuizItem,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Item'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildQuizItemsList(EditQuizState state, EditQuizViewModel viewModel) {
    if (state.quizItems.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No quiz items yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first quiz item to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: viewModel.addQuizItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Quiz Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.athenaSupportiveGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = state.quizItems[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuizItemEditor(
                item: item,
                index: index,
                onUpdate: (updatedItem) => viewModel.updateQuizItem(item.id, updatedItem),
                onRemove: () => viewModel.removeQuizItem(item.id),
                onToggleExpansion: () => viewModel.toggleQuizItemExpansion(item.id),
                showValidationErrors: state.showValidationErrors,
              ),
            );
          },
          childCount: state.quizItems.length,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String quizTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.athenaSupportiveGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.athenaSupportiveGreen,
            size: 32,
          ),
        ),
        title: const Text('Quiz Updated!'),
        content: Text(
          'Your quiz "$quizTitle" has been successfully updated.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final viewModel = ref.read(editQuizViewModelProvider(widget.quizId).notifier);
              viewModel.clearSuccess();
              context.pop(); // Close dialog
              context.pop(); // Go back to quiz detail
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.athenaSupportiveGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
