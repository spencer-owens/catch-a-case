-- Drop all existing agent-related policies
DROP POLICY IF EXISTS "Agents can update their assigned cases" ON public.cases;
DROP POLICY IF EXISTS "Agents can view all cases" ON public.cases;

-- Recreate the view policy
CREATE POLICY "Agents can view all cases"
  ON public.cases 
  FOR SELECT
  USING (is_agent());

-- Create new update policy with proper restrictions
CREATE POLICY "Agents can update their assigned cases"
  ON public.cases 
  FOR UPDATE
  TO public
  USING (
    is_agent() 
    AND assigned_agent_id = auth.uid()
  )
  WITH CHECK (
    is_agent() 
    AND assigned_agent_id = auth.uid()
  ); 