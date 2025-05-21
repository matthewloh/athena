import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  final GoRouterState? routerState;
  final String? errorMessage;

  const NotFoundScreen({super.key, this.routerState, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final uri = routerState?.uri.toString();
    final error = routerState?.error?.toString() ?? errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 32),
              Text(
                'Oops! We couldn\'t find that page.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.athenaDarkGrey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (uri != null && uri.isNotEmpty)
                Text(
                  'Requested Path: $uri',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 8),
              if (error != null && error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    'Error: $error',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red[700],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.goNamed(AppRouteNames.home),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go to Homepage'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
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