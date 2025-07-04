-- Enhanced Chatbot Features and FCM Support
-- Generated: 2025-01-20
-- Purpose: Add image conversations, tool calling, and push notifications

BEGIN;

-- ========================================
-- Enhanced Chatbot Features
-- ========================================

-- Update chat_messages table to support enhanced features
ALTER TABLE chat_messages 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT NULL,
ADD COLUMN IF NOT EXISTS has_attachments BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tool_calls JSONB DEFAULT NULL;

-- Add indexes for enhanced chatbot features
CREATE INDEX IF NOT EXISTS idx_chat_messages_metadata 
    ON chat_messages USING GIN(metadata) 
    WHERE metadata IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_chat_messages_attachments 
    ON chat_messages(conversation_id) 
    WHERE has_attachments = true;

-- ========================================
-- FCM Push Notifications
-- ========================================

-- Add FCM token to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- Add index for FCM token lookups
CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token 
    ON profiles(fcm_token) 
    WHERE fcm_token IS NOT NULL;

-- Create notification history table
CREATE TABLE IF NOT EXISTS notification_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'goal_created', 
        'goal_completed', 
        'goal_progress', 
        'goal_deleted', 
        'session_created', 
        'session_completed', 
        'session_rescheduled', 
        'session_cancelled'
    )),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}',
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT
);

-- ========================================
-- Row Level Security Policies
-- ========================================

-- RLS for notification history
ALTER TABLE notification_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notification history" ON notification_history
    FOR SELECT USING (auth.uid() = user_id);

-- ========================================
-- Indexes and Performance
-- ========================================

-- Index for notification history queries
CREATE INDEX IF NOT EXISTS idx_notification_history_user_type 
    ON notification_history(user_id, type);

CREATE INDEX IF NOT EXISTS idx_notification_history_sent_at 
    ON notification_history(user_id, sent_at DESC);

-- ========================================
-- Real-time Subscriptions
-- ========================================

-- Enable real-time for notification history
ALTER PUBLICATION supabase_realtime ADD TABLE notification_history;

-- ========================================
-- Comments for Documentation
-- ========================================

COMMENT ON COLUMN chat_messages.metadata IS 'JSON metadata for enhanced features like image URLs, tool results';
COMMENT ON COLUMN chat_messages.has_attachments IS 'Boolean flag indicating if message has file attachments';
COMMENT ON COLUMN chat_messages.tool_calls IS 'JSON array of AI tool calls made during message processing';
COMMENT ON COLUMN profiles.fcm_token IS 'Firebase Cloud Messaging token for push notifications';
COMMENT ON TABLE notification_history IS 'History of all push notifications sent to users';

COMMIT;
