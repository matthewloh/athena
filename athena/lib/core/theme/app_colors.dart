import 'package:flutter/material.dart';

/// App color palette - thoughtfully curated for Athena.
class AppColors {
  // Private constructor to prevent instantiation.
  AppColors._();

  // --- Core Brand Palette ---
  // Primary brand color, used for major UI elements, navigation, and call-to-actions.
  static const Color athenaBlue = Color(0xFF1A73E8); // Vibrant and trustworthy blue
  // Secondary brand color, used for accents, highlights, and secondary actions.
  static const Color athenaPurple = Color(0xFFA78BFA); // Friendly and engaging purple
  // Supportive accent color, often used for success states or positive reinforcement.
  static const Color athenaSupportiveGreen = Color(0xFF5CD6C0); // Calm and encouraging teal/green

  // --- Neutrals ---
  // Standard black for text and dark elements.
  static const Color black = Color(0xFF000000);
  // Standard white for backgrounds and light text.
  static const Color white = Colors.white;
  // Off-white for main app background, providing a softer canvas.
  static const Color athenaOffWhite = Color(0xFFF5F5F5);
  // Dark grey for primary text, icons, and important content against light backgrounds.
  static const Color athenaDarkGrey = Color(0xFF424242);
  // Medium grey for secondary text, hints, and disabled states.
  static const Color athenaMediumGrey = Color(0xFF757575);
  // Light grey for dividers, borders, and subtle background elements.
  static const Color athenaLightGrey = Color(0xFFBDBDBD);

  // --- Semantic & Utility Colors ---
  // Primary color alias for consistency.
  static const Color primary = athenaBlue;
  // Secondary color alias.
  static const Color secondary = athenaPurple;
  // Background color alias.
  static const Color background = athenaOffWhite;
  // Surface color, typically for cards, dialogs, and sheets.
  static const Color surface = white;
  // Text/icon color on primary backgrounds.
  static const Color onPrimary = white;
  // Text/icon color on secondary backgrounds.
  static const Color onSecondary = white;
  // Text/icon color on general app background.
  static const Color onBackground = athenaDarkGrey;
  // Text/icon color on surface elements.
  static const Color onSurface = athenaDarkGrey;

  // Standard error color for highlighting issues, validation errors, etc.
  static const Color error = Color(0xFFD32F2F); // A Material Design standard red
  // Text/icon color on error backgrounds.
  static const Color onError = white;

  // Color for warning messages or states needing attention.
  static const Color warning = Color(0xFFFFA000); // Amber/orange for warnings
  // Text/icon color on warning backgrounds.
  static const Color onWarning = black;

  // Color for success messages or positive confirmations (can be same as supportiveGreen).
  static const Color success = athenaSupportiveGreen;
  // Text/icon color on success backgrounds.
  static const Color onSuccess = black; // Or white, depending on contrast with athenaSupportiveGreen

  // --- Gradient Example (if needed, implement directly in widgets for more control) ---
  // static const LinearGradient athenaGradient = LinearGradient(
  //   colors: [athenaBlue, athenaPurple],
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  // );
}
