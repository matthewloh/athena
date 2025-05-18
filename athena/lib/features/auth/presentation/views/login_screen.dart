import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/features/auth/presentation/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Listen for errors and show SnackBar
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Optional: Listen for successful login (isAuthenticated becomes true) to navigate
      // This can also be handled by GoRouter's redirect based on auth state
      // if (next.isAuthenticated && previous?.isAuthenticated == false) {
      //   context.goNamed(AppRouteNames.home);
      // }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login to Athena')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Consider adding your logo here if desired
                // Image.asset('assets/images/logo.png', height: 100),
                // const SizedBox(height: 48),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (authState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        authViewModel.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // TODO: Implement navigation to forgot password screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot Password functionality not implemented yet.')),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don\\'t have an account?"),
                    TextButton(
                      onPressed: () => context.goNamed(AppRouteNames.signup),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 