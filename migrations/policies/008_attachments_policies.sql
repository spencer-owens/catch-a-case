-- Enable RLS on attachments table
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view attachments for their cases" ON public.attachments;
DROP POLICY IF EXISTS "Users can upload attachments to their cases" ON public.attachments;
DROP POLICY IF EXISTS "Admins have full access to attachments" ON public.attachments;
DROP POLICY IF EXISTS "Users can update their attachments" ON public.attachments;
DROP POLICY IF EXISTS "Users can delete their attachments" ON public.attachments;

-- Create policies

-- Admins have full access
CREATE POLICY "Admins have full access to attachments"
ON public.attachments
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin());

-- Users can view attachments for cases they're involved with
CREATE POLICY "Users can view attachments for their cases"
ON public.attachments
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = attachments.case_id
        AND (
            cases.client_id = auth.uid()
            OR cases.assigned_agent_id = auth.uid()
            OR is_agent()
        )
    )
);

-- Users can upload attachments to their cases
CREATE POLICY "Users can upload attachments to their cases"
ON public.attachments
FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = case_id
        AND (
            cases.client_id = auth.uid()
            OR cases.assigned_agent_id = auth.uid()
            OR is_agent()
        )
    )
    AND uploader_id = auth.uid()
);

-- Users can update their own attachments
CREATE POLICY "Users can update their attachments"
ON public.attachments
FOR UPDATE
TO authenticated
USING (uploader_id = auth.uid())
WITH CHECK (uploader_id = auth.uid());

-- Users can delete their own attachments
CREATE POLICY "Users can delete their attachments"
ON public.attachments
FOR DELETE
TO authenticated
USING (
    uploader_id = auth.uid()
    OR is_admin()
    OR (
        is_agent()
        AND EXISTS (
            SELECT 1 FROM public.cases
            WHERE cases.id = case_id
            AND cases.assigned_agent_id = auth.uid()
        )
    )
); 