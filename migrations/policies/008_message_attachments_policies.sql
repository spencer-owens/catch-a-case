-- Enable RLS on message_attachments table
ALTER TABLE public.message_attachments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins have full access to message attachments" ON public.message_attachments;
DROP POLICY IF EXISTS "Users can view message attachments for their cases" ON public.message_attachments;
DROP POLICY IF EXISTS "Users can create message attachments for their messages" ON public.message_attachments;

-- Create policies
-- Admins have full access
CREATE POLICY "Admins have full access to message attachments"
ON public.message_attachments
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin());

-- Users can view message attachments for cases they're involved with
CREATE POLICY "Users can view message attachments for their cases"
ON public.message_attachments
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.messages m
        JOIN public.cases c ON c.id = m.case_id
        WHERE m.id = message_attachments.message_id
        AND (
            c.client_id = auth.uid()
            OR c.assigned_agent_id = auth.uid()
            OR is_agent()
        )
    )
);

-- Users can create message attachments for their messages
CREATE POLICY "Users can create message attachments for their messages"
ON public.message_attachments
FOR INSERT
TO authenticated
WITH CHECK (
    -- Check message ownership and case access
    (
        is_admin()
        OR
        (is_agent() AND EXISTS (
            SELECT 1 FROM public.messages m
            JOIN public.cases c ON c.id = m.case_id
            WHERE m.id = message_id
            AND m.sender_id = auth.uid()
        ))
        OR
        (EXISTS (
            SELECT 1 FROM public.messages m
            JOIN public.cases c ON c.id = m.case_id
            WHERE m.id = message_id
            AND m.sender_id = auth.uid()
            AND c.client_id = auth.uid()
        ))
    )
    AND
    -- Check attachment access
    (
        is_admin()
        OR
        (is_agent() AND EXISTS (
            SELECT 1 FROM public.attachments a
            JOIN public.cases c ON c.id = a.case_id
            WHERE a.id = attachment_id
            AND c.assigned_agent_id = auth.uid()
        ))
        OR
        (EXISTS (
            SELECT 1 FROM public.attachments a
            JOIN public.cases c ON c.id = a.case_id
            WHERE a.id = attachment_id
            AND c.client_id = auth.uid()
            AND a.uploader_id = auth.uid()
        ))
    )
); 