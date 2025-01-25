-- Update message policies to allow admins to see all messages
BEGIN;

-- Drop ALL existing policies
DROP POLICY IF EXISTS "Users can view messages for their cases" ON public.messages;
DROP POLICY IF EXISTS "Users can create messages for their cases" ON public.messages;
DROP POLICY IF EXISTS "Users can update their messages" ON public.messages;
DROP POLICY IF EXISTS "Users can update their own messages" ON public.messages;
DROP POLICY IF EXISTS "Admins have full access to messages" ON public.messages;
DROP POLICY IF EXISTS "Users and admins can view messages" ON public.messages;
DROP POLICY IF EXISTS "Admins have full access" ON public.messages;

-- Create new policies with proper admin access
CREATE POLICY "Admins can view all messages"
ON public.messages
FOR SELECT
TO authenticated
USING (is_admin());

CREATE POLICY "Users can view case messages"
ON public.messages
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM cases
    WHERE cases.id = messages.case_id
    AND (
      cases.client_id = auth.uid() OR 
      cases.assigned_agent_id = auth.uid() OR 
      is_agent()
    )
  )
);

CREATE POLICY "Users can create messages for their cases"
ON public.messages
FOR INSERT
TO authenticated
WITH CHECK (
  (
    EXISTS (
      SELECT 1 FROM cases
      WHERE cases.id = case_id
      AND (
        cases.client_id = auth.uid() OR 
        cases.assigned_agent_id = auth.uid() OR 
        is_agent()
      )
    )
  ) AND sender_id = auth.uid()
);

CREATE POLICY "Users can update their own messages"
ON public.messages
FOR UPDATE
TO authenticated
USING (sender_id = auth.uid() OR is_admin())
WITH CHECK (sender_id = auth.uid() OR is_admin());

CREATE POLICY "Admins have full access"
ON public.messages
FOR DELETE
TO authenticated
USING (is_admin());

COMMIT; 