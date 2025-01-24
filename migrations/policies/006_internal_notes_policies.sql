-- Enable RLS on internal_notes table
ALTER TABLE public.internal_notes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Agents and admins can view internal notes" ON public.internal_notes;
DROP POLICY IF EXISTS "Agents can create internal notes" ON public.internal_notes;
DROP POLICY IF EXISTS "Agents can update their notes" ON public.internal_notes;
DROP POLICY IF EXISTS "Admins can manage internal notes" ON public.internal_notes;

-- Create policies
-- Only agents and admins can view internal notes
CREATE POLICY "Agents and admins can view internal notes"
ON public.internal_notes
FOR SELECT
TO authenticated
USING (
    is_admin() OR 
    (is_agent() AND EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = internal_notes.case_id
        AND cases.assigned_agent_id = auth.uid()
    ))
);

-- Only agents can create notes for their assigned cases
CREATE POLICY "Agents can create internal notes"
ON public.internal_notes
FOR INSERT
TO authenticated
WITH CHECK (
    is_agent() 
    AND agent_id = auth.uid()
    AND EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = case_id
        AND cases.assigned_agent_id = auth.uid()
    )
);

-- Agents can update only their own notes
CREATE POLICY "Agents can update their notes"
ON public.internal_notes
FOR UPDATE
TO authenticated
USING (
    is_admin() OR (is_agent() AND agent_id = auth.uid())
)
WITH CHECK (
    is_admin() OR (is_agent() AND agent_id = auth.uid())
);

-- Admins have full access
CREATE POLICY "Admins can manage internal notes"
ON public.internal_notes
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin()); 