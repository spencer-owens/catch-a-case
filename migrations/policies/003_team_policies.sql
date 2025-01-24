-- Enable RLS
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their teams" ON public.teams;
DROP POLICY IF EXISTS "Agents and admins can create teams" ON public.teams;
DROP POLICY IF EXISTS "Admins can update teams" ON public.teams;
DROP POLICY IF EXISTS "Admins can delete teams" ON public.teams;
DROP POLICY IF EXISTS "Users can view members of their teams" ON public.team_members;
DROP POLICY IF EXISTS "Users can view team members" ON public.team_members;
DROP POLICY IF EXISTS "Agents and admins can add team members" ON public.team_members;
DROP POLICY IF EXISTS "Agents and admins can remove team members" ON public.team_members;

-- Team Members Policies (these must come first and be role-based only)

-- View team members (users can view members if they are an agent/admin or if they are the member)
CREATE POLICY "Users can view team members"
    ON public.team_members
    FOR SELECT
    TO authenticated
    USING (
        -- Direct user match or role-based access
        user_id = auth.uid()
        OR
        (SELECT role FROM public.users WHERE id = auth.uid()) IN ('agent', 'admin')
    );

-- Add team members (only agents and admins can add members)
CREATE POLICY "Agents and admins can add team members"
    ON public.team_members
    FOR INSERT
    TO authenticated
    WITH CHECK (
        (SELECT role FROM public.users WHERE id = auth.uid()) IN ('agent', 'admin')
    );

-- Remove team members (only agents and admins can remove members)
CREATE POLICY "Agents and admins can remove team members"
    ON public.team_members
    FOR DELETE
    TO authenticated
    USING (
        (SELECT role FROM public.users WHERE id = auth.uid()) IN ('agent', 'admin')
    );

-- Teams Policies (these can now safely check team_members)

-- View teams (users can view teams they are members of or if they are agent/admin)
CREATE POLICY "Users can view their teams"
    ON public.teams
    FOR SELECT
    TO authenticated
    USING (
        -- First check role-based access
        (SELECT role FROM public.users WHERE id = auth.uid()) IN ('agent', 'admin')
        OR
        -- Then check membership
        EXISTS (
            SELECT 1 FROM public.team_members
            WHERE team_members.team_id = teams.id
            AND team_members.user_id = auth.uid()
        )
    );

-- Create teams (only agents and admins can create teams)
CREATE POLICY "Agents and admins can create teams"
    ON public.teams
    FOR INSERT
    TO authenticated
    WITH CHECK (
        (SELECT role FROM public.users WHERE id = auth.uid()) IN ('agent', 'admin')
    );

-- Update teams (only admins can update team details)
CREATE POLICY "Admins can update teams"
    ON public.teams
    FOR UPDATE
    TO authenticated
    USING (
        (SELECT role FROM public.users WHERE id = auth.uid()) = 'admin'
    )
    WITH CHECK (
        (SELECT role FROM public.users WHERE id = auth.uid()) = 'admin'
    );

-- Delete teams (only admins can delete teams)
CREATE POLICY "Admins can delete teams"
    ON public.teams
    FOR DELETE
    TO authenticated
    USING (
        (SELECT role FROM public.users WHERE id = auth.uid()) = 'admin'
    ); 