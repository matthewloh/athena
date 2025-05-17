import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Core Palette
  static const Color athenaBlue = Color(0xFF3F8EFC);
  static const Color athenaPurple = Color(0xFFA78BFA);
  static const Color athenaSupportiveGreen = Color(0xFF5CD6C0);

  // Neutrals
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color athenaOffWhite = Color(0xFFFAFAFA);
  static const Color athenaDarkGrey = Color(0xFF1E1E1E);

  // Example Semantic Colors (Can be expanded based on usage)
  // These could be defined based on the core palette or be new colors.
  // For now, let's alias some for demonstration.
  static const Color primary = athenaBlue;
  static const Color secondary = athenaPurple;
  static const Color background = athenaOffWhite;
  static const Color surface = white;
  static const Color onPrimary = white;
  static const Color onSecondary = white;
  static const Color onBackground = athenaDarkGrey;
  static const Color onSurface = athenaDarkGrey;
  static const Color error = Colors.red; // Standard error color
  static const Color onError = white;
} 