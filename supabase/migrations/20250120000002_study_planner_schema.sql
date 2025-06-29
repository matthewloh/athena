-- Study Planner Feature Database Schema
-- Migration: 20250120000002_study_planner_schema.sql

-- Create enum for study session status
CREATE TYPE study_session_status AS ENUM (
  'scheduled',
  'inProgress', 
  'completed',
  'missed',
  'cancelled'
);

-- Create study_goals table
CREATE TABLE study_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  subject TEXT,
  target_date DATE,
  progress DECIMAL(3,2) NOT NULL DEFAULT 0.0 CHECK (progress >= 0.0 AND progress <= 1.0),
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create study_sessions table
CREATE TABLE study_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  study_goal_id UUID REFERENCES study_goals(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  subject TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  status study_session_status NOT NULL DEFAULT 'scheduled',
  reminder_offset_minutes INTEGER,
  notes TEXT,
  actual_duration_minutes INTEGER,
  linked_material_id UUID, -- Will be updated to reference study_materials after that table is created
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  
  -- Ensure start_time is before end_time
  CONSTRAINT valid_session_time CHECK (start_time < end_time),
  
  -- Ensure actual_duration_minutes is positive if set
  CONSTRAINT valid_actual_duration CHECK (actual_duration_minutes IS NULL OR actual_duration_minutes > 0),
  
  -- Ensure reminder_offset_minutes is positive if set
  CONSTRAINT valid_reminder_offset CHECK (reminder_offset_minutes IS NULL OR reminder_offset_minutes > 0)
);

-- Create indexes for better query performance
CREATE INDEX idx_study_goals_user_id ON study_goals(user_id);
CREATE INDEX idx_study_goals_target_date ON study_goals(target_date);
CREATE INDEX idx_study_goals_subject ON study_goals(subject);
CREATE INDEX idx_study_goals_is_completed ON study_goals(is_completed);

CREATE INDEX idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX idx_study_sessions_study_goal_id ON study_sessions(study_goal_id);
CREATE INDEX idx_study_sessions_start_time ON study_sessions(start_time);
CREATE INDEX idx_study_sessions_end_time ON study_sessions(end_time);
CREATE INDEX idx_study_sessions_status ON study_sessions(status);
CREATE INDEX idx_study_sessions_subject ON study_sessions(subject);

-- Create updated_at trigger function (reuse existing if available)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_study_goals_updated_at
  BEFORE UPDATE ON study_goals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_study_sessions_updated_at
  BEFORE UPDATE ON study_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE study_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;

-- Study goals policies
CREATE POLICY "Users can view their own study goals"
  ON study_goals FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own study goals"
  ON study_goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own study goals"
  ON study_goals FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own study goals"
  ON study_goals FOR DELETE
  USING (auth.uid() = user_id);

-- Study sessions policies
CREATE POLICY "Users can view their own study sessions"
  ON study_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own study sessions"
  ON study_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own study sessions"
  ON study_sessions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own study sessions"
  ON study_sessions FOR DELETE
  USING (auth.uid() = user_id); 