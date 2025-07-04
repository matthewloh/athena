import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/shared/widgets/in_app_notification.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final SupabaseClient _supabase = Supabase.instance.client;
  static BuildContext? _currentContext;

  /// Set current context for showing notifications
  static void setContext(BuildContext context) {
    _currentContext = context;
  }

  /// Initialize FCM and request permissions
  static Future<void> initialize() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ FCM: User granted permission');

        // Set up message handlers
        _setupMessageHandlers();

        // Set up token refresh listener
        _firebaseMessaging.onTokenRefresh.listen(_handleTokenRefresh);

        // Set up auth state listener
        _supabase.auth.onAuthStateChange.listen((data) {
          if (data.event == AuthChangeEvent.signedIn) {
            _handleUserSignedIn();
          } else if (data.event == AuthChangeEvent.signedOut) {
            _handleUserSignedOut();
          }
        });

        // If user is already signed in, get token now
        if (_supabase.auth.currentUser != null) {
          await _handleUserSignedIn();
        }
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ FCM: User granted provisional permission');
      } else {
        debugPrint('❌ FCM: User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
    }
  }

  /// Handle user sign in - get and save FCM token
  static Future<void> _handleUserSignedIn() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('📱 FCM Token for signed-in user: $token');
        await _saveFCMTokenToSupabase(token);
        await subscribeToTopics();
      }
    } catch (e) {
      debugPrint('❌ Error handling user sign in for FCM: $e');
    }
  }

  /// Handle user sign out - clean up FCM token
  static Future<void> _handleUserSignedOut() async {
    try {
      await deleteToken();
      debugPrint('🔥 FCM token cleaned up on sign out');
    } catch (e) {
      debugPrint('❌ Error handling user sign out for FCM: $e');
    }
  }

  /// Handle token refresh
  static Future<void> _handleTokenRefresh(String token) async {
    debugPrint('🔄 FCM Token refreshed: $token');
    await _saveFCMTokenToSupabase(token);
  }

  /// Save FCM token to Supabase
  static Future<void> _saveFCMTokenToSupabase(String token) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No authenticated user to save FCM token');
        return;
      }

      // Update the profiles table with FCM token
      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', user.id);

      debugPrint('✅ FCM token saved to Supabase');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Set up message handlers for different app states
  static void _setupMessageHandlers() {
    // Handle messages when app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '📨 Received foreground message: ${message.notification?.title}',
      );
      _handleMessage(message);
    });

    // Handle messages when app is opened from background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '📨 App opened from background message: ${message.notification?.title}',
      );
      _handleMessageTap(message);
    });

    // Handle messages when app is opened from terminated state
    _getInitialMessage();
  }

  /// Handle messages when app is in foreground
  static void _handleMessage(RemoteMessage message) {
    debugPrint('📨 Message data: ${message.data}');

    // Show beautiful in-app notification overlay
    if (_currentContext != null) {
      InAppNotificationOverlay.show(_currentContext!, message);
    } else {
      debugPrint('⚠️ No context available for showing notification overlay');
    }

    // Handle specific notification types
    final notificationType = message.data['type'];
    switch (notificationType) {
      case 'goal_completed':
        debugPrint('🎉 Goal completed notification received');
        break;
      case 'goal_created':
        debugPrint('🎯 New goal created notification received');
        break;
      case 'goal_progress':
        debugPrint('📈 Goal progress updated notification received');
        break;
      case 'session_created':
        debugPrint('📅 Study session scheduled notification received');
        break;
      case 'session_completed':
        debugPrint('✅ Study session completed notification received');
        break;
      default:
        debugPrint('📨 Unknown notification type: $notificationType');
    }
  }

  /// Handle message tap (when user taps notification)
  static void _handleMessageTap(RemoteMessage message) {
    debugPrint('📱 User tapped notification: ${message.data}');

    // Navigate to relevant screen based on message data
    if (message.data['type'] == 'goal_completed') {
      // Navigate to planner screen
    } else if (message.data['type'] == 'session_reminder') {
      // Navigate to session details
    }
  }

  /// Check for initial message when app is opened from terminated state
  static Future<void> _getInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('📨 App opened from terminated state with message');
      _handleMessageTap(initialMessage);
    }
  }

  /// Subscribe to topic for general notifications
  static Future<void> subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('athena_updates');
      await _firebaseMessaging.subscribeToTopic('study_tips');
      debugPrint('✅ Subscribed to FCM topics');
    } catch (e) {
      debugPrint('❌ Error subscribing to topics: $e');
    }
  }

  /// Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();

      // Remove token from Supabase
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('profiles')
            .update({'fcm_token': null})
            .eq('id', user.id);
      }

      debugPrint('✅ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Test function to simulate different notification types (for development/testing)
  static void simulateNotification(String type) {
    if (_currentContext == null) {
      debugPrint('⚠️ No context available for testing notifications');
      return;
    }

    late RemoteMessage testMessage;

    switch (type) {
      case 'goal_completed':
        testMessage = RemoteMessage(
          notification: const RemoteNotification(
            title: '🎉 Goal Completed!',
            body:
                'Congratulations! You\'ve completed "Master Flutter Development"',
          ),
          data: {'type': 'goal_completed', 'goalId': 'test-goal-123'},
        );
        break;
      case 'goal_created':
        testMessage = RemoteMessage(
          notification: const RemoteNotification(
            title: '🎯 New Study Goal Created!',
            body:
                'You\'ve set a new goal: "Learn Advanced Mathematics" for Mathematics',
          ),
          data: {
            'type': 'goal_created',
            'goalId': 'test-goal-456',
            'subject': 'Mathematics',
          },
        );
        break;
      case 'goal_progress':
        testMessage = RemoteMessage(
          notification: const RemoteNotification(
            title: '📈 Progress Updated',
            body: '"Complete React Course" is now 75% complete',
          ),
          data: {
            'type': 'goal_progress',
            'goalId': 'test-goal-789',
            'progress': '75',
          },
        );
        break;
      case 'session_completed':
        testMessage = RemoteMessage(
          notification: const RemoteNotification(
            title: '✅ Session Completed!',
            body: 'Great job completing "Mathematics Study Session"!',
          ),
          data: {'type': 'session_completed', 'sessionId': 'test-session-123'},
        );
        break;
      case 'session_created':
        testMessage = RemoteMessage(
          notification: const RemoteNotification(
            title: '📅 Study Session Scheduled',
            body: '"Physics Study Time" scheduled for 3:00 PM',
          ),
          data: {
            'type': 'session_created',
            'sessionId': 'test-session-456',
            'subject': 'Physics',
          },
        );
        break;
      default:
        testMessage = RemoteMessage(
          notification: const RemoteNotification(
            title: '📨 Test Notification',
            body: 'This is a test notification from Athena!',
          ),
          data: {'type': 'test'},
        );
    }

    debugPrint('🧪 Simulating $type notification');
    _handleMessage(testMessage);
  }

  /// Send real notification via Supabase Edge Function (for testing)
  static Future<void> sendRealNotification(
    String type, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No authenticated user for real notification');
        return;
      }

      debugPrint('🚀 Sending real notification via Edge Function: $type');

      final response = await _supabase.functions.invoke(
        'fcm-notifications-jwt',
        body: {
          'user_id': user.id,
          'type': type,
          'title': '',
          'body': '',
          'data': data ?? {},
        },
      );

      debugPrint('✅ Real notification sent successfully: ${response.data}');
    } catch (e) {
      debugPrint('❌ Error sending real notification: $e');
      rethrow;
    }
  }

  /// Test real notifications with different types
  static Future<void> testRealNotification(String type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No authenticated user for testing');
        return;
      }

      Map<String, dynamic> testData = {};

      switch (type) {
        case 'goal_created':
          testData = {
            'title': 'Master Flutter Development',
            'subject': 'Programming',
            'goalId': 'test-goal-${DateTime.now().millisecondsSinceEpoch}',
          };
          break;
        case 'goal_completed':
          testData = {
            'title': 'Complete Mathematics Course',
            'goalId': 'test-goal-${DateTime.now().millisecondsSinceEpoch}',
          };
          break;
        case 'goal_progress':
          testData = {
            'title': 'Learn Data Structures',
            'progress': 85,
            'goalId': 'test-goal-${DateTime.now().millisecondsSinceEpoch}',
          };
          break;
        case 'session_created':
          testData = {
            'title': 'Physics Study Session',
            'subject': 'Physics',
            'sessionId':
                'test-session-${DateTime.now().millisecondsSinceEpoch}',
          };
          break;
        case 'session_completed':
          testData = {
            'title': 'Chemistry Lab Work',
            'sessionId':
                'test-session-${DateTime.now().millisecondsSinceEpoch}',
          };
          break;
        case 'test':
          testData = {
            'message':
                'Hello from Athena! This is a real FCM test notification.',
          };
          break;
      }

      await sendRealNotification(type, data: testData);
    } catch (e) {
      debugPrint('❌ Test real notification failed: $e');
    }
  }
}
