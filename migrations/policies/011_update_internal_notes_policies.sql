-- Update internal notes policies to allow admins full participation
BEGIN;

-- Drop all existing policies
DROP POLICY IF EXISTS "Agents and admins can create internal notes" ON public.internal_notes;
DROP POLICY IF EXISTS "Agents and admins can view internal notes" ON public.internal_notes;
DROP POLICY IF EXISTS "Users can update their own notes" ON public.internal_notes;
DROP POLICY IF EXISTS "Admins have full access" ON public.internal_notes;

-- Update the trigger function to allow both agents and admins
CREATE OR REPLACE FUNCTION public.validate_internal_note_agent()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = NEW.agent_id AND (role = 'agent' OR role = 'admin')
    ) THEN
        RAISE EXCEPTION 'Invalid agent_id: User must have agent or admin role';
    END IF;
    RETURN NEW;
END;
$function$;

-- Create new policies that allow both agents and admins to participate
CREATE POLICY "Agents and admins can view internal notes"
ON public.internal_notes
FOR SELECT
TO authenticated
USING (
  is_admin() OR (
    is_agent() AND EXISTS (
      SELECT 1 FROM cases
      WHERE cases.id = internal_notes.case_id
      AND cases.assigned_agent_id = auth.uid()
    )
  )
);

CREATE POLICY "Agents and admins can create internal notes"
ON public.internal_notes
FOR INSERT
TO authenticated
WITH CHECK (
  (is_agent() OR is_admin()) AND
  agent_id = auth.uid()
);

CREATE POLICY "Users can update their own notes"
ON public.internal_notes
FOR UPDATE
TO authenticated
USING (agent_id = auth.uid() OR is_admin())
WITH CHECK (agent_id = auth.uid() OR is_admin());

CREATE POLICY "Admins have full access"
ON public.internal_notes
FOR DELETE
TO authenticated
USING (is_admin());

COMMIT; 