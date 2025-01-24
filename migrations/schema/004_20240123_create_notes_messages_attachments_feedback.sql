-- Create Internal Notes table
CREATE TABLE IF NOT EXISTS public.internal_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    agent_id UUID NOT NULL REFERENCES public.users(id),
    note_content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create Messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id),
    message_content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create Attachments table
CREATE TABLE IF NOT EXISTS public.attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    uploader_id UUID NOT NULL REFERENCES public.users(id),
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    file_path TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create message_attachments join table
CREATE TABLE IF NOT EXISTS public.message_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
    attachment_id UUID NOT NULL REFERENCES public.attachments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(message_id, attachment_id)
);

-- Create Feedback table
CREATE TABLE IF NOT EXISTS public.feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES public.users(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    CONSTRAINT one_feedback_per_case_client UNIQUE(case_id, client_id)
);

-- Create function to validate agent role for internal notes
CREATE OR REPLACE FUNCTION validate_internal_note_agent()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = NEW.agent_id AND role = 'agent'
    ) THEN
        RAISE EXCEPTION 'Invalid agent_id: User must have agent role';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create function to validate feedback client
CREATE OR REPLACE FUNCTION validate_feedback_client()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = NEW.client_id AND role = 'client'
    ) THEN
        RAISE EXCEPTION 'Invalid client_id: User must have client role';
    END IF;
    
    -- Verify the client is associated with the case
    IF NOT EXISTS (
        SELECT 1 FROM public.cases 
        WHERE id = NEW.case_id AND client_id = NEW.client_id
    ) THEN
        RAISE EXCEPTION 'Invalid case_id: Client must be associated with the case';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for validation and updated_at
CREATE TRIGGER validate_internal_note_agent_trigger
    BEFORE INSERT OR UPDATE ON public.internal_notes
    FOR EACH ROW
    EXECUTE FUNCTION validate_internal_note_agent();

CREATE TRIGGER validate_feedback_client_trigger
    BEFORE INSERT OR UPDATE ON public.feedback
    FOR EACH ROW
    EXECUTE FUNCTION validate_feedback_client();

CREATE TRIGGER set_internal_notes_updated_at
    BEFORE UPDATE ON public.internal_notes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_messages_updated_at
    BEFORE UPDATE ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_attachments_updated_at
    BEFORE UPDATE ON public.attachments
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_feedback_updated_at
    BEFORE UPDATE ON public.feedback
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
