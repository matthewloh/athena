import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/create_quiz_state.dart';
import 'package:flutter/material.dart';

class QuizItemEditor extends StatefulWidget {
  final QuizItemData item;
  final int index;
  final ValueChanged<QuizItemData> onUpdate;
  final VoidCallback onRemove;
  final VoidCallback onToggleExpansion;
  final bool showValidationErrors;

  const QuizItemEditor({
    super.key,
    required this.item,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
    required this.onToggleExpansion,
    required this.showValidationErrors,
  });

  @override
  State<QuizItemEditor> createState() => _QuizItemEditorState();
}

class _QuizItemEditorState extends State<QuizItemEditor> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late List<TextEditingController> _mcqControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(text: widget.item.question);
    _answerController = TextEditingController(text: widget.item.answer);
    _mcqControllers =
        widget.item.mcqOptions
            .map((option) => TextEditingController(text: option))
            .toList();

    // Ensure we have at least 4 controllers for MCQ
    while (_mcqControllers.length < 4) {
      _mcqControllers.add(TextEditingController());
    }
  }

  @override
  void didUpdateWidget(QuizItemEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item != widget.item) {
      // Only update text if it's different to avoid cursor jumping
      if (_questionController.text != widget.item.question) {
        _questionController.text = widget.item.question;
      }
      if (_answerController.text != widget.item.answer) {
        _answerController.text = widget.item.answer;
      }

      // Update MCQ options if needed
      if (widget.item.type == QuizItemType.multipleChoice) {
        for (
          int i = 0;
          i < widget.item.mcqOptions.length && i < _mcqControllers.length;
          i++
        ) {
          if (_mcqControllers[i].text != widget.item.mcqOptions[i]) {
            _mcqControllers[i].text = widget.item.mcqOptions[i];
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _questionController.dispose();
    _answerController.dispose();
    for (final controller in _mcqControllers) {
      controller.dispose();
    }
  }

  void _updateItem({
    String? question,
    String? answer,
    QuizItemType? type,
    List<String>? mcqOptions,
    int? correctOptionIndex,
  }) {
    final updatedItem = widget.item.copyWith(
      question: question ?? widget.item.question,
      answer: answer ?? widget.item.answer,
      type: type ?? widget.item.type,
      mcqOptions: mcqOptions ?? widget.item.mcqOptions,
      correctOptionIndex: correctOptionIndex ?? widget.item.correctOptionIndex,
    );
    widget.onUpdate(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content (expandable)
          if (widget.item.isExpanded) _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hasErrors = widget.showValidationErrors && !widget.item.isValid;

    return InkWell(
      onTap: widget.onToggleExpansion,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Item number and type icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    hasErrors
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child:
                    hasErrors
                        ? Icon(
                          Icons.error,
                          size: 16,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        )
                        : Text(
                          '${widget.index + 1}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),

            // Type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    widget.item.type == QuizItemType.flashcard
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.item.type == QuizItemType.flashcard
                        ? Icons.flip_to_front
                        : Icons.quiz,
                    size: 14,
                    color:
                        widget.item.type == QuizItemType.flashcard
                            ? Colors.blue
                            : Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Preview text
            Expanded(
              child: Text(
                widget.item.question.isEmpty
                    ? 'Empty question'
                    : widget.item.question,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      widget.item.question.isEmpty
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                  fontStyle:
                      widget.item.question.isEmpty ? FontStyle.italic : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Validity indicator
            Icon(
              widget.item.isValid ? Icons.check_circle : Icons.error,
              color:
                  widget.item.isValid
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
              size: 20,
            ),

            // Expansion indicator
            Icon(
              widget.item.isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),

          // Type selector
          _buildTypeSelector(context),
          const SizedBox(height: 16),

          // Question field
          _buildQuestionField(context),
          const SizedBox(height: 16),

          // Answer/Options field
          if (widget.item.type == QuizItemType.flashcard)
            _buildAnswerField(context)
          else
            _buildMcqOptionsField(context),

          const SizedBox(height: 16),

          // Actions
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Type is now fixed based on quiz type - no longer user selectable
        Text(
          widget.item.type == QuizItemType.flashcard
              ? 'Flashcard Question'
              : 'Multiple Choice Question',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildQuestionField(BuildContext context) {
    return TextFormField(
      controller: _questionController,
      decoration: InputDecoration(
        labelText: 'Question *',
        hintText:
            widget.item.type == QuizItemType.flashcard
                ? 'Enter the term or question'
                : 'Enter the multiple choice question',
        errorText:
            widget.showValidationErrors ? widget.item.questionError : null,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.help_outline),
      ),
      onChanged: (value) => _updateItem(question: value),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildAnswerField(BuildContext context) {
    return TextFormField(
      controller: _answerController,
      decoration: InputDecoration(
        labelText: 'Answer *',
        hintText: 'Enter the definition or answer',
        errorText: widget.showValidationErrors ? widget.item.answerError : null,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lightbulb_outline),
      ),
      onChanged: (value) => _updateItem(answer: value),
      maxLines: 3,
      maxLength: 500,
    );
  }

  Widget _buildMcqOptionsField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer Options',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...List.generate(4, (index) {
          final isCorrect = index == widget.item.correctOptionIndex;
          final optionErrors = widget.item.mcqOptionErrors;
          final hasError =
              widget.showValidationErrors &&
              index < optionErrors.length &&
              optionErrors[index] != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                // Correct answer radio
                Radio<int>(
                  value: index,
                  groupValue: widget.item.correctOptionIndex,
                  onChanged: (value) => _updateItem(correctOptionIndex: value),
                ),

                // Option input
                Expanded(
                  child: TextFormField(
                    controller: _mcqControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}',
                      hintText: 'Enter option text',
                      errorText: hasError ? optionErrors[index] : null,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              isCorrect
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              isCorrect
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      prefixIcon: Icon(
                        isCorrect
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCorrect ? Colors.green : null,
                      ),
                    ),
                    onChanged: (value) {
                      final options =
                          _mcqControllers.map((c) => c.text).toList();
                      _updateItem(mcqOptions: options);
                    },
                    maxLength: 200,
                  ),
                ),
              ],
            ),
          );
        }),
        if (widget.showValidationErrors && widget.item.hasMcqErrors)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please fill at least 2 options and ensure the correct answer is selected',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        const Spacer(),

        TextButton.icon(
          onPressed: widget.onRemove,
          icon: const Icon(Icons.delete),
          label: const Text('Remove'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(width: 8),

        TextButton.icon(
          onPressed: widget.onToggleExpansion,
          icon: const Icon(Icons.keyboard_arrow_up, size: 18),
          label: const Text('Collapse'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
