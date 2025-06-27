-- Review System Database Schema
-- This migration creates the complete database structure for the Adaptive Review System feature
-- including quizzes, quiz_items tables with spaced repetition support, indexes, and RLS policies

-- Create enum types for quiz system
CREATE TYPE quiz_type AS ENUM ('flashcard', 'multipleChoice');
CREATE TYPE quiz_item_type AS ENUM ('flashcard', 'multipleChoice');
CREATE TYPE difficulty_rating AS ENUM ('again', 'hard', 'good', 'easy');
CREATE TYPE session_type AS ENUM ('mixed', 'dueOnly', 'newOnly');
CREATE TYPE session_status AS ENUM ('active', 'completed', 'abandoned');

-- Create quizzes table
CREATE TABLE public.quizzes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    quiz_type quiz_type NOT NULL DEFAULT 'flashcard', -- Type of quiz (flashcard or multiple choice)
    study_material_id UUID REFERENCES public.study_materials(id) ON DELETE SET NULL,
    subject subject, -- Optional subject for categorization (enum defined in separate migration)
    description TEXT, -- Optional description for additional context
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Constraints
    CONSTRAINT quizzes_title_not_empty CHECK (LENGTH(TRIM(title)) > 0),
    CONSTRAINT quizzes_title_length CHECK (LENGTH(title) <= 200),
    CONSTRAINT quizzes_description_length CHECK (description IS NULL OR LENGTH(description) <= 500)
);

-- Create quiz_items table with spaced repetition fields
CREATE TABLE public.quiz_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Basic quiz item fields
    item_type quiz_item_type NOT NULL DEFAULT 'flashcard',
    question_text TEXT NOT NULL,
    answer_text TEXT NOT NULL,
    
    -- Multiple choice specific fields (nullable for flashcards)
    mcq_options JSONB,
    mcq_correct_option_key TEXT,
    
    -- Spaced repetition algorithm fields
    easiness_factor NUMERIC(3,2) DEFAULT 2.5 NOT NULL,
    interval_days INTEGER DEFAULT 0 NOT NULL,
    repetitions INTEGER DEFAULT 0 NOT NULL,
    last_reviewed_at TIMESTAMPTZ,
    next_review_date DATE,
    
    -- Metadata and timestamps
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
      -- Constraints
    CONSTRAINT quiz_items_question_not_empty CHECK (LENGTH(TRIM(question_text)) > 0),
    CONSTRAINT quiz_items_answer_required_for_flashcard CHECK (
        (item_type = 'flashcard' AND LENGTH(TRIM(answer_text)) > 0)
        OR
        (item_type = 'multipleChoice')
    ),
    CONSTRAINT quiz_items_question_length CHECK (LENGTH(question_text) <= 1000),
    CONSTRAINT quiz_items_answer_length CHECK (LENGTH(answer_text) <= 2000),
    CONSTRAINT quiz_items_easiness_factor_range CHECK (easiness_factor >= 1.3 AND easiness_factor <= 3.0),
    CONSTRAINT quiz_items_interval_days_positive CHECK (interval_days >= 0),
    CONSTRAINT quiz_items_repetitions_positive CHECK (repetitions >= 0),

    -- MCQ specific constraints
    CONSTRAINT quiz_items_mcq_options_required 
        CHECK (
            (item_type = 'multipleChoice' AND mcq_options IS NOT NULL AND mcq_correct_option_key IS NOT NULL) 
            OR 
            (item_type = 'flashcard' AND mcq_options IS NULL AND mcq_correct_option_key IS NULL)
        ),
    CONSTRAINT quiz_items_mcq_options_structure 
        CHECK (
            mcq_options IS NULL 
            OR 
            jsonb_typeof(mcq_options) = 'object'
        )
);

