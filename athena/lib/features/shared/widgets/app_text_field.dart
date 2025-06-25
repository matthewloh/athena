import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';

/// A reusable text field component following Athena's design system.
///
/// This widget provides a consistent text input look and feel throughout the app,
/// with support for validation, multi-line input, and various customization options.
class AppTextField extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController? controller;
  
  /// Label text displayed above the input
  final String? labelText;
  
  /// Hint text displayed inside the input when empty
  final String? hintText;
  
  /// Optional validation function that returns error message or null
  final String? Function(String?)? validator;
  
  /// If true, the field will be obscured (for passwords)
  final bool obscureText;
  
  /// The keyboard type to use for editing the text
  final TextInputType keyboardType;
  
  /// If non-null, the field is displayed with the specified number of lines
  final int? maxLines;
  
  /// Maximum number of characters allowed
  final int? maxLength;
  
  /// Called when the text is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// Called when the text changes
  final ValueChanged<String>? onChanged;
  
  /// Optional suffix icon
  final Widget? suffixIcon;
  
  /// Optional prefix icon
  final Widget? prefixIcon;
  
  /// If true, the field is read-only
  final bool readOnly;
  
  /// Focus node for the text field
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.onSubmitted,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.athenaDarkGrey,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          readOnly: readOnly,
          focusNode: focusNode,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.athenaDarkGrey,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.athenaMediumGrey,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: AppColors.white,
            errorStyle: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
