import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/constants/constants.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/auth/presentation/widgets/custom_sign_in_form.dart';
import 'package:athena/features/auth/presentation/widgets/login_method_toggle.dart';
import 'package:athena/features/auth/presentation/widgets/custom_magic_link_form.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  void _handleSocialSignInError(dynamic error) {
    if (mounted) {
      setState(() {
        _successMessage = null;
        if (error is AuthException) {
          _errorMessage = error.message;
        } else if (error != null) {
          _errorMessage = error.toString();
        } else {
          _errorMessage = 'An unknown error occurred during social sign-in.';
        }
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb
                ? Constants.supabaseLoginCallbackUrlWeb
                : Constants.supabaseLoginCallbackUrlMobile,
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );

      if (mounted) {
        setState(() {
          _errorMessage = null;
          _successMessage = 'Successfully signed in with Google.';
        });
      }
    } catch (e) {
      if (mounted) {
        _handleSocialSignInError(e);
      }
    }
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
                                    CustomSignInForm(
                                      onSignInComplete: () {
                                        if (mounted) {
                                          setState(() {
                                            _errorMessage = null;
                                            _successMessage = null;
                                          });
                                        }
                                      },
                                      onPasswordResetEmailSent: () {
                                        if (mounted) {
                                          setState(() {
                                            _errorMessage = null;
                                            _successMessage =
                                                'Password recovery email sent! Check your inbox.';
                                          });
                                        }
                                      },
                                      onError: _handleError,
                                    ),
                                  if (_selectedLoginMethod ==
                                      LoginMethod.magicLink)
                                    CustomMagicLinkForm(
                                      onSuccess: () {
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
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
                          const SizedBox(height: 16),
                          Theme(
                            data: athenaAuthTheme,
                            child: SupaSocialsAuth(
                              socialProviders: const [OAuthProvider.google],
                              colored: true,
                              // nativeGoogleAuthConfig: const NativeGoogleAuthConfig(
                              //   webClientId:
                              //       '653279524622-tcbl98f4inl6hv8c4ssakc4tofeu7mor.apps.googleusercontent.com',
                              //   iosClientId:
                              //       '653279524622-f715bn4fm2md061pvl8qlrcfvftt5rs2.apps.googleusercontent.com',
                              // ),
                              redirectUrl:
                                  kIsWeb
                                      ? null
                                      : Constants
                                          .supabaseLoginCallbackUrlMobile,
                              onSuccess: (Session response) {
                                if (mounted) {
                                  setState(() {
                                    _errorMessage = null;
                                    _successMessage =
                                        'Successfully signed up and logged in with social provider.';
                                  });
                                }
                              },
                              onError: _handleSocialSignUpError,
                              authScreenLaunchMode: LaunchMode.inAppWebView,
                            ),
                          ),
                          // SizedBox(
                          //   height: 48,
                          //   child: OutlinedButton.icon(
                          //     onPressed: _signInWithGoogle,
                          //     icon: Image.asset(
                          //       'assets/images/google_logo.png',
                          //       height: 20,
                          //       width: 20,
                          //       errorBuilder: (context, error, stackTrace) {
                          //         return const Icon(
                          //           Icons.g_mobiledata,
                          //           size: 24,
                          //           color: Colors.red,
                          //         );
                          //       },
                          //     ),
                          //     label: const Text(
                          //       'Continue with Google',
                          //       style: TextStyle(
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.w600,
                          //         color: AppColors.athenaDarkGrey,
                          //       ),
                          //     ),
                          //     style: OutlinedButton.styleFrom(
                          //       side: BorderSide(
                          //         color: AppColors.athenaLightGrey.withValues(
                          //           alpha: 0.7,
                          //         ),
                          //       ),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8.0),
                          //       ),
                          //       backgroundColor: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
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
