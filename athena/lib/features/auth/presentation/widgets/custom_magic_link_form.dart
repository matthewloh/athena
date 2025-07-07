import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomMagicLinkForm extends ConsumerStatefulWidget {
  final void Function()? onSuccess;
  final void Function(dynamic error)? onError;

  const CustomMagicLinkForm({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  ConsumerState<CustomMagicLinkForm> createState() => _CustomMagicLinkFormState();
}

class _CustomMagicLinkFormState extends ConsumerState<CustomMagicLinkForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(appAuthProvider.notifier).signInWithOtp(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e);
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
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
          
          const SizedBox(height: 20),
          
          // Send Magic Link button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendMagicLink,
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
                      'Send Magic Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Info text
          Text(
            'We\'ll send you a magic link to sign in without a password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.athenaMediumGrey,
              fontSize: 13,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Don't have an account link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  color: AppColors.athenaDarkGrey,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : () => context.goNamed(AppRouteNames.signup),
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
        ],
      ),
    );
  }
} 