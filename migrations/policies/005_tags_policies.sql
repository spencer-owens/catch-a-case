-- Enable RLS on tags table
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can view tags" ON public.tags;
DROP POLICY IF EXISTS "Admins can manage tags" ON public.tags;

-- Create policies
-- Everyone can view tags
CREATE POLICY "Authenticated users can view tags" 
ON public.tags
FOR SELECT
TO authenticated
USING (true);

-- Only admins can manage tags
CREATE POLICY "Admins can manage tags"
ON public.tags
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin()); 