# 🔥 Firebase FCM with JWT Authentication Setup Guide

## 🎯 Overview

This guide will help you set up the `fcm-notifications-jwt` Supabase Edge Function with proper Firebase service account authentication for sending FCM notifications.

## 📋 Prerequisites

- Firebase project created
- Athena app configured with Firebase
- FCM tokens being stored in your Supabase `profiles` table

## 🔧 Step 1: Create Firebase Service Account

### 1.1 Access Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **Athena project**
3. Click the **gear icon** ⚙️ → **Project Settings**

### 1.2 Generate Service Account Key
1. Navigate to **Service Accounts** tab
2. Click **Generate new private key**
3. Click **Generate key** (this downloads a JSON file)
4. **⚠️ Keep this file secure!** It contains sensitive credentials

### 1.3 Verify Service Account Permissions
Ensure your service account has these roles:
- **Firebase Cloud Messaging Admin**
- **Firebase Admin SDK Administrator Service Agent**

## 📁 Step 2: Configure Service Account File

### 2.1 Rename and Move File
1. Rename the downloaded file to `service-account.json`
2. Place it in: `supabase/functions/fcm-notifications-jwt/service-account.json`

### 2.2 Verify File Structure
Your service account JSON should look like this:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com",
  "client_id": "123456789...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/...",
  "universe_domain": "googleapis.com"
}
```

### 2.3 Security Note
**⚠️ IMPORTANT**: Add `service-account.json` to your `.gitignore` file:
```gitignore
# Firebase Service Account (contains sensitive keys)
supabase/functions/*/service-account.json
```

## 🚀 Step 3: Deploy Edge Function

### 3.1 Deploy Function
```bash
# From your project root
supabase functions deploy fcm-notifications-jwt
```

### 3.2 Verify Deployment
Check the Supabase Dashboard → Edge Functions to confirm deployment.

## 🧪 Step 4: Test the Function

### 4.1 Test via Flutter App
1. Run your Athena app in **debug mode**
2. Go to the **Home Screen**
3. Look for **two notification icons** in the AppBar:
   - 🔔 **Bell Icon**: Local simulation notifications
   - ☁️ **Cloud Upload Icon**: Real FCM notifications via Edge Function
4. Tap the **cloud upload icon**
5. Choose a notification type to test

### 4.2 Test via Supabase Dashboard
Navigate to Edge Functions → `fcm-notifications-jwt` → Invoke with:
```json
{
  "user_id": "your-user-id",
  "type": "test",
  "title": "",
  "body": "",
  "data": {
    "message": "Hello from Supabase!"
  }
}
```

## 🔍 Step 5: Verify Everything Works

### 5.1 Check Logs
Monitor logs in:
- **Supabase Dashboard**: Edge Functions → fcm-notifications-jwt → Logs
- **Flutter Console**: Look for debug messages

### 5.2 Expected Log Messages
```
🔥 Athena FCM Notifications (JWT) Function Started!
📨 Processing notification request: {...}
🎯 Found FCM token for user: xxx
🔑 Generated access token successfully
✅ Notification sent successfully: {...}
```

### 5.3 Common Issues & Solutions

**❌ "Invalid service account"**
- Verify `service-account.json` file format
- Check if the file is properly uploaded
- Ensure service account has FCM permissions

**❌ "No FCM token found"**
- Check if user is authenticated
- Verify FCM token is stored in `profiles` table
- Test with a user who has granted notification permissions

**❌ "FCM send failed: 401"**
- Service account permissions issue
- Regenerate service account key
- Verify project ID matches

**❌ "Function not found"**
- Redeploy the function: `supabase functions deploy fcm-notifications-jwt`
- Check function name in Flutter code matches deployment

## 🔄 Step 6: Integration with App Features

### 6.1 Automatic Webhooks (Optional)
To trigger notifications automatically when data changes:

1. Create database webhooks in Supabase Dashboard
2. Set webhook URL to: `https://your-project.supabase.co/functions/v1/fcm-notifications-jwt`
3. Configure for tables: `study_goals`, `study_sessions`
4. Set events: `INSERT`, `UPDATE`

### 6.2 Manual Triggers
Use the Flutter interface or call the function directly:
```dart
await FCMService.sendRealNotification('goal_completed', data: {
  'title': 'Mathematics Mastery',
  'goalId': 'goal-123'
});
```

## 📱 Step 7: Production Deployment

### 7.1 Environment Variables
For production, consider using Supabase secrets instead of JSON files:
1. Go to Supabase Dashboard → Settings → API
2. Add secrets for sensitive values
3. Update function to use `Deno.env.get('SECRET_NAME')`

### 7.2 Security Checklist
- ✅ Service account JSON not in version control
- ✅ Function deployed and working
- ✅ FCM tokens properly managed
- ✅ Error handling implemented
- ✅ Notification history logging (optional)

## 🎉 Success!

Your FCM notification system with JWT authentication is now ready! Users will receive:
- **Real FCM notifications** from your backend
- **Beautiful in-app overlays** when app is in foreground
- **System notifications** when app is in background/terminated

## 📚 Additional Resources

- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [FCM HTTP v1 API](https://firebase.google.com/docs/cloud-messaging/http-server-ref)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)

---

**Your notification system is production-ready! 🚀** 