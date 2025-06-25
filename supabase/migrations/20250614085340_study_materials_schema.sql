-- Study Materials Feature Database Schema
-- Migration: 20250614085340_study_materials_schema.sql

-- Create enum for subjects
CREATE TYPE subject AS ENUM (
  -- STEM Subjects
  'mathematics', 'physics', 'chemistry', 'biology', 'computerScience', 'engineering', 
  'statistics', 'dataScience', 'informationTechnology', 'cybersecurity',
  
  -- Languages & Literature
  'englishLiterature', 'englishLanguage', 'spanish', 'french', 'german', 'chinese', 
  'japanese', 'linguistics', 'creativeWriting',
  
  -- Social Sciences
  'history', 'geography', 'psychology', 'sociology', 'politicalScience', 'economics', 
  'anthropology', 'internationalRelations', 'philosophy', 'ethics',
  
  -- Business & Management
  'businessStudies', 'marketing', 'finance', 'accounting', 'management', 'humanResources', 
  'operationsManagement', 'entrepreneurship',
  
  -- Arts & Creative
  'art', 'music', 'drama', 'filmStudies', 'photography', 'graphicDesign', 'architecture',
  
  -- Health & Medical
  'medicine', 'nursing', 'publicHealth', 'nutrition', 'physicalEducation', 'sportsScience',
  
  -- Law & Legal Studies
  'law', 'criminalJustice', 'legalStudies',
  
  -- Environmental & Earth Sciences
  'environmentalScience', 'geology', 'climateScience', 'marineBiology',
  
  -- Education & Teaching
  'education', 'pedagogy', 'educationalPsychology'
);

-- Create enum for content types
CREATE TYPE content_type AS ENUM ('typedText', 'textFile', 'imageFile');

-- Create study_materials table
CREATE TABLE study_materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  subject subject,
  content_type content_type NOT NULL,
  original_content_text TEXT,
  file_storage_path TEXT,
  ocr_extracted_text TEXT,
  summary_text TEXT,
  has_ai_summary BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_study_materials_user_id ON study_materials(user_id);
CREATE INDEX idx_study_materials_subject ON study_materials(subject);
CREATE INDEX idx_study_materials_content_type ON study_materials(content_type);
CREATE INDEX idx_study_materials_created_at ON study_materials(created_at);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_study_materials_updated_at
  BEFORE UPDATE ON study_materials
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE study_materials ENABLE ROW LEVEL SECURITY;

-- Study materials policies
CREATE POLICY "Users can view their own study materials"
  ON study_materials FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own study materials"
  ON study_materials FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own study materials"
  ON study_materials FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own study materials"
  ON study_materials FOR DELETE
  USING (auth.uid() = user_id);