-- Create review_sessions table to track review performance
CREATE TABLE public.review_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE CASCADE,
      -- Session metadata
    session_type session_type DEFAULT 'mixed' NOT NULL,
    total_items INTEGER DEFAULT 0 NOT NULL,
    completed_items INTEGER DEFAULT 0 NOT NULL,
    correct_responses INTEGER DEFAULT 0 NOT NULL,
    
    -- Performance metrics
    average_difficulty NUMERIC(2,1), -- Average difficulty rating (1-4 scale)
    session_duration_seconds INTEGER,
    
    -- Session status and timestamps
    status session_status DEFAULT 'active' NOT NULL,
    started_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    completed_at TIMESTAMPTZ,
      -- Constraints
    CONSTRAINT review_sessions_total_items_positive CHECK (total_items >= 0),
    CONSTRAINT review_sessions_completed_items_valid CHECK (completed_items >= 0 AND completed_items <= total_items),
    CONSTRAINT review_sessions_correct_responses_valid CHECK (correct_responses >= 0 AND correct_responses <= completed_items),
    CONSTRAINT review_sessions_average_difficulty_range CHECK (average_difficulty IS NULL OR (average_difficulty >= 1.0 AND average_difficulty <= 4.0)),
    CONSTRAINT review_sessions_duration_positive CHECK (session_duration_seconds IS NULL OR session_duration_seconds >= 0),
    CONSTRAINT review_sessions_completion_consistency CHECK (
        (status = 'completed' AND completed_at IS NOT NULL) 
        OR 
        (status != 'completed' AND (completed_at IS NULL OR completed_at = started_at))
    )
);

-- Create review_responses table to track individual item responses
CREATE TABLE public.review_responses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    session_id UUID NOT NULL REFERENCES public.review_sessions(id) ON DELETE CASCADE,
    quiz_item_id UUID NOT NULL REFERENCES public.quiz_items(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Response data
    difficulty_rating difficulty_rating NOT NULL,
    response_time_seconds INTEGER,
    user_answer TEXT, -- For MCQ: the selected option key, for flashcard: can be null
    is_correct BOOLEAN, -- For flashcards: based on self-assessment, for MCQ: automatic
    
    -- Previous spaced repetition values (for history/analytics)
    previous_easiness_factor NUMERIC(3,2),
    previous_interval_days INTEGER,
    previous_repetitions INTEGER,
    
    -- New spaced repetition values (calculated after this response)
    new_easiness_factor NUMERIC(3,2),
    new_interval_days INTEGER,
    new_repetitions INTEGER,
    new_next_review_date DATE,
    
    -- Timestamps
    responded_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Constraints
    CONSTRAINT review_responses_response_time_positive CHECK (response_time_seconds IS NULL OR response_time_seconds >= 0),
    CONSTRAINT review_responses_previous_ef_range CHECK (previous_easiness_factor IS NULL OR (previous_easiness_factor >= 1.3 AND previous_easiness_factor <= 3.0)),
    CONSTRAINT review_responses_new_ef_range CHECK (new_easiness_factor IS NULL OR (new_easiness_factor >= 1.3 AND new_easiness_factor <= 3.0)),
    CONSTRAINT review_responses_previous_interval_positive CHECK (previous_interval_days IS NULL OR previous_interval_days >= 0),
    CONSTRAINT review_responses_new_interval_positive CHECK (new_interval_days IS NULL OR new_interval_days >= 0),
    CONSTRAINT review_responses_previous_reps_positive CHECK (previous_repetitions IS NULL OR previous_repetitions >= 0),
    CONSTRAINT review_responses_new_reps_positive CHECK (new_repetitions IS NULL OR new_repetitions >= 0)
);

-- Create indexes for performance optimization
-- Primary performance indexes for spaced repetition queries
CREATE INDEX idx_quiz_items_next_review_date ON public.quiz_items(next_review_date) 
    WHERE next_review_date IS NOT NULL;

CREATE INDEX idx_quiz_items_user_next_review ON public.quiz_items(user_id, next_review_date) 
    WHERE next_review_date IS NOT NULL;

CREATE INDEX idx_quiz_items_quiz_user ON public.quiz_items(quiz_id, user_id);

