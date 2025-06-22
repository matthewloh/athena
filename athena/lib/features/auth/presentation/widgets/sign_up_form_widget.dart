// ignore_for_file: avoid_print

import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer
import 'package:flutter/material.dart';

class SignUpFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> marketingConsentNotifier;
  final ValueNotifier<bool> termsAgreedNotifier;
  final bool isLoading;
  final VoidCallback onSubmit;

  const SignUpFormWidget({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.marketingConsentNotifier,
    required this.termsAgreedNotifier,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Theme similar to EmailPasswordSocialSignInForm for consistency
    final athenaAuthTheme = ThemeData.light().copyWith(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary; // Color when checkbox is selected
          }
          return AppColors
              .athenaMediumGrey; // Color when checkbox is unselected
        }),
        checkColor: WidgetStateProperty.all(
          AppColors.onPrimary,
        ), // Color of the check mark
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.8),
        labelStyle: TextStyle(color: AppColors.athenaMediumGrey, fontSize: 15),
        hintStyle: TextStyle(color: AppColors.athenaLightGrey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 16.0,
        ), // Adjusted vertical padding
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
        suffixIconColor: AppColors.athenaMediumGrey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Theme(
      data: athenaAuthTheme,
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: widget.fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.length < 3) {
                  return 'Full name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_passwordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }

                // Add more complex password validation if needed (e.g., regex)
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_confirmPasswordVisible,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != widget.passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: Text(
                'Keep me up to date with the latest news and updates.',
                style: TextStyle(fontSize: 14, color: AppColors.athenaDarkGrey),
              ),
              value: widget.marketingConsentNotifier.value,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  setState(() {
                    // setState to rebuild the CheckboxListTile with the new value
                    widget.marketingConsentNotifier.value = newValue;
                  });
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero, // Adjust padding as needed
              activeColor:
                  AppColors.primary, // Uses checkboxTheme if defined, else this
            ),
            const SizedBox(height: 8),
            FormField<bool>(
              initialValue: widget.termsAgreedNotifier.value,
              validator: (value) {
                if (value == false) {
                  return 'You must agree to the terms and conditions';
                }
                return null;
              },
              builder: (FormFieldState<bool> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.athenaDarkGrey,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                              text: 'I have read and agree to the ',
                            ),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: Implement navigation or dialog for Terms and Conditions
                                      print('Terms and Conditions tapped');
                                      // Example: showDialog(...);
                                    },
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      value: widget.termsAgreedNotifier.value,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          setState(() {
                            // setState to rebuild the CheckboxListTile with the new value
                            widget.termsAgreedNotifier.value = newValue;
                          });
                          state.didChange(
                            newValue,
                          ); // Important for FormField validation
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40.0,
                          top: 0,
                        ), // Align with checkbox title approx
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onSubmit,
              child:
                  widget.isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
