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
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(hasText ? 'Add Text to Image' : 'Add Text Field'),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog to edit extracted text
  ///
  /// Returns the edited text if saved, null if cancelled
  static Future<String?> showEditTextDialog(
    BuildContext context,
    String originalText,
  ) async {
    // Create a new text editing controller for this dialog
    final dialogController = TextEditingController(text: originalText);

    // Show dialog to edit text
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (dialogContext) {
        // Local state for validation error - will be managed by the StatefulBuilder
        String? errorText;

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

            return WillPopScope(
              // Prevent Android back button from dismissing without explicit action
              onWillPop: () async => false,
              child: AlertDialog(
                title: const Text('Edit Extracted Text'),
                titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
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
                        TextField(
                          controller: dialogController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Edit text here...',
                            errorText: errorText,
                          ),
                          autofocus: true,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final text = dialogController.text.trim();
                      if (text.isEmpty) {
                        setDialogState(() {
                          errorText = 'Text cannot be empty';
                        });
                      } else {
                        Navigator.of(context).pop(text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
