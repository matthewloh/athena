import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/constants/constants.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SignInOnlyForm extends StatelessWidget {
  final void Function(AuthResponse response) onSignInComplete;
  final VoidCallback onPasswordResetEmailSentCallback;
  final void Function(Session response) onSocialSuccess;
  final void Function(dynamic error) onError;

  const SignInOnlyForm({
    super.key,
    required this.onSignInComplete,
    required this.onPasswordResetEmailSentCallback,
    required this.onSocialSuccess,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.athenaLightGrey.withValues(alpha: 0.7),
        thickness: 1,
        space: 24,
      ),
    );

    return Theme(
      data: athenaAuthTheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sign-in only form (no sign-up functionality)
          SupaEmailAuth(
            redirectTo:
                kIsWeb ? null : Constants.supabaseLoginCallbackUrlMobile,
            onSignInComplete: onSignInComplete,
            onPasswordResetEmailSent: onPasswordResetEmailSentCallback,
            onError: onError,
            autofocus: false,
            // Remove sign-up related callbacks and metadata
            onSignUpComplete: (response) {},
            metadataFields: [],
            showConfirmPasswordField: false,
          ),

          // "Don't have an account? Sign up" link
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(color: AppColors.athenaDarkGrey, fontSize: 14),
              ),
              TextButton(
                onPressed: () => context.goNamed(AppRouteNames.signup),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'OR SIGN IN WITH',
                  style: TextStyle(
                    color: AppColors.athenaMediumGrey,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          Theme(
            data: athenaAuthTheme.copyWith(
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: athenaAuthTheme.elevatedButtonTheme.style?.copyWith(
                  textStyle: WidgetStateProperty.all<TextStyle>(
                    athenaAuthTheme.textTheme.labelLarge!.copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ),
            ),
            child: SupaSocialsAuth(
              socialProviders: const [OAuthProvider.google],
              colored: true,
              redirectUrl: Constants.supabaseLoginCallbackUrlWeb,
              onSuccess: onSocialSuccess,
              onError: onError,
              authScreenLaunchMode: LaunchMode.inAppWebView,
            ),
          ),
        ],
      ),
    );
  }
}
