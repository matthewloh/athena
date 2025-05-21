/// Route name constants to be used throughout the app
class AppRouteNames {
  AppRouteNames._(); // Private constructor

  // Auth related routes
  static const String landing = 'landing';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String profile = 'profile';

  // Main app routes
  static const String home = 'home';
  static const String loading = 'loading';

  // Feature routes
  static const String chat = 'chat';
  static const String materials = 'materials';
  static const String review = 'review';
  static const String planner = 'planner';

  static const String loginCallback =
      'loginCallback'; // Kept for now, though unused in current flow
  static const String authCallback =
      'auth/callback'; // Ensure this matches the actual incoming path
  static const String updatePassword =
      'update-password'; // For setting a new password after recovery link
}
