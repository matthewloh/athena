import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomUpdatePasswordScreen extends ConsumerStatefulWidget {
  const CustomUpdatePasswordScreen({super.key});

  @override
  ConsumerState<CustomUpdatePasswordScreen> createState() =>
      _CustomUpdatePasswordScreenState();
}

class _CustomUpdatePasswordScreenState extends ConsumerState<CustomUpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(appAuthProvider.notifier).updatePassword(
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        setState(() {
          _successMessage = 'Password updated successfully! You can now sign in with your new password.';
        });
        
        // Navigate to login after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.goNamed(AppRouteNames.login);
          }
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
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
    
    // Check if we have a valid session from the recovery link
    final accessToken = Supabase.instance.client.auth.currentSession?.accessToken;
    
    if (accessToken == null) {
      return Scaffold(
        backgroundColor: AppColors.athenaOffWhite,
        appBar: AppBar(
          title: const Text('Update Password'),
          backgroundColor: AppColors.athenaOffWhite,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Invalid or Expired Link',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.athenaDarkGrey,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'This password reset link is invalid or has expired. Please request a new password reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.athenaMediumGrey,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => context.goNamed(AppRouteNames.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        title: const Text('Update Password'),
        backgroundColor: AppColors.athenaOffWhite,
        elevation: 0,
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
                        'Create New Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.athenaDarkGrey,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Enter a strong new password for your account',
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
                                
                                // New Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    hintText: 'Enter your new password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
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
                                  validator: _validatePassword,
                                  enabled: !_isLoading,
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Confirm Password field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm New Password',
                                    hintText: 'Confirm your new password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
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
                                  validator: _validateConfirmPassword,
                                  enabled: !_isLoading,
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Password requirements
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
                                        'Password Requirements:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.athenaDarkGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '• At least 6 characters long\n• Contains uppercase and lowercase letters\n• Contains at least one number',
                                        style: TextStyle(
                                          color: AppColors.athenaMediumGrey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Update Password button
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _updatePassword,
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
                                            'Update Password',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
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
              
              // Back to Login button
              if (_successMessage != null || _errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextButton(
                    onPressed: () => context.goNamed(AppRouteNames.login),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
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