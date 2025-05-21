import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() =>
      _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  String? _successMessage;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // The accessToken is usually handled by Supabase internally when the app is opened via the recovery link.
    // Supabase.instance.client.auth.currentSession?.accessToken is the typical way to get it
    // if needed directly, but SupaResetPassword should handle it if the session is active from the link.
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Your Password'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 80,
                width: 80,
                color: AppColors.athenaBlue, // Tint with brand color
              ),
              const SizedBox(height: 24),
              Text(
                'Create a new strong password for your Athena account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.athenaDarkGrey,
                ),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(
                      color: AppColors.success, // Use AppColors.success
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (accessToken == null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invalid or expired recovery session. Please try requesting a password reset again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            GoRouter.of(context).goNamed(AppRouteNames.login);
                          }
                        },
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
                )
              else
                SupaResetPassword(
                  accessToken: accessToken,
                  onSuccess: (response) {
                    if (mounted) {
                      final router = GoRouter.of(context);
                      setState(() {
                        _successMessage =
                            'Password updated successfully! You can now sign in with your new password.';
                        _errorMessage = null;
                      });
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) router.goNamed(AppRouteNames.login);
                      });
                    }
                  },
                  onError: (error) {
                    if (mounted) {
                      setState(() {
                        _errorMessage = error.toString();
                        _successMessage = null;
                      });
                    }
                  },
                  // You can customize the form fields if needed using `passwordLength` or `customPasswordValidators`
                  // For theming, SupaResetPassword uses Material widgets that adapt to your app's theme.
                ),
              const SizedBox(height: 24),
              if (_successMessage != null ||
                  accessToken ==
                      null) // Show login button if success or if token invalid
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      GoRouter.of(context).goNamed(AppRouteNames.login);
                    }
                  },
                  child: const Text('Proceed to Login'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
