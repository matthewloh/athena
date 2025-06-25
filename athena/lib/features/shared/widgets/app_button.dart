import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';

/// A reusable button component following Athena's design system.
/// 
/// This widget provides a consistent button look and feel throughout the app,
/// with support for common button features such as loading state, icons,
/// and various visual customizations.
class AppButton extends StatelessWidget {
  /// The text displayed on the button
  final String label;
  
  /// Callback function when the button is pressed
  final VoidCallback? onPressed;
  
  /// Optional icon to display before the label
  final Widget? icon;
  
  /// If true, displays a loading indicator instead of the label/icon
  final bool isLoading;
  
  /// Background color of the button (defaults to primary)
  final Color? backgroundColor;
  
  /// Text color of the button (defaults to white)
  final Color? textColor;
  
  /// Width of the button (null means it takes parent's width)
  final double? width;
  
  /// Height of the button (defaults to 48)
  final double height;
  
  /// Border radius of the button (defaults to 8)
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? Colors.white;
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          disabledForegroundColor: txtColor.withValues(alpha: 0.6),
          elevation: 0,
        ),
        child: _buildButtonContent(theme, txtColor),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme, Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon == null) {
      return Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
