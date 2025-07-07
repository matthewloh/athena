import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/constants/constants.dart'; // For Supabase callback URL
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/auth/presentation/widgets/sign_up_form_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final ValueNotifier<bool> _marketingConsentNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<bool> _termsAgreedNotifier = ValueNotifier<bool>(false);

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _marketingConsentNotifier.dispose();
    _termsAgreedNotifier.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref
          .read(appAuthProvider.notifier)
          .signUp(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            data: {
              'full_name': _fullNameController.text.trim(),
              'marketing_consent': _marketingConsentNotifier.value,
              'terms_agreement': _termsAgreedNotifier.value,
            },
          );

      if (mounted) {
        setState(() {
          _successMessage =
              'Sign Up successful! Please check your email to verify your account.';
          _fullNameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _marketingConsentNotifier.value = false; // Reset notifiers
          _termsAgreedNotifier.value = false;
        });
      }
        } catch (e) {
      // Debug logging to see exactly what error we're getting
      print('🚨 Signup error: Type: ${e.runtimeType}, Message: $e');
      if (e is AuthException) {
        print('🚨 AuthException details: ${e.message}');
      }
      
      if (mounted) {
        setState(() {
          if (e is AuthException) {
            // Handle specific case where email already exists
            if (e.message.toLowerCase().contains('duplicate') || 
                e.message.toLowerCase().contains('already exists') ||
                e.message.toLowerCase().contains('unique constraint') ||
                e.message.toLowerCase().contains('email already registered') ||
                e.message.toLowerCase().contains('user already registered')) {
              _errorMessage =
                  'An account with this email already exists. Please use a different email or sign in instead.';
            } else {
              _errorMessage = e.message;
            }
          } else {
            // Check if it's a PostgreSQL constraint violation
            final errorString = e.toString().toLowerCase();
            if (errorString.contains('duplicate key value') ||
                errorString.contains('unique constraint') ||
                errorString.contains('profiles_email_key') ||
                errorString.contains('already exists')) {
              _errorMessage =
                  'An account with this email already exists. Please use a different email or sign in instead.';
            } else {
              _errorMessage = 'Signup failed: ${e.toString()}';
            }
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSocialSignUpError(dynamic error) {
    if (mounted) {
      setState(() {
        _successMessage = null;
        if (error is AuthException) {
          _errorMessage = error.message;
        } else if (error != null) {
          _errorMessage = error.toString();
        } else {
          _errorMessage = 'An unknown error occurred during social sign-up.';
        }
      });
    }
  }

  Widget _buildMessageArea() {
    Color? messageColor;
    String? messageText;
    IconData? messageIcon;

    if (_errorMessage != null) {
      messageColor = AppColors.error;
      messageText = _errorMessage!;
      messageIcon = Icons.error_outline_rounded;
    } else if (_successMessage != null) {
      messageColor = AppColors.success;
      messageText = _successMessage!;
      messageIcon = Icons.check_circle_outline_rounded;
    }

    if (messageText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: messageColor?.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: messageColor!.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(messageIcon, color: messageColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                messageText,
                style: TextStyle(
                  color:
                      messageColor == AppColors.success
                          ? AppColors.athenaDarkGrey
                          : messageColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final athenaAuthTheme = Theme.of(context).copyWith(
      dividerTheme: DividerThemeData(
        color: AppColors.athenaLightGrey.withValues(alpha: 0.7),
        thickness: 1,
        space: 24,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate back to landing instead of exiting app
          context.goNamed(AppRouteNames.landing);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.athenaOffWhite,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 16,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Image.asset(
                          'assets/images/logo.png',
                          height: screenHeight * 0.12,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        const Text(
                          'Create your Athena Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.athenaDarkGrey,
                            fontFamily: 'Overused Grotesk',
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        _buildMessageArea(),
                        SignUpFormWidget(
                          formKey: _formKey,
                          fullNameController: _fullNameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          marketingConsentNotifier: _marketingConsentNotifier,
                          termsAgreedNotifier: _termsAgreedNotifier,
                          isLoading: _isLoading,
                          onSubmit: _signUp,
                        ),
                        const SizedBox(height: 16),
                        Theme(
                          data: athenaAuthTheme,
                          child: const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  'OR SIGN UP WITH',
                                  style: TextStyle(
                                    color: AppColors.athenaMediumGrey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Theme(
                          data: athenaAuthTheme,
                          child: SupaSocialsAuth(
                            socialProviders: const [OAuthProvider.google],
                            colored: true,
                            redirectUrl:
                                kIsWeb
                                    ? null
                                    : Constants.supabaseLoginCallbackUrlMobile,
                            onSuccess: (Session response) {
                              if (mounted) {
                                setState(() {
                                  _errorMessage = null;
                                  _successMessage =
                                      'Successfully signed up and logged in with Google.';
                                });
                              }
                            },
                            onError: _handleSocialSignUpError,
                            authScreenLaunchMode: LaunchMode.inAppWebView,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: AppColors.athenaDarkGrey,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.goNamed(AppRouteNames.login),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
