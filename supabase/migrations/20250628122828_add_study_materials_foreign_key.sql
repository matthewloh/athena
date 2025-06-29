-- Add foreign key constraint for linked_material_id in study_sessions table
-- This migration runs after study_materials table is created

-- Check if constraint already exists before adding it
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'study_sessions_linked_material_id_fkey'
    AND table_name = 'study_sessions'
    AND constraint_type = 'FOREIGN KEY'
  ) THEN
    ALTER TABLE study_sessions 
    ADD CONSTRAINT study_sessions_linked_material_id_fkey 
    FOREIGN KEY (linked_material_id) REFERENCES study_materials(id) ON DELETE SET NULL;
  END IF;
END $$;
