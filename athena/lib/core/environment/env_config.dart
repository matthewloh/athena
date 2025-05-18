import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  /// Checks if the app is running on Web
  static final bool isWeb = kIsWeb;

  /// Reads the environment type (dev, uat, prod) from `dart-define`. Defaults to 'dev'.
  static final String env = const String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// Loads the correct environment file for local development.
  static Future<void> loadEnv() async {
    if (!isWeb) {
      String envFile = '.env.$env';
      try {
        await dotenv.load(fileName: envFile);
      } catch (e) {
        // If the .env file is critical for local non-web development and not found,
        // re-throwing or specific handling might be needed.
        // For now, let's maintain the original behavior of throwing.
        throw Exception(
          'Failed to load environment file: $envFile. Make sure it exists or variables are dart-defined.',
        );
      }
    }
  }

  /// Retrieves the API URL from `dart-define` or `.env` file.
  static String get apiUrl {
    String valueFromDefine = const String.fromEnvironment(
      'API_URL',
      defaultValue: '',
    );
    if (valueFromDefine.isNotEmpty) {
      return valueFromDefine;
    }
    if (!isWeb) {
      return dotenv.env['API_URL'] ?? 'https://api.default.com';
    }
    return 'https://api.default.com'; // Default for web if not dart-defined
  }

  /// Retrieves the Supabase URL.
  /// Prioritizes dart-define, then .env (for non-web), then empty string.
  static String get supabaseUrl {
    String value = const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    if (value.isNotEmpty) {
      return value;
    }
    if (!isWeb) {
      return dotenv.env['SUPABASE_URL'] ?? '';
    }
    return ''; // Must be provided for web via dart-define, or results in empty
  }

  /// Retrieves the Supabase Anon Key.
  /// Prioritizes dart-define, then .env (for non-web), then empty string.
  static String get supabaseAnonKey {
    String value = const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );
    if (value.isNotEmpty) {
      return value;
    }
    if (!isWeb) {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    }
    return ''; // Must be provided for web via dart-define, or results in empty
  }
}
