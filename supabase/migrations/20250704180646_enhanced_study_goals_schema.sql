-- Enhanced Study Goals Schema
-- Add goal_type and priority_level to support the new StudyGoalForm features

-- Create goal_type enum
CREATE TYPE goal_type AS ENUM (
    'academic',
    'skills', 
    'career',
    'personal',
    'research'
);

-- Create priority_level enum  
CREATE TYPE priority_level AS ENUM (
    'high',
    'medium',
    'low'
);

-- Add new columns to study_goals table
ALTER TABLE study_goals 
ADD COLUMN goal_type goal_type DEFAULT 'academic',
ADD COLUMN priority_level priority_level DEFAULT 'medium';

-- Add helpful comments
COMMENT ON COLUMN study_goals.goal_type IS 'Type of study goal: academic, skills, career, personal, or research';
COMMENT ON COLUMN study_goals.priority_level IS 'Priority level: high, medium, or low';

-- Create indexes for better query performance
CREATE INDEX idx_study_goals_goal_type ON study_goals(goal_type);
CREATE INDEX idx_study_goals_priority_level ON study_goals(priority_level);
CREATE INDEX idx_study_goals_user_goal_type ON study_goals(user_id, goal_type);
CREATE INDEX idx_study_goals_user_priority ON study_goals(user_id, priority_level);
