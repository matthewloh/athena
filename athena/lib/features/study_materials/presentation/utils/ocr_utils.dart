import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:athena/core/theme/app_colors.dart';

/// Utility class to handle OCR (Optical Character Recognition) operations
class OcrUtils {
  /// Process image with OCR and extract text from it
  ///
  /// Returns the extracted text if successful, null otherwise
  static Future<String?> processImageWithOCR(File imageFile) async {
    // Check if file exists to avoid crashes
    if (!await imageFile.exists()) {
      debugPrint('Image file does not exist for OCR');
      return null;
    }

    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      String extractedText = '';

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );
        extractedText = recognizedText.text;
      } catch (e) {
        debugPrint('Error recognizing text: $e');
        return null;
      } finally {
        textRecognizer.close();
      }

      return extractedText;
    } catch (e) {
      debugPrint('Error in OCR processing: $e');
      return null;
    }
  }

  /// Show a dialog to confirm adding extracted text
  ///
  /// Returns true if user chooses to add the text, false otherwise
  static Future<bool?> showOcrResultDialog(
    BuildContext context,
    String? extractedText,
  ) async {
    final bool hasText = extractedText != null && extractedText.isNotEmpty;

    // Calculate available height for the dialog
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final keyboardVisible = keyboardHeight > 0;

    // Calculate available height with more space when keyboard is visible
    final availableHeight =
        screenHeight - keyboardHeight - (keyboardVisible ? 150 : 200);

    return showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow tapping outside to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(hasText ? 'Text Detected' : 'No Text Detected'),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  availableHeight > 100
                      ? availableHeight
                      : 300, // Ensure minimum height
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasText
                        ? 'The following text was detected in the image:'
                        : 'No text could be detected in the image. You can still add a blank text field to enter notes manually.',
                  ),
                  if (hasText) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(extractedText),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Ensure the dialog resizes when keyboard appears
          scrollable: true,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w500),
              ),
              child: Text(hasText ? 'ADD' : 'ADD TEXT FIELD'),
            ),
          ],
        );
      },
    );
  }

  /// Show an enhanced dialog to edit extracted text
  ///
  /// Returns the edited text if saved, null if cancelled
  static Future<String?> showEditTextDialog(
    BuildContext context,
    String originalText,
  ) async {
    // Create a new text editing controller for this dialog
    final dialogController = TextEditingController(text: originalText);
    final FocusNode focusNode = FocusNode();

    // After dialog appears, focus the text field and select all text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      dialogController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: dialogController.text.length,
      );
    });

    // Show dialog to edit text with improved UX
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (dialogContext) {
        // Local state for validation error - will be managed by the StatefulBuilder
        String? errorText;
        bool hasEdited = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            // Calculate available height for the dialog
            final mediaQuery = MediaQuery.of(context);
            final screenHeight = mediaQuery.size.height;
            final keyboardHeight = mediaQuery.viewInsets.bottom;
            final keyboardVisible = keyboardHeight > 0;

            // Calculate available height with more space when keyboard is visible
            final availableHeight =
                screenHeight - keyboardHeight - (keyboardVisible ? 150 : 250);

            return PopScope(
              // Prevent Android back button from dismissing without explicit action
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;

                final navigator = Navigator.of(context);

                // If user made changes, ask for confirmation
                if (hasEdited) {
                  final shouldDiscard = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text(
                            'Discard changes?',
                            style: TextStyle(color: Colors.black87),
                          ),
                          content: const Text(
                            'You have unsaved changes. Are you sure you want to discard them?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('KEEP EDITING'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('DISCARD'),
                            ),
                          ],
                        ),
                  );
                  if (shouldDiscard == true) {
                    navigator.pop();
                  }
                } else {
                  navigator.pop();
                }
              },
              child: AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit OCR Text',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors
                                .black87, // Explicitly set color for visibility
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Correct any inaccuracies in the extracted text',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: availableHeight > 100 ? availableHeight : 200,
                    // Add minimum width to ensure text field has enough space
                    minWidth: 280,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  focusNode.hasFocus
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                              width: focusNode.hasFocus ? 2.0 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            // Add shadow when focused
                            boxShadow:
                                focusNode.hasFocus
                                    ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: TextField(
                            controller: dialogController,
                            focusNode: focusNode,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Edit text here...',
                              errorText: errorText,
                              contentPadding: const EdgeInsets.all(16),
                              border: InputBorder.none,
                            ),
                            autofocus: true,
                            onChanged: (value) {
                              if (value != originalText && !hasEdited) {
                                setDialogState(() {
                                  hasEdited = true;
                                });
                              }
                            },
                          ),
                        ),
                        // Character count indicator
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${dialogController.text.length} characters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // Action buttons - more compact and subtle
                  TextButton(
                    onPressed: () {
                      if (hasEdited) {
                        showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text(
                                  'Discard changes?',
                                  style: TextStyle(color: Colors.black87),
                                ),
                                content: const Text(
                                  'You have made changes to the text. Are you sure you want to discard them?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Keep Editing'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      Navigator.of(dialogContext).pop(null);
                                    },
                                    child: const Text('Discard'),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        Navigator.of(dialogContext).pop(null);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      minimumSize: const Size(60, 36),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final text = dialogController.text.trim();
                      if (text.isEmpty) {
                        setDialogState(() {
                          errorText = 'Text cannot be empty';
                        });
                      } else {
                        Navigator.of(dialogContext).pop(text);
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(60, 36),
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    child: const Text('Save'),
                  ),
                ],
                scrollable: true,
              ),
            );
          },
        );
      },
    );
  }
}
