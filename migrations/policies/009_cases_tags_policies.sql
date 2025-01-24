-- Enable RLS on cases_tags table
ALTER TABLE public.cases_tags ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins have full access to cases_tags" ON public.cases_tags;
DROP POLICY IF EXISTS "Users can view case tags for their cases" ON public.cases_tags;
DROP POLICY IF EXISTS "Agents can manage case tags" ON public.cases_tags;

-- Create policies
-- Admins have full access
CREATE POLICY "Admins have full access to cases_tags"
ON public.cases_tags
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin());

-- Users can view case tags for cases they're involved with
CREATE POLICY "Users can view case tags for their cases"
ON public.cases_tags
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = cases_tags.case_id
        AND (
            cases.client_id = auth.uid()
            OR cases.assigned_agent_id = auth.uid()
            OR is_agent()
        )
    )
);

-- Agents can manage case tags for their assigned cases
CREATE POLICY "Agents can manage case tags"
ON public.cases_tags
FOR INSERT
TO authenticated
WITH CHECK (
    is_agent() AND
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = case_id
        AND cases.assigned_agent_id = auth.uid()
    )
);