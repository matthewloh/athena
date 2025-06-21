-- Create the study-materials storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'study-materials',
  'study-materials',
  false, -- Set to false for private access, users can only access their own files  10485760, -- 10MB file size limit
  ARRAY[
    'text/plain', 
    'application/pdf', 
    'image/jpeg', 
    'image/png', 
    'image/jpg', 
    'image/webp',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document', -- .docx files
    'application/msword' -- .doc files
  ]
) ON CONFLICT (id) DO NOTHING;

-- Create RLS policies for the study-materials bucket
-- Allow users to upload files to their own directory (userId/*)
CREATE POLICY "Users can upload to their own directory" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'study-materials' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to view/download files from their own directory
CREATE POLICY "Users can view their own files" ON storage.objects
FOR SELECT USING (
  bucket_id = 'study-materials' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to update files in their own directory
CREATE POLICY "Users can update their own files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'study-materials' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete files in their own directory
CREATE POLICY "Users can delete their own files" ON storage.objects
FOR DELETE USING (
  bucket_id = 'study-materials' AND 
  (storage.foldername(name))[1] = auth.uid()::text
);
