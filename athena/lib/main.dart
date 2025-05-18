import 'package:athena/core/environment/env_config.dart';
import 'package:athena/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables. For web, dart-defines are used directly by EnvConfig.
  // For non-web, this loads .env files if present.
  await EnvConfig.loadEnv();

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // Check if Supabase keys are loaded, especially for web where they must be dart-defined
  if (EnvConfig.isWeb &&
      (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty)) {
    // Display a more prominent error for web if keys are missing
    runApp(const MissingEnvErrorApp(isWeb: true));
    return;
  } else if (!EnvConfig.isWeb &&
      (EnvConfig.supabaseUrl.isEmpty || EnvConfig.supabaseAnonKey.isEmpty)) {
    // For non-web, if keys are still empty after trying dart-define and .env, show error
    // This might happen if .env file is missing/misconfigured and no dart-defines are set
    runApp(const MissingEnvErrorApp(isWeb: false));
    return;
  }

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

// Added a helper widget to display a clear error if env vars are missing
class MissingEnvErrorApp extends StatelessWidget {
  final bool isWeb;
  const MissingEnvErrorApp({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    String message =
        'Error: SUPABASE_URL and SUPABASE_ANON_KEY must be provided.';
    if (isWeb) {
      message +=
          ' Please ensure they are defined in your env.json and passed via --dart-define-from-file=env.json.';
    } else {
      message +=
          ' Please ensure they are defined in .env files (e.g., .env.dev) or via dart-define for this build.';
    }
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
