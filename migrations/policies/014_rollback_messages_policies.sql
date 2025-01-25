-- Rollback message policies to previous state
BEGIN;

-- Drop the separated policies we just created
DROP POLICY IF EXISTS "Admins can view all messages" ON public.messages;
DROP POLICY IF EXISTS "Agents can view case messages" ON public.messages;
DROP POLICY IF EXISTS "Clients can view their case messages" ON public.messages;

-- Recreate the original policies
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

COMMIT; 