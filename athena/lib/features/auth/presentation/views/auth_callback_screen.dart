import 'package:flutter/material.dart';

class AuthCallbackScreen extends StatelessWidget {
  const AuthCallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen acts as a temporary target for the deep link.
    // Supabase SDK processes the URL fragment/query params, auth state changes,
    // and GoRouter's global redirect logic then navigates to the appropriate screen (e.g., /home).
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 