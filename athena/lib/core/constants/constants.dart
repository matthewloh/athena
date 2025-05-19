import 'package:flutter/foundation.dart';

class Constants {
  Constants._();

  static const String appName = 'Athena';

  // Mobile deep link scheme for auth callbacks
  static const String mobileRedirectUrl = 'app.helloathena://login-callback';
  
  // Web auth callback URL
  static const String webRedirectUrl = 'https://helloathena.app/auth-callback';
  
  // Return the appropriate redirect URL based on platform
  static String get supabaseRedirectUrl => 
      kIsWeb ? webRedirectUrl : mobileRedirectUrl;
      
  // Legacy constant for backward compatibility
  static const String supabaseLoginCallbackUrl = mobileRedirectUrl;
}
