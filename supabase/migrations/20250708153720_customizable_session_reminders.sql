-- Customizable Session Reminders System
-- Migration: 20250708153720_customizable_session_reminders.sql
-- Purpose: Advanced reminder system with templates and customizable timing

BEGIN;

-- ========================================
-- Enums and Types
-- ========================================

-- Create enum for reminder types
CREATE TYPE reminder_type AS ENUM (
  'session_reminder',
  'session_starting_soon',
  'session_overdue', 
  'goal_deadline_reminder',
  'study_streak_reminder',
  'daily_checkin',
  'evening_summary'
);

-- Create enum for reminder delivery status
CREATE TYPE reminder_delivery_status AS ENUM (
  'pending',
  'sent',
  'failed',
  'cancelled'
);

-- ========================================
-- Reminder Templates Table
-- ========================================

-- Predefined reminder templates for quick setup
CREATE TABLE reminder_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  offset_minutes INTEGER NOT NULL CHECK (offset_minutes > 0),
  message_template TEXT NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- Session Reminders Table
-- ========================================

-- Links study sessions to their reminder configurations
CREATE TABLE session_reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES study_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  template_id UUID REFERENCES reminder_templates(id) ON DELETE SET NULL,
  
  -- Reminder configuration
  offset_minutes INTEGER NOT NULL CHECK (offset_minutes > 0),
  custom_message TEXT, -- Override template message if provided
  is_enabled BOOLEAN DEFAULT TRUE,
  
  -- Delivery tracking
  scheduled_time TIMESTAMP WITH TIME ZONE, -- Calculated: session.start_time - offset_minutes
  delivery_status reminder_delivery_status DEFAULT 'pending',
  sent_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  notification_id UUID, -- Reference to notification_history.id
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
  
  -- Note: Complex time validation handled by trigger function
);

-- ========================================
-- User Reminder Preferences
-- ========================================

-- Default reminder preferences for users
CREATE TABLE user_reminder_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  
  -- Default reminders to auto-create for new sessions
  default_reminder_template_ids UUID[] DEFAULT '{}',
  
  -- Global notification settings
  notifications_enabled BOOLEAN DEFAULT TRUE,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  timezone TEXT DEFAULT 'Asia/Kuala_Lumpur',
  
  -- Notification preferences by type
  session_reminders_enabled BOOLEAN DEFAULT TRUE,
  goal_reminders_enabled BOOLEAN DEFAULT TRUE,
  daily_checkins_enabled BOOLEAN DEFAULT TRUE,
  streak_reminders_enabled BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- Enhanced Notification History
-- ========================================

-- Extend notification_history to support more reminder types
ALTER TABLE notification_history 
DROP CONSTRAINT IF EXISTS notification_history_type_check;

ALTER TABLE notification_history 
ADD CONSTRAINT notification_history_type_check 
CHECK (type IN (
  -- Existing types
  'goal_created', 
  'goal_completed', 
  'goal_progress', 
  'goal_deleted', 
  'session_created', 
  'session_completed', 
  'session_rescheduled', 
  'session_cancelled',
  -- New reminder types
  'session_reminder',
  'session_starting_soon', 
  'session_overdue',
  'goal_deadline_reminder',
  'study_streak_reminder',
  'daily_checkin',
  'evening_summary'
));

-- Add reminder-specific fields
ALTER TABLE notification_history 
ADD COLUMN IF NOT EXISTS session_reminder_id UUID REFERENCES session_reminders(id) ON DELETE SET NULL,
ADD COLUMN IF NOT EXISTS reminder_type reminder_type,
ADD COLUMN IF NOT EXISTS scheduled_for TIMESTAMP WITH TIME ZONE;

-- ========================================
-- Indexes for Performance
-- ========================================

