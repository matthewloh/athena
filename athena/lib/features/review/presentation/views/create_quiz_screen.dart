import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_viewmodel.dart';
import 'package:athena/features/review/presentation/widgets/quiz_item_editor.dart';
import 'package:athena/features/review/presentation/widgets/study_material_selector.dart';
import 'package:athena/features/shared/widgets/subject_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  final String? studyMaterialId;
  final String? initialMode;

  const CreateQuizScreen({super.key, this.studyMaterialId, this.initialMode});

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Parse initial mode from string
      CreateQuizMode? initialMode;
      if (widget.initialMode == 'manual') {
        initialMode = CreateQuizMode.manual;
      } else if (widget.initialMode == 'ai') {
        initialMode = CreateQuizMode.aiGenerated;
      }

      ref
          .read(createQuizViewModelProvider.notifier)
          .initialize(
            studyMaterialId: widget.studyMaterialId,
            initialMode: initialMode,
          );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createQuizViewModelProvider);
    final viewModel = ref.read(createQuizViewModelProvider.notifier);

    // Listen for success state
    ref.listen<CreateQuizState>(createQuizViewModelProvider, (previous, next) {
      if (next.isSuccess && next.createdQuiz != null) {
        _showSuccessDialog(context, next.createdQuiz!.title);
      }
      if (next.error != null) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        elevation: 0,
        backgroundColor: AppColors.athenaSupportiveGreen,
        foregroundColor: AppColors.athenaOffWhite,
        actions: [
          if (state.hasAnyLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quiz Mode Selection
                    _buildModeSelector(state, viewModel),
                    const SizedBox(height: 16),

                    // Quiz Type Selection
                    _buildQuizTypeSelector(state, viewModel),
                    const SizedBox(height: 24),

                    // Basic Information Card
                    _buildBasicInfoCard(state, viewModel),
                    const SizedBox(height: 16),

                    // Study Material Selection (for AI mode)
                    if (state.mode == CreateQuizMode.aiGenerated) ...[
                      _buildStudyMaterialCard(state, viewModel),
                      const SizedBox(height: 16),
                    ],

                    // AI Generation Section
                    if (state.mode == CreateQuizMode.aiGenerated)
                      _buildAiGenerationCard(state, viewModel),

                    // Manual Quiz Items Section
                    if (state.mode == CreateQuizMode.manual) ...[
                      _buildQuizItemsHeader(state, viewModel),
                    ],
                  ],
                ),
              ),
            ),

            // Quiz Items List (for manual mode)
            if (state.mode == CreateQuizMode.manual)
              _buildQuizItemsList(state, viewModel),

            // Generated Items Preview (for AI mode)
            if (state.mode == CreateQuizMode.aiGenerated &&
                state.quizItems.isNotEmpty)
              _buildGeneratedItemsPreview(state, viewModel),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(state, viewModel),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildModeSelector(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Creation Mode',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<CreateQuizMode>(
                    title: const Text('Manual'),
                    subtitle: const Text('Create questions yourself'),
                    value: CreateQuizMode.manual,
                    groupValue: state.mode,
                    onChanged: (mode) => viewModel.updateMode(mode!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<CreateQuizMode>(
                    title: const Text('AI Generated'),
                    subtitle: const Text('Generate from study material'),
                    value: CreateQuizMode.aiGenerated,
                    groupValue: state.mode,
                    onChanged: (mode) => viewModel.updateMode(mode!),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizTypeSelector(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the type of questions for this quiz. All questions must be of the same type.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<QuizType>(
                    title: const Text('Flashcards'),
                    subtitle: const Text('Question and answer format'),
                    value: QuizType.flashcard,
                    groupValue: state.selectedQuizType,
                    onChanged:
                        (type) =>
                            type != null
                                ? viewModel.updateQuizType(type)
                                : null,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<QuizType>(
                    title: const Text('Multiple Choice'),
                    subtitle: const Text('Questions with multiple options'),
                    value: QuizType.multipleChoice,
                    groupValue: state.selectedQuizType,
                    onChanged:
                        (type) =>
                            type != null
                                ? viewModel.updateQuizType(type)
                                : null,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Quiz Title *',
                hintText: 'Enter a descriptive title for your quiz',
                errorText: state.titleError,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              onChanged: viewModel.updateTitle,
              maxLength: 100,
            ),
            const SizedBox(height: 16), // Subject Dropdown
            SubjectSearchableDropdown(
              selectedSubject: state.selectedSubject,
              onChanged: viewModel.updateSubject,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add notes or context about this quiz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              onChanged: viewModel.updateDescription,
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyMaterialCard(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Material',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StudyMaterialSelector(
              selectedMaterialId: state.selectedStudyMaterialId,
              availableMaterials: state.availableStudyMaterials,
              isLoading: state.isLoadingStudyMaterials,
              onChanged: viewModel.updateStudyMaterial,
              errorText: state.studyMaterialError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiGenerationCard(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Question Generation',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (state.quizItems.isEmpty) ...[
              Text(
                'Select a study material and click generate to create questions automatically.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.athenaSupportiveGreen,
                  ),
                  onPressed:
                      state.selectedStudyMaterialId != null &&
                              !state.isGeneratingAi
                          ? () => viewModel.generateAiQuestions()
                          : null,
                  icon:
                      state.isGeneratingAi
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.auto_awesome),
                  label: Text(
                    state.isGeneratingAi
                        ? 'Generating...'
                        : 'Generate Questions',
                  ),
                ),
              ),
            ] else ...[
              Text(
                '${state.quizItems.length} questions generated. Review and regenerate if needed.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),

              TextButton.icon(
                onPressed:
                    !state.isGeneratingAi
                        ? () => viewModel.generateAiQuestions()
                        : null,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Regenerate'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuizItemsHeader(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Quiz Items (${state.quizItems.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildQuizItemsList(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    if (state.quizItems.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quiz items yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add flashcards or multiple choice questions to get started.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: viewModel.addQuizItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.athenaSupportiveGreen,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Item'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = state.quizItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: QuizItemEditor(
              item: item,
              index: index,
              onUpdate:
                  (updatedItem) =>
                      viewModel.updateQuizItem(item.id, updatedItem),
              onRemove: () => viewModel.removeQuizItem(item.id),
              onToggleExpansion:
                  () => viewModel.toggleQuizItemExpansion(item.id),
              showValidationErrors: state.showValidationErrors,
            ),
          );
        }, childCount: state.quizItems.length),
      ),
    );
  }

  Widget _buildGeneratedItemsPreview(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverToBoxAdapter(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Questions (${state.quizItems.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...state.quizItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildQuizItemPreview(item),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizItemPreview(QuizItemData item) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.type == QuizItemType.flashcard
                    ? Icons.flip_to_front
                    : Icons.quiz,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                item.type == QuizItemType.flashcard
                    ? 'Flashcard'
                    : 'Multiple Choice',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.question,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (item.type == QuizItemType.flashcard) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Text(
                item.answer,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ] else if (item.type == QuizItemType.multipleChoice) ...[
            ...item.mcqOptions.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrect = index == item.correctOptionIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isCorrect
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            color:
                                isCorrect
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: isCorrect ? FontWeight.w500 : null,
                          color:
                              isCorrect
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    CreateQuizState state,
    CreateQuizViewModel viewModel,
  ) {
    if (state.mode == CreateQuizMode.aiGenerated && state.quizItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed:
          state.isFormValid && !state.hasAnyLoading
              ? viewModel.createQuiz
              : null,
      icon:
          state.isCreating
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.save),
      label: Text(state.isCreating ? 'Creating...' : 'Create Quiz'),
      backgroundColor:
          state.isFormValid
              ? AppColors.athenaSupportiveGreen
              : Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  void _showSuccessDialog(BuildContext context, String quizTitle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Quiz Created!'),
            content: Text(
              'Your quiz "$quizTitle" has been created successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.pop(); // Go back to previous screen
                },
                child: const Text('Done'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.athenaSupportiveGreen,
                ),
                onPressed: () {
                  context.pop(); // Close dialog
                  ref.read(createQuizViewModelProvider.notifier).reset();
                },
                child: const Text('Create Another'),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed:
              () =>
                  ref.read(createQuizViewModelProvider.notifier).clearErrors(),
        ),
      ),
    );
  }
}
