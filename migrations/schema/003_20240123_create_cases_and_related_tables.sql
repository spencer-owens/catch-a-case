-- Create Statuses table for dynamic status management
CREATE TABLE IF NOT EXISTS public.statuses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status_name TEXT NOT NULL UNIQUE,
    description TEXT,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create Tags table
CREATE TABLE IF NOT EXISTS public.tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tag_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create Cases table
CREATE TABLE IF NOT EXISTS public.cases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES public.users(id),
    assigned_agent_id UUID REFERENCES public.users(id),
    status_id UUID NOT NULL REFERENCES public.statuses(id),
    title TEXT NOT NULL,
    description TEXT,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create cases_tags join table
CREATE TABLE IF NOT EXISTS public.cases_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id UUID NOT NULL REFERENCES public.cases(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(case_id, tag_id)
);

-- Create function to validate user roles
CREATE OR REPLACE FUNCTION validate_case_roles()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if client has 'client' role
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = NEW.client_id AND role = 'client'
    ) THEN
        RAISE EXCEPTION 'Invalid client_id: User must have client role';
    END IF;

    -- Check if assigned agent has 'agent' role (if assigned)
    IF NEW.assigned_agent_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = NEW.assigned_agent_id AND role = 'agent'
    ) THEN
        RAISE EXCEPTION 'Invalid assigned_agent_id: User must have agent role';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for validation and updated_at
CREATE TRIGGER validate_case_roles_trigger
    BEFORE INSERT OR UPDATE ON public.cases
    FOR EACH ROW
    EXECUTE FUNCTION validate_case_roles();

CREATE TRIGGER set_statuses_updated_at
    BEFORE UPDATE ON public.statuses
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_cases_updated_at
    BEFORE UPDATE ON public.cases
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Insert default statuses
INSERT INTO public.statuses (status_name, description, order_index) VALUES
    ('Intake', 'Initial case registration and information gathering', 1),
    ('Pre-litigation', 'Case preparation and documentation', 2),
    ('Litigation', 'Active legal proceedings', 3),
    ('Settlement', 'Settlement negotiations or mediation', 4),
    ('Closed', 'Case has been resolved and closed', 5)
ON CONFLICT (status_name) DO NOTHING;
