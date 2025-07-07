import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(appAuthProvider.notifier).recoverPassword(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _successMessage = 'Password reset email sent! Check your inbox for instructions.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is AuthException) {
            _errorMessage = e.message;
          } else {
            _errorMessage = e.toString();
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Widget _buildMessageArea() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
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
        padding: const EdgeInsets.only(bottom: 16.0),
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Navigate back to login instead of exiting app
          context.goNamed(AppRouteNames.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.athenaOffWhite,
        appBar: AppBar(
          title: const Text('Forgot Password'),
          backgroundColor: AppColors.athenaOffWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.goNamed(AppRouteNames.login),
          ),
        ),
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
                        SizedBox(height: screenHeight * 0.05),
                        Image.asset(
                          'assets/images/logo.png',
                          height: screenHeight * 0.12,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        const Text(
                          'Reset Your Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.athenaDarkGrey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Enter your email address and we\'ll send you a link to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.athenaMediumGrey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMessageArea(),
                                  
                                  // Email field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      hintText: 'Enter your email',
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      filled: true,
                                      fillColor: AppColors.white.withValues(alpha: 0.8),
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
                                    ),
                                    validator: _validateEmail,
                                    enabled: !_isLoading,
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Send Reset Email button
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _resetPassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Send Reset Email',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                  
                                  if (_successMessage != null) ...[
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.athenaLightGrey.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'What\'s next?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.athenaDarkGrey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '1. Check your email inbox\n2. Click the reset link in the email\n3. Create a new password\n4. Sign in with your new password',
                                            style: TextStyle(
                                              color: AppColors.athenaMediumGrey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Back to Login button
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Remember your password?',
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