-- Indexes for quiz management
CREATE INDEX idx_quizzes_user_updated ON public.quizzes(user_id, updated_at DESC);
CREATE INDEX idx_quizzes_quiz_type ON public.quizzes(quiz_type);
CREATE INDEX idx_quizzes_study_material ON public.quizzes(study_material_id) 
    WHERE study_material_id IS NOT NULL;
CREATE INDEX idx_quizzes_subject ON public.quizzes(user_id, subject) 
    WHERE subject IS NOT NULL;

-- Indexes for review sessions and analytics
CREATE INDEX idx_review_sessions_user_started ON public.review_sessions(user_id, started_at DESC);
CREATE INDEX idx_review_sessions_status ON public.review_sessions(user_id, status);
CREATE INDEX idx_review_responses_session ON public.review_responses(session_id, responded_at);
CREATE INDEX idx_review_responses_quiz_item ON public.review_responses(quiz_item_id, responded_at DESC);
CREATE INDEX idx_review_responses_user_date ON public.review_responses(user_id, responded_at DESC);

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at timestamps
CREATE TRIGGER update_quizzes_updated_at 
    BEFORE UPDATE ON public.quizzes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quiz_items_updated_at 
    BEFORE UPDATE ON public.quiz_items 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
-- Enable RLS on all tables
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.review_responses ENABLE ROW LEVEL SECURITY;

-- RLS Policies for quizzes table
CREATE POLICY "Users can view their own quizzes" ON public.quizzes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own quizzes" ON public.quizzes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quizzes" ON public.quizzes
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own quizzes" ON public.quizzes
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for quiz_items table
CREATE POLICY "Users can view their own quiz items" ON public.quiz_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own quiz items" ON public.quiz_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own quiz items" ON public.quiz_items
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own quiz items" ON public.quiz_items
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for review_sessions table
CREATE POLICY "Users can view their own review sessions" ON public.review_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own review sessions" ON public.review_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own review sessions" ON public.review_sessions
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own review sessions" ON public.review_sessions
    FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for review_responses table
CREATE POLICY "Users can view their own review responses" ON public.review_responses
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own review responses" ON public.review_responses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own review responses" ON public.review_responses
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own review responses" ON public.review_responses
    FOR DELETE USING (auth.uid() = user_id);

-- Essential database performance optimizations for review system queries
CREATE INDEX IF NOT EXISTS idx_quiz_items_easiness_factor ON quiz_items(user_id, easiness_factor);
CREATE INDEX IF NOT EXISTS idx_review_responses_user_responded ON review_responses(user_id, responded_at);
CREATE INDEX IF NOT EXISTS idx_review_sessions_completed_status ON review_sessions(user_id, status, completed_at) WHERE status = 'completed';

-- Create a function to validate MCQ options format (data validation only)
CREATE OR REPLACE FUNCTION validate_mcq_options(options JSONB)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if it's a JSON object
    IF jsonb_typeof(options) != 'object' THEN
        RETURN FALSE;
    END IF;
    
    -- Check if it has at least 2 options
    IF jsonb_array_length(jsonb_object_keys(options)) < 2 THEN
        RETURN FALSE;
    END IF;
    
    -- Check if all values are strings (option text)
    IF NOT (
        SELECT bool_and(jsonb_typeof(value) = 'string')
        FROM jsonb_each(options)
    ) THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON FUNCTION validate_mcq_options(JSONB) TO authenticated;

-- Comments for documentation
COMMENT ON TABLE public.quizzes IS 'Stores quiz collections created by users, optionally linked to study materials. Subject and description provide categorization for standalone quizzes';
COMMENT ON TABLE public.quiz_items IS 'Individual quiz items (flashcards, MCQs) with spaced repetition metadata';
COMMENT ON TABLE public.review_sessions IS 'Tracks review session metadata and performance metrics';
COMMENT ON TABLE public.review_responses IS 'Records individual responses during review sessions with spaced repetition calculations';
COMMENT ON FUNCTION validate_mcq_options IS 'Validates MCQ options JSON format for data integrity';

-- Log completion
SELECT 'Review system database schema and optimizations applied successfully' as status;
