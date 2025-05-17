import 'package:flutter/material.dart';
import 'package:athena/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Athena',
      theme: ThemeData(
        fontFamily: 'Inter', // Set Inter as the default font
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.athenaBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.athenaOffWhite,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.athenaBlue,
          foregroundColor: AppColors.white,
          elevation: 2,
          titleTextStyle: const TextStyle(
            fontFamily:
                'Inter', // Or Overused Grotesk if preferred for AppBar titles
            fontSize: 20,
            fontWeight:
                FontWeight.w500, // Corresponds to a common 'medium' weight
            color: AppColors.white,
            fontVariations: <FontVariation>[FontVariation('wght', 500.0)],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaBlue,
            foregroundColor: AppColors.white,
            minimumSize: const Size(200, 50),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500, // Medium weight
              fontVariations: <FontVariation>[FontVariation('wght', 500.0)],
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.athenaBlue,
            side: const BorderSide(color: AppColors.athenaBlue, width: 1.5),
            minimumSize: const Size(200, 50),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500, // Medium weight
              fontVariations: <FontVariation>[FontVariation('wght', 500.0)],
            ),
          ),
        ),
        textTheme: const TextTheme(
          // Updated to use Inter by default due to ThemeData.fontFamily
          // Specific overrides below if needed, or use Overused Grotesk directly in widgets
          headlineMedium: TextStyle(
            fontFamily: 'Overused Grotesk', // Specific font for this style
            color: AppColors.athenaDarkGrey,
            fontWeight:
                FontWeight.bold, // This will be controlled by fontVariations
            fontVariations: <FontVariation>[
              FontVariation('wght', 700.0), // Bold for Overused Grotesk
            ],
          ),
          titleMedium: TextStyle(
            // fontFamily: 'Inter', // Inherited from ThemeData
            color: AppColors.athenaDarkGrey,
            // fontWeight and fontVariations can be set here or in the widget
          ),
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Athena')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/images/logo.png', // Path to your logo
                height: 128, // Adjust size as needed
                width: 128, // Adjust size as needed
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Athena!',
                style: textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  // fontWeight is now controlled by fontVariations in TextTheme
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI-powered study companion to enhance your learning journey.',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.athenaDarkGrey.withOpacity(0.9),
                  fontSize: 16, // Slightly adjusted size
                  fontVariations: const <FontVariation>[
                    FontVariation('wght', 400.0), // Regular weight for Inter
                    FontVariation('opsz', 16.0), // Optical size for Inter
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to Login Screen
                  print('Login button pressed');
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to Sign Up Screen
                  print('Sign Up button pressed');
                },
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
