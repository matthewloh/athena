import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/auth/presentation/widgets/email_password_social_sign_in_form.dart';
import 'package:athena/features/auth/presentation/widgets/login_method_toggle.dart';
import 'package:athena/features/auth/presentation/widgets/magic_link_sign_in_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Define the enum for login methods here
enum LoginMethod { emailPasswordSocial, magicLink }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? _errorMessage;
  String? _successMessage;
  LoginMethod _selectedLoginMethod = LoginMethod.emailPasswordSocial;

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildMessageArea() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_successMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: AppColors.athenaDarkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _handleError(dynamic error) {
    if (mounted) {
      setState(() {
        _successMessage = null;
        if (error is AuthException) {
          _errorMessage = error.message;
        } else {
          _errorMessage = error.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Image.asset(
                          'assets/images/logo.png',
                          height: screenHeight * 0.15,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        const Text(
                          'Welcome to Athena!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.athenaDarkGrey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'Sign in to continue your learning journey',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: AppColors.athenaMediumGrey,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildMessageArea(),
                                LoginMethodToggle(
                                  selectedMethod: _selectedLoginMethod,
                                  onMethodSelected: (method) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedLoginMethod = method;
                                        _errorMessage = null;
                                        _successMessage = null;
                                      });
                                    }
                                  },
                                ),
                                if (_selectedLoginMethod ==
                                    LoginMethod.emailPasswordSocial)
                                  EmailPasswordSocialSignInForm(
                                    onSignInComplete: (response) {
                                      if (mounted) {
                                        setState(() {
                                          _errorMessage = null;
                                          _successMessage = null;
                                        });
                                      }
                                    },
                                    onSignUpComplete: (response) {
                                      if (mounted) {
                                        setState(() {
                                          _errorMessage = null;
                                          _successMessage =
                                              'Sign up successful! Please verify your email and sign in.';
                                        });
                                      }
                                    },
                                    onPasswordResetEmailSentCallback: () {
                                      if (mounted) {
                                        setState(() {
                                          _errorMessage = null;
                                          _successMessage =
                                              'Password recovery email sent! Check your inbox.';
                                        });
                                      }
                                    },
                                    onSocialSuccess: (response) {
                                      if (mounted) {
                                        setState(() {
                                          _errorMessage = null;
                                          _successMessage =
                                              'Successfully signed in with social provider.';
                                        });
                                      }
                                    },
                                    onError: _handleError,
                                  ),
                                if (_selectedLoginMethod ==
                                    LoginMethod.magicLink)
                                  MagicLinkSignInForm(
                                    onSuccess: (response) {
                                      if (mounted) {
                                        setState(() {
                                          _errorMessage = null;
                                          _successMessage =
                                              'Magic link sent! Check your email inbox.';
                                        });
                                      }
                                    },
                                    onError: _handleError,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
