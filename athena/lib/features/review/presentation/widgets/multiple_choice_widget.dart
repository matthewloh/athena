import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget for displaying multiple choice questions during review sessions.
///
/// This widget provides an interactive interface for multiple choice questions where users can:
/// - View the question
/// - Select from available options
/// - See the correct answer after selection
/// - Receive visual feedback on their choice
class MultipleChoiceWidget extends StatelessWidget {
  /// The question text to display
  final String question;

  /// List of answer options as key-value pairs (A: "Option text", B: "Option text", etc.)
  final List<MapEntry<String, String>> options;

  /// Currently selected option (null if none selected)
  final String? selectedOption;

  /// The correct answer option
  final String? correctOption;

  /// Whether to show the correct answer (after user has selected)
  final bool showCorrectAnswer;

  /// Callback when an option is selected
  final Function(String) onOptionSelected;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.options,
    this.selectedOption,
    this.correctOption,
    required this.showCorrectAnswer,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Validate MCQ configuration
    if (options.isEmpty) {
      return _buildErrorWidget(
        'No options provided for multiple choice question',
      );
    }

    if (options.length < 2) {
      return _buildErrorWidget(
        'Multiple choice question must have at least 2 options',
      );
    }

    if (options.length > 4) {
      return _buildErrorWidget(
        'Multiple choice question cannot have more than 4 options',
      );
    }

    // Validate option keys (should be A, B, C, D in order)
    final expectedKeys = ['A', 'B', 'C', 'D'].take(options.length).toList();
    final actualKeys = options.map((e) => e.key).toList();

    if (!_listsEqual(actualKeys, expectedKeys)) {
      debugPrint(
        'Warning: MCQ option keys mismatch. Expected: $expectedKeys, Got: $actualKeys',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question card
        _buildQuestionCard(context),

        const SizedBox(height: 24),

        // Options
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(context, option, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.athenaBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              color: AppColors.athenaBlue,
              size: 24,
            ),
          ),

          const SizedBox(height: 16),

          // Question text
          Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          if (showCorrectAnswer) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.athenaSupportiveGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.athenaSupportiveGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Answer revealed',
                    style: TextStyle(
                      color: AppColors.athenaSupportiveGreen,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    MapEntry<String, String> option,
    int index,
  ) {
    final optionKey = option.key;
    final optionText = option.value;
    final isSelected = selectedOption == optionKey;
    final isCorrect = correctOption == optionKey;
    final showFeedback = showCorrectAnswer && selectedOption != null;

    // Determine the visual state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    Color? iconColor;

    if (showFeedback) {
      if (isCorrect) {
        // Correct answer
        backgroundColor = AppColors.athenaSupportiveGreen.withOpacity(0.1);
        borderColor = AppColors.athenaSupportiveGreen;
        textColor = AppColors.athenaSupportiveGreen;
        icon = Icons.check_circle;
        iconColor = AppColors.athenaSupportiveGreen;
      } else if (isSelected) {
        // Wrong answer that was selected
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
        icon = Icons.cancel;
        iconColor = Colors.red;
      } else {
        // Other options
        backgroundColor = Colors.grey.withOpacity(0.05);
        borderColor = Colors.grey.withOpacity(0.3);
        textColor = Colors.grey[600]!;
      }
    } else if (isSelected) {
      // Selected but answer not revealed yet
      backgroundColor = AppColors.athenaBlue.withOpacity(0.1);
      borderColor = AppColors.athenaBlue;
      textColor = AppColors.athenaBlue;
      icon = Icons.radio_button_checked;
      iconColor = AppColors.athenaBlue;
    } else {
      // Not selected
      backgroundColor = Colors.white;
      borderColor = Colors.grey.withOpacity(0.3);
      textColor = Colors.black87;
      icon = Icons.radio_button_unchecked;
      iconColor = Colors.grey[600];
    }

    return GestureDetector(
      onTap: showFeedback ? null : () => onOptionSelected(optionKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow:
              isSelected && !showFeedback
                  ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            // Option letter
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionKey, // Use the actual option key (A, B, C, D)
                  style: TextStyle(
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Option text
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Status icon
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: iconColor, size: 24),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds an error widget for invalid MCQ configurations
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 48),
          const SizedBox(height: 16),
          Text(
            'Invalid MCQ Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  /// Helper method to compare two lists for equality
  bool _listsEqual<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
