import 'package:athena/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Athena',
      theme: ThemeData(
        fontFamily: 'Inter',
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
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
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
              fontWeight: FontWeight.w500,
              fontVariations: <FontVariation>[FontVariation('wght', 500.0)],
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Overused Grotesk',
            color: AppColors.athenaDarkGrey,
            fontWeight: FontWeight.bold,
            fontVariations: <FontVariation>[FontVariation('wght', 700.0)],
          ),
          titleMedium: TextStyle(color: AppColors.athenaDarkGrey),
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// LandingPage, MyHomePage and _MyHomePageState are now removed as LandingScreen is created
// in features/auth/presentation/views/ and routing is handled by GoRouter.
