-- Enable RLS
ALTER TABLE public.message_attachments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view message attachments for their cases" ON public.message_attachments;
DROP POLICY IF EXISTS "Users can create message attachments for their messages" ON public.message_attachments;

-- Create policies
CREATE POLICY "Users can view message attachments for their cases" ON public.message_attachments
    FOR SELECT USING (
        is_admin()
        OR EXISTS (
            -- If user can see the message (messages RLS will handle case access)
            SELECT 1 FROM messages m
            JOIN cases c ON c.id = m.case_id
            WHERE m.id = message_attachments.message_id
            AND (
                c.client_id = auth.uid()
                OR c.assigned_agent_id = auth.uid()
                OR is_agent()
            )
        )
    );

CREATE POLICY "Users can create message attachments for their messages" ON public.message_attachments
    FOR INSERT WITH CHECK (
        is_admin()
        OR (
            EXISTS (
                SELECT 1 FROM messages m
                JOIN cases c ON c.id = m.case_id
                WHERE m.id = message_id
                AND (
                    -- Client must own the case and the attachment
                    (NOT is_agent() AND c.client_id = auth.uid() AND EXISTS (
                        SELECT 1 FROM attachments a
                        WHERE a.id = attachment_id
                        AND a.case_id = c.id
                        AND a.uploader_id = auth.uid()
                    ))
                    OR
                    -- Agent can use any attachment from their assigned case
                    (is_agent() AND c.assigned_agent_id = auth.uid() AND EXISTS (
                        SELECT 1 FROM attachments a
                        WHERE a.id = attachment_id
                        AND a.case_id = c.id
                    ))
                )
            )
        )
    ); 