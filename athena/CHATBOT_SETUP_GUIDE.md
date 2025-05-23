# Athena Chatbot - Quick Setup Guide

## Prerequisites

1. **Supabase CLI** installed and configured
2. **OpenAI API Key** (for AI responses)
3. **Flutter** development environment
4. **Docker** (for local Supabase)

## Step 1: Database Setup

### Apply the Database Migration
```bash
cd athena_project
supabase start
supabase db reset  # This will apply all migrations including the new chatbot schema
```

### Verify Tables Created
```sql
-- Check if tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('conversations', 'chat_messages');
```

## Step 2: Edge Function Deployment

### Deploy the Chat Stream Function
```bash
# Deploy the function
supabase functions deploy chat-stream

# Set the OpenAI API key
supabase secrets set OPENAI_API_KEY=your_openai_api_key_here
```

### Test the Edge Function
```bash
# Get your JWT token from Supabase Studio
# Then test the function
curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/chat-stream' \
  --header 'Authorization: Bearer YOUR_JWT_TOKEN' \
  --header 'Content-Type: application/json' \
  --data '{
    "conversationId": "test-conversation-id",
    "message": "Hello, can you help me with math?",
    "includeContext": false
  }'
```

## Step 3: Flutter App Configuration

### Update Environment Variables
```json
// athena/env.local.json
{
  "SUPABASE_URL": "http://127.0.0.1:54321",
  "SUPABASE_ANON_KEY": "your_anon_key_from_supabase_start"
}
```

### Install Dependencies
```bash
cd athena
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Step 4: Testing the Implementation

### Create a Test Conversation
1. **Start the Flutter app**:
   ```bash
   flutter run --dart-define-from-file=env.local.json
   ```

2. **Navigate to the Chatbot screen**
3. **Create a new conversation** using the "Start New Conversation" button
4. **Send a test message** and verify AI response streaming

### Manual Database Testing
```sql
-- Create a test conversation
INSERT INTO conversations (user_id, title) 
VALUES ('your-user-id', 'Test Conversation')
RETURNING id;

-- Insert a test message
INSERT INTO chat_messages (conversation_id, sender, content)
VALUES ('conversation-id-from-above', 'user', 'Hello AI!');

-- Check if trigger updated conversation
SELECT * FROM conversations WHERE id = 'conversation-id-from-above';
```

## Step 5: Troubleshooting

### Common Issues

#### 1. Edge Function Not Working
```bash
# Check function logs
supabase functions logs chat-stream

# Verify environment variables
supabase secrets list
```

#### 2. Database Connection Issues
```bash
# Check Supabase status
supabase status

# Reset if needed
supabase stop
supabase start
```

#### 3. Flutter Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### 4. Authentication Issues
- Ensure you're logged in to the app
- Check that RLS policies are correctly applied
- Verify JWT token is valid

### Debug Commands

#### Check Database Schema
```sql
-- List all tables
\dt

-- Describe conversations table
\d conversations

-- Describe chat_messages table
\d chat_messages

-- Check RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename IN ('conversations', 'chat_messages');
```

#### Test Edge Function Locally
```bash
# Run function locally for debugging
supabase functions serve chat-stream --env-file ./supabase/.env.local
```

## Step 6: Next Development Steps

### Immediate Tasks
1. **Test conversation creation flow**
2. **Verify message streaming works**
3. **Test real-time message updates**
4. **Check error handling**

### UI Improvements Needed
1. **Add conversation list sidebar**
2. **Improve message bubble styling**
3. **Add typing indicators**
4. **Implement conversation management**

### Backend Enhancements
1. **Add conversation search functionality**
2. **Implement message pagination**
3. **Add conversation statistics**
4. **Optimize database queries**

## Expected Behavior

### Working Features
- ✅ User authentication
- ✅ Conversation creation
- ✅ Message sending
- ✅ AI response streaming
- ✅ Real-time message updates
- ✅ Conversation persistence

### Known Limitations
- ⚠️ No conversation list UI yet
- ⚠️ Basic error handling
- ⚠️ No message retry functionality
- ⚠️ No conversation search
- ⚠️ No message pagination

## Performance Notes

### Expected Response Times
- **Message send**: < 500ms
- **AI response start**: < 2s
- **AI response complete**: 5-15s (depending on complexity)
- **Real-time updates**: < 500ms

### Resource Usage
- **Memory**: Monitor for memory leaks during long conversations
- **Network**: Streaming responses use minimal bandwidth
- **Database**: Queries are optimized with proper indexes

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Supabase logs: `supabase functions logs`
3. Check Flutter debug console for client-side errors
4. Verify environment variables are correctly set

## Next Steps

After confirming the basic functionality works:
1. **Implement conversation management UI** (Phase 3.1)
2. **Add advanced chat features** (Phase 3.2)
3. **Implement search functionality** (Phase 4.1)
4. **Add comprehensive testing** (Phase 5)

This setup provides a solid foundation for the complete chatbot implementation outlined in the improvement plan. 