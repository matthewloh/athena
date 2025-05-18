// For FontVariation
import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Athena')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png', // Path to your logo
                height: 128,
                width: 128,
              ),
              const SizedBox(height: 32),
              Text(
                'Athena',
                style: textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Overused Grotesk',
                  fontSize: 48,
                  color: Theme.of(context).colorScheme.primary,
                  fontVariations: const <FontVariation>[
                    FontVariation('wght', 700.0),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI-powered study companion.',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.athenaDarkGrey.withOpacity(0.9),
                  fontSize: 18,
                  fontVariations: const <FontVariation>[
                    FontVariation('wght', 400.0),
                    FontVariation('opsz', 18.0),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => context.goNamed(AppRouteNames.login),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.goNamed(AppRouteNames.signup),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
} 