-- Reminder templates indexes
CREATE INDEX idx_reminder_templates_active ON reminder_templates(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_reminder_templates_default ON reminder_templates(is_default) WHERE is_default = TRUE;

-- Session reminders indexes
CREATE INDEX idx_session_reminders_session_id ON session_reminders(session_id);
CREATE INDEX idx_session_reminders_user_id ON session_reminders(user_id);
CREATE INDEX idx_session_reminders_scheduled_time ON session_reminders(scheduled_time) WHERE delivery_status = 'pending';
CREATE INDEX idx_session_reminders_delivery_status ON session_reminders(delivery_status);
CREATE INDEX idx_session_reminders_enabled ON session_reminders(user_id, is_enabled) WHERE is_enabled = TRUE;

-- User preferences indexes
CREATE INDEX idx_user_reminder_preferences_notifications_enabled 
ON user_reminder_preferences(user_id) WHERE notifications_enabled = TRUE;

-- Enhanced notification history indexes
CREATE INDEX idx_notification_history_reminder_type ON notification_history(user_id, reminder_type);
CREATE INDEX idx_notification_history_session_reminder ON notification_history(session_reminder_id);
CREATE INDEX idx_notification_history_scheduled_for ON notification_history(scheduled_for);

-- ========================================
-- Functions and Triggers
-- ========================================

-- Function to calculate scheduled time for reminders
CREATE OR REPLACE FUNCTION calculate_reminder_scheduled_time()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate scheduled_time based on session start_time and offset_minutes
  IF NEW.session_id IS NOT NULL AND NEW.offset_minutes IS NOT NULL THEN
    SELECT start_time - INTERVAL '1 minute' * NEW.offset_minutes
    INTO NEW.scheduled_time
    FROM study_sessions
    WHERE id = NEW.session_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-calculate scheduled times
CREATE TRIGGER update_reminder_scheduled_time
  BEFORE INSERT OR UPDATE ON session_reminders
  FOR EACH ROW
  EXECUTE FUNCTION calculate_reminder_scheduled_time();

-- Function to create default reminders for new sessions
CREATE OR REPLACE FUNCTION create_default_session_reminders()
RETURNS TRIGGER AS $$
DECLARE
  template_id UUID;
  user_prefs RECORD;
BEGIN
  -- Get user preferences
  SELECT * INTO user_prefs 
  FROM user_reminder_preferences 
  WHERE user_id = NEW.user_id;
  
  -- If user has preferences and notifications are enabled
  IF user_prefs IS NOT NULL AND user_prefs.notifications_enabled AND user_prefs.session_reminders_enabled THEN
    -- Create reminders for each default template
    FOREACH template_id IN ARRAY user_prefs.default_reminder_template_ids
    LOOP
      INSERT INTO session_reminders (session_id, user_id, template_id, offset_minutes)
      SELECT NEW.id, NEW.user_id, rt.id, rt.offset_minutes
      FROM reminder_templates rt
      WHERE rt.id = template_id AND rt.is_active = TRUE;
    END LOOP;
  ELSE
    -- Create default 15-minute reminder if no preferences set
    INSERT INTO session_reminders (session_id, user_id, offset_minutes, custom_message)
    VALUES (NEW.id, NEW.user_id, 15, 'Your study session starts in 15 minutes!');
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-create default reminders for new sessions
CREATE TRIGGER create_default_reminders_for_session
  AFTER INSERT ON study_sessions
  FOR EACH ROW
  EXECUTE FUNCTION create_default_session_reminders();

-- Update triggers for updated_at
CREATE TRIGGER update_reminder_templates_updated_at
  BEFORE UPDATE ON reminder_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_session_reminders_updated_at
  BEFORE UPDATE ON session_reminders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_reminder_preferences_updated_at
  BEFORE UPDATE ON user_reminder_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- Row Level Security (RLS)
-- ========================================

-- Enable RLS
ALTER TABLE reminder_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_reminder_preferences ENABLE ROW LEVEL SECURITY;

-- Reminder templates policies (read-only for users, admin managed)
CREATE POLICY "Anyone can view active reminder templates"
  ON reminder_templates FOR SELECT
  USING (is_active = TRUE);

-- Session reminders policies
CREATE POLICY "Users can view their own session reminders"
  ON session_reminders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own session reminders"
  ON session_reminders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own session reminders"
  ON session_reminders FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own session reminders"
  ON session_reminders FOR DELETE
  USING (auth.uid() = user_id);

-- User reminder preferences policies
CREATE POLICY "Users can view their own reminder preferences"
  ON user_reminder_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own reminder preferences"
  ON user_reminder_preferences FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reminder preferences"
  ON user_reminder_preferences FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ========================================
-- Default Data
-- ========================================

-- Insert default reminder templates
INSERT INTO reminder_templates (name, description, offset_minutes, message_template, is_default) VALUES
('15 Minutes Before', 'Quick heads up before your session', 15, '⏰ "{session_title}" starts in 15 minutes!', TRUE),
('1 Hour Before', 'Time to wrap up and prepare', 60, '📚 "{session_title}" starts in 1 hour. Time to prepare!', TRUE),
('1 Day Before', 'Plan ahead for tomorrow', 1440, '📅 Reminder: "{session_title}" is scheduled for tomorrow at {session_time}', FALSE),
('5 Minutes Before', 'Last minute reminder', 5, '🚨 "{session_title}" starts in 5 minutes! Get ready!', FALSE),
('30 Minutes Before', 'Half hour warning', 30, '📖 "{session_title}" starts in 30 minutes. Finish up what you''re doing!', FALSE);

-- ========================================
-- Real-time Subscriptions
-- ========================================

-- Enable real-time for new tables
ALTER PUBLICATION supabase_realtime ADD TABLE session_reminders;
ALTER PUBLICATION supabase_realtime ADD TABLE user_reminder_preferences;

-- ========================================
-- Comments for Documentation
-- ========================================

COMMENT ON TABLE reminder_templates IS 'Predefined reminder templates with timing and message patterns';
COMMENT ON TABLE session_reminders IS 'Individual reminder configurations for study sessions';
COMMENT ON TABLE user_reminder_preferences IS 'User-specific notification preferences and default settings';

COMMENT ON COLUMN session_reminders.scheduled_time IS 'Auto-calculated time when reminder should be sent (session.start_time - offset_minutes)';
COMMENT ON COLUMN session_reminders.custom_message IS 'Override template message for this specific reminder';
COMMENT ON COLUMN user_reminder_preferences.default_reminder_template_ids IS 'Array of template IDs to auto-create for new sessions';
COMMENT ON COLUMN user_reminder_preferences.quiet_hours_start IS 'Start time for quiet hours (no notifications)';
COMMENT ON COLUMN user_reminder_preferences.quiet_hours_end IS 'End time for quiet hours (no notifications)';

COMMIT;
