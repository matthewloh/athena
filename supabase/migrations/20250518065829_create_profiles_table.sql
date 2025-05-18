CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  preferred_subjects TEXT[], -- Array of text for preferred subjects
  updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles table
CREATE POLICY "Users can select their own profile."
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile."
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile."
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Optional: Allow service_role to bypass RLS (useful for admin operations or server-side logic)
CREATE POLICY "Allow all access for service_role"
  ON public.profiles FOR ALL
  USING (current_setting('request.role', true) = 'service_role')
  WITH CHECK (current_setting('request.role', true) = 'service_role');