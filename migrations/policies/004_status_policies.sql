-- Enable RLS on statuses table
ALTER TABLE public.statuses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Authenticated users can view statuses" ON public.statuses;
DROP POLICY IF EXISTS "Agents can create statuses" ON public.statuses;
DROP POLICY IF EXISTS "Agents can update statuses" ON public.statuses;
DROP POLICY IF EXISTS "Admins can delete statuses" ON public.statuses;
DROP POLICY IF EXISTS "Admins can manage statuses" ON public.statuses;
DROP POLICY IF EXISTS "Statuses are viewable by everyone" ON public.statuses;

-- Create policies
-- Everyone can view statuses
CREATE POLICY "Authenticated users can view statuses" 
ON public.statuses
FOR SELECT
TO authenticated
USING (true);

-- Agents can create statuses
CREATE POLICY "Agents can create statuses"
ON public.statuses
FOR INSERT
TO authenticated
WITH CHECK (is_agent() OR is_admin());

-- Agents can update statuses
CREATE POLICY "Agents can update statuses"
ON public.statuses
FOR UPDATE
TO authenticated
USING (is_agent() OR is_admin())
WITH CHECK (is_agent() OR is_admin());

-- Only admins can delete statuses
CREATE POLICY "Admins can delete statuses"
ON public.statuses
FOR DELETE
TO authenticated
USING (is_admin()); 