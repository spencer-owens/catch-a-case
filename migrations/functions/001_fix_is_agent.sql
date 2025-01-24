-- Fix the is_agent() function to correctly check roles
CREATE OR REPLACE FUNCTION public.is_agent()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'agent'
  );
$$ LANGUAGE sql SECURITY DEFINER; 