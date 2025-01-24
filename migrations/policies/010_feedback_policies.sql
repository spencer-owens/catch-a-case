-- Enable RLS on feedback table
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins have full access to feedback" ON public.feedback;
DROP POLICY IF EXISTS "Users can view feedback for their cases" ON public.feedback;
DROP POLICY IF EXISTS "Clients can create feedback for their cases" ON public.feedback;
DROP POLICY IF EXISTS "Clients can update their feedback" ON public.feedback;

-- Create policies
-- Admins have full access
CREATE POLICY "Admins have full access to feedback"
ON public.feedback
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin());

-- Users can view feedback for cases they're involved with
CREATE POLICY "Users can view feedback for their cases"
ON public.feedback
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = feedback.case_id
        AND (
            cases.client_id = auth.uid()
            OR cases.assigned_agent_id = auth.uid()
            OR is_agent()
        )
    )
);

-- Clients can create feedback for their cases
CREATE POLICY "Clients can create feedback for their cases"
ON public.feedback
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = case_id
        AND cases.client_id = auth.uid()
    )
    AND client_id = auth.uid()
);

-- Clients can update their own feedback
CREATE POLICY "Clients can update their feedback"
ON public.feedback
FOR UPDATE
TO authenticated
USING (client_id = auth.uid())
WITH CHECK (client_id = auth.uid()); 