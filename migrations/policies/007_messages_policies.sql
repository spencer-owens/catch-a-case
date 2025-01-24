-- Enable RLS on messages table
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins have full access to messages" ON public.messages;
DROP POLICY IF EXISTS "Users can view messages for their cases" ON public.messages;
DROP POLICY IF EXISTS "Users can create messages for their cases" ON public.messages;
DROP POLICY IF EXISTS "Users can update their messages" ON public.messages;

-- Create policies
-- Admins have full access
CREATE POLICY "Admins have full access to messages"
ON public.messages
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin());

-- Users can view messages for cases they're involved with
CREATE POLICY "Users can view messages for their cases"
ON public.messages
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.cases
        WHERE cases.id = messages.case_id
        AND (
            cases.client_id = auth.uid()
            OR cases.assigned_agent_id = auth.uid()
            OR is_agent()
        )
    )
);

-- Users can create messages for their cases
CREATE POLICY "Users can create messages for their cases"
ON public.messages
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
    AND sender_id = auth.uid()
);

-- Users can update their own messages
CREATE POLICY "Users can update their messages"
ON public.messages
FOR UPDATE
TO authenticated
USING (sender_id = auth.uid())
WITH CHECK (sender_id = auth.uid()); 