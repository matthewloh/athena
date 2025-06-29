-- Create file_attachments table for chat messages
CREATE TABLE file_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_size BIGINT NOT NULL,
  mime_type TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  thumbnail_path TEXT,
  upload_status TEXT NOT NULL DEFAULT 'pending' CHECK (upload_status IN ('pending', 'uploading', 'completed', 'failed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE file_attachments ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to see their own file attachments
CREATE POLICY "Users can view their own file attachments" ON file_attachments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_messages cm
      JOIN conversations c ON cm.conversation_id = c.id
      WHERE cm.id = file_attachments.message_id
      AND c.user_id = auth.uid()
    )
  );

-- Policy to allow users to insert their own file attachments
CREATE POLICY "Users can insert their own file attachments" ON file_attachments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_messages cm
      JOIN conversations c ON cm.conversation_id = c.id
      WHERE cm.id = file_attachments.message_id
      AND c.user_id = auth.uid()
    )
  );

-- Policy to allow users to update their own file attachments
CREATE POLICY "Users can update their own file attachments" ON file_attachments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM chat_messages cm
      JOIN conversations c ON cm.conversation_id = c.id
      WHERE cm.id = file_attachments.message_id
      AND c.user_id = auth.uid()
    )
  );

-- Policy to allow users to delete their own file attachments
CREATE POLICY "Users can delete their own file attachments" ON file_attachments
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM chat_messages cm
      JOIN conversations c ON cm.conversation_id = c.id
      WHERE cm.id = file_attachments.message_id
      AND c.user_id = auth.uid()
    )
  );

-- Add index for performance
CREATE INDEX idx_file_attachments_message_id ON file_attachments(message_id);

-- Add has_attachments column to chat_messages for quick filtering
ALTER TABLE chat_messages ADD COLUMN IF NOT EXISTS has_attachments BOOLEAN DEFAULT FALSE;

-- Create function to update has_attachments when file_attachments are added/removed
CREATE OR REPLACE FUNCTION update_message_has_attachments()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE chat_messages 
    SET has_attachments = TRUE 
    WHERE id = NEW.message_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE chat_messages 
    SET has_attachments = (
      SELECT COUNT(*) > 0 
      FROM file_attachments 
      WHERE message_id = OLD.message_id
    )
    WHERE id = OLD.message_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER trigger_update_message_has_attachments_insert
  AFTER INSERT ON file_attachments
  FOR EACH ROW EXECUTE FUNCTION update_message_has_attachments();

CREATE TRIGGER trigger_update_message_has_attachments_delete
  AFTER DELETE ON file_attachments
  FOR EACH ROW EXECUTE FUNCTION update_message_has_attachments();

-- Create storage bucket for chat attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-attachments', 'chat-attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for chat attachments
CREATE POLICY "Users can upload their own chat attachments" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'chat-attachments' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view their own chat attachments" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'chat-attachments' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can update their own chat attachments" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'chat-attachments' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete their own chat attachments" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'chat-attachments' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
