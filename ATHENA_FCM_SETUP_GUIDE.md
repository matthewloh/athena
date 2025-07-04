# 🔥 Athena FCM Push Notifications & Enhanced Chatbot Setup Guide

## 🎯 **Overview**

This guide will help you set up Firebase Cloud Messaging (FCM) for push notifications and enhanced chatbot features in your Athena study companion app.

## 📋 **Prerequisites**

- Firebase project created and configured
- Firebase service account key
- Supabase project with Edge Functions enabled

## 🛠️ **Step 1: Apply Database Migration (Using Supabase CLI)**

```bash
# Navigate to your project root
cd project_athena/athena

# Apply the migration
supabase db push

# Or check migration status first
supabase migration list
```

The migration includes:

- ✅ Enhanced chatbot features (metadata, attachments, tool_calls)
- ✅ FCM token column in profiles table
- ✅ Notification history tracking
- ✅ Proper indexes and RLS policies

## 🚀 **Step 2: Deploy Edge Functions**

```bash
# Deploy the push notifications function
supabase functions deploy push-notifications

# Deploy enhanced chatbot functions
supabase functions deploy chat-stream-vision
supabase functions deploy chat-stream-tools
```

## 🔐 **Step 3: Set Environment Variables**

Create a `.env.local` file in your project root:

```env
# Firebase Configuration (Required for FCM)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_ACCESS_TOKEN=your-firebase-access-token

# OpenAI/Gemini for enhanced chatbot (Optional)
OPENAI_API_KEY=your-openai-key
GOOGLE_AI_API_KEY=your-gemini-key
```

Deploy the secrets:

```bash
supabase secrets set --env-file .env.local
```

## 📡 **Step 4: Create Database Webhooks**

### For Study Goals Notifications:

1. Go to your Supabase Dashboard → Database → Webhooks
2. Click "Create a new hook"
3. **Name**: `study_goals_notifications`
4. **Table**: `study_goals`
5. **Events**: Check `Insert`, `Update`
6. **Type**: `Supabase Edge Functions`
7. **Edge Function**: `push-notifications`
8. **HTTP Method**: `POST`
9. **HTTP Headers**:
   - Add auth header with service key
   - Content-Type: `application/json`

### For Study Sessions Notifications:

1. Create another webhook with same settings
2. **Name**: `study_sessions_notifications`
3. **Table**: `study_sessions`
4. **Events**: Check `Insert`, `Update`
5. Same configuration as above

## 📱 **Step 5: Update Flutter App**

### Add Firebase Configuration Files:

- Place `google-services.json` in `android/app/`
- Place `GoogleService-Info.plist` in `ios/Runner/`

### Update Android Configuration:

In `android/app/build.gradle`, ensure you have:

```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

In `android/app/src/main/AndroidManifest.xml`, add:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.VIBRATE" />

<!-- FCM -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

<application>
    <!-- FCM Service -->
    <service
        android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>

    <!-- Notification channel -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="athena_study_reminders" />
</application>
```

## 🧪 **Step 6: Test the Setup**

### Test FCM Token Registration:

1. Run your Flutter app: `flutter run`
2. Sign in with a user account
3. Check the logs for: `✅ FCM token saved to Supabase`
4. Verify in Supabase Dashboard → Table Editor → profiles → fcm_token column

### Test Push Notifications:

1. In Supabase Dashboard → Table Editor → study_goals
2. Insert a new goal for your test user
3. You should receive a push notification: "🎯 New Study Goal Created!"

### Test Enhanced Chatbot:

1. Use the chatbot with image uploads
2. Ask questions that trigger Wikipedia searches
3. Check chat_messages table for metadata and tool_calls data

### Test from Command Line:

```bash
# Test push notification
curl -X POST "https://your-project-ref.supabase.co/functions/v1/push-notifications" \
  -H "Authorization: Bearer YOUR_SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "INSERT",
    "table": "study_goals",
    "record": {
      "id": "test-id",
      "user_id": "your-user-id",
      "title": "Test Goal",
      "subject": "Mathematics",
      "progress": 0,
      "is_completed": false
    }
  }'

# Test enhanced chatbot with tools
curl -X POST "https://your-project-ref.supabase.co/functions/v1/chat-stream-tools" \
  -H "Authorization: Bearer YOUR_SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "conversationId": "your-conversation-id",
    "message": "Tell me about quantum physics",
    "enableTools": true
  }'
```

## 🔧 **Troubleshooting**

### Migration Issues:

```bash
# Check migration status
supabase migration list

# Manually apply if needed
supabase db push

# Check database schema
supabase db diff
```

### No FCM Token Saved:

- Check if Firebase is properly initialized in `main.dart`
- Verify user is signed in when FCM initializes
- Check Flutter logs for FCM errors

### Notifications Not Received:

- Verify webhook is created and enabled
- Check Edge Function logs in Supabase Dashboard
- Ensure Firebase service account has correct permissions
- Verify FCM token exists in profiles table

### Enhanced Chatbot Issues:

- Check if OpenAI/Gemini API keys are set
- Verify Edge Functions are deployed correctly
- Check function logs for errors

## 📊 **Monitoring**

### Check Edge Function Logs:

```bash
supabase functions logs push-notifications
supabase functions logs chat-stream-tools
supabase functions logs chat-stream-vision
```

### Check Database Changes:

```bash
# View recent migrations
supabase migration list

# Check table structure
supabase db dump --schema-only
```

### Monitor FCM Delivery:

- Firebase Console → Cloud Messaging → Reports
- Check delivery rates and error rates

## 🎉 **Success!**

Your Athena app now has:

- ✅ FCM push notifications for study goals and sessions
- ✅ Enhanced chatbot with image conversations
- ✅ AI tool calling with Wikipedia integration
- ✅ Automatic token management and cleanup
- ✅ Rich notification content with emojis and data
- ✅ Cross-platform support (Android/iOS)
- ✅ Real-time webhook integration
- ✅ Proper database schema with RLS policies

Users will now receive notifications when they:

- 🎯 Create new study goals
- 📈 Update goal progress
- 🎉 Complete goals
- 📅 Schedule study sessions
- ✅ Complete study sessions

And they can now:

- 📸 Chat with images for homework help
- 🔍 Get Wikipedia information through AI tools
- 🤖 Experience enhanced AI conversations

## 🚀 **Next Steps**

Consider adding:

- 🔔 Scheduled reminders for upcoming sessions
- 📊 Weekly progress summary notifications
- 🏆 Achievement and milestone notifications
- 🤝 Social features (study buddy reminders)
- 📱 Local notifications for offline scenarios
- 📅 Google Calendar integration (planned for future release)

## 🏗️ **Future Enhancements**

When ready, you can add:

- Google Calendar sync for study sessions
- Advanced AI features like document analysis
- Voice conversations with the chatbot
- Collaborative study features
