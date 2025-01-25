-- Fix messages policies to properly handle admin viewing
BEGIN;

-- Drop existing SELECT policies
DROP POLICY IF EXISTS "Admins can view all messages" ON public.messages;
DROP POLICY IF EXISTS "Users can view case messages" ON public.messages;

-- Create new policies with clearer separation
CREATE POLICY "Admins can view all messages"
ON public.messages
FOR SELECT
TO authenticated
USING (is_admin());

CREATE POLICY "Agents can view case messages"
ON public.messages
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM cases
    WHERE cases.id = messages.case_id
    AND (cases.assigned_agent_id = auth.uid() OR is_agent())
  )
);

CREATE POLICY "Clients can view their case messages"
ON public.messages
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM cases
    WHERE cases.id = messages.case_id
    AND cases.client_id = auth.uid()
  )
);

COMMIT; 