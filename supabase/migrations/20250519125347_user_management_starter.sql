-- Create a table for public profiles
CREATE TABLE profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  updated_at TIMESTAMP WITH TIME ZONE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  website TEXT,

  CONSTRAINT username_length CHECK (char_length(username) >= 3)
);

-- Enable Row Level Security for profiles table
ALTER TABLE profiles
  ENABLE ROW LEVEL SECURITY;

-- Create policies for profiles table
CREATE POLICY "Public profiles are viewable by everyone." 
  ON profiles FOR SELECT 
  USING (true);

CREATE POLICY "Users can insert their own profile." 
  ON profiles FOR INSERT 
  WITH CHECK ((auth.uid() = id));

CREATE POLICY "Users can update their own profile." 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Create a secure function to handle new user signup
CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql;

-- Trigger the function every time a user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Set up storage bucket for avatars
INSERT INTO storage.buckets (id, name)
  VALUES ('avatars', 'avatars');

-- Create robust RLS policies for the avatars storage bucket - NO PUBLIC ACCESS

-- Allow only authenticated users to view avatars
CREATE POLICY "Authenticated users can view avatars"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'avatars' AND 
    auth.role() = 'authenticated'
  );

-- Allow users to upload their own avatars
CREATE POLICY "Authenticated users can upload avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated'
  );

-- Allow users to update only their own avatars
CREATE POLICY "Users can update their own avatars"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    owner = auth.uid()
  );

-- Allow users to delete only their own avatars
CREATE POLICY "Users can delete their own avatars"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated' AND
    owner = auth.uid()
  );