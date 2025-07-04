import 'package:athena/core/router/app_router.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  usePathUrlStrategy();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // set to pkce by default
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
    storageOptions: const StorageClientOptions(retryAttempts: 10),
  );

  // Initialize FCM service
  await FCMService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Athena',
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
      ],
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
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AppColors.white,
            fontVariations: const [FontVariation('wght', 500.0)],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaBlue,
            foregroundColor: AppColors.white,
            minimumSize: const Size(200, 50),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontVariations: const [FontVariation('wght', 500.0)],
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.athenaBlue,
            side: BorderSide(color: AppColors.athenaBlue, width: 1.5),
            minimumSize: const Size(200, 50),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontVariations: const [FontVariation('wght', 500.0)],
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Overused Grotesk',
            color: AppColors.athenaDarkGrey,
            fontWeight: FontWeight.bold,
            fontVariations: const [FontVariation('wght', 700.0)],
          ),
          titleMedium: TextStyle(color: AppColors.athenaDarkGrey),
        ),
        useMaterial3: true,
      ),
    );
  }
}
