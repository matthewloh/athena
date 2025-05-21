import 'package:athena/core/constants/constants.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class MagicLinkSignInForm extends StatelessWidget {
  final void Function(Session response) onSuccess;
  final void Function(dynamic error) onError;

  const MagicLinkSignInForm({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    final athenaAuthTheme = ThemeData.light().copyWith(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.8),
        labelStyle: TextStyle(color: AppColors.athenaMediumGrey, fontSize: 15),
        hintStyle: TextStyle(color: AppColors.athenaLightGrey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 12.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.athenaLightGrey.withValues(alpha: 0.7),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.athenaLightGrey.withValues(alpha: 0.7),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        prefixIconColor: AppColors.athenaMediumGrey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Theme(
      data: athenaAuthTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          SupaMagicAuth(
            redirectUrl:
                kIsWeb ? null : Constants.supabaseLoginCallbackUrlMobile,
            onSuccess: onSuccess,
            onError: onError,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
