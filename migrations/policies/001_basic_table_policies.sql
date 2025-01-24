-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.statuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cases_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.internal_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedback ENABLE ROW LEVEL SECURITY;

-- Create a helper function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- Create a helper function to check if user is agent
CREATE OR REPLACE FUNCTION public.is_agent()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM auth.users u
    JOIN public.users pu ON u.id = pu.id
    WHERE u.id = auth.uid() AND pu.role = 'agent'
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- USERS table policies
-- Everyone can view basic user info (needed for UI displays)
CREATE POLICY "Users are viewable by everyone"
  ON public.users FOR SELECT
  USING (true);

-- Only admins can create/update/delete users
CREATE POLICY "Admins have full access to users"
  ON public.users FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- TEAMS table policies
-- Everyone can view teams
CREATE POLICY "Teams are viewable by everyone"
  ON public.teams FOR SELECT
  USING (true);

-- Only admins can manage teams
CREATE POLICY "Admins have full access to teams"
  ON public.teams FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- TEAM_MEMBERS table policies
-- Everyone can view team members
CREATE POLICY "Team members are viewable by everyone"
  ON public.team_members FOR SELECT
  USING (true);

-- Only admins can manage team members
CREATE POLICY "Admins can manage team members"
  ON public.team_members FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- CASES table policies
-- Admins have full access
CREATE POLICY "Admins have full access to cases"
  ON public.cases FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Agents can view all cases and update cases assigned to them
CREATE POLICY "Agents can view all cases"
  ON public.cases FOR SELECT
  USING (is_agent());

CREATE POLICY "Agents can update their assigned cases"
  ON public.cases FOR UPDATE
  USING (is_agent() AND assigned_agent_id = auth.uid())
  WITH CHECK (is_agent() AND assigned_agent_id = auth.uid());

-- Clients can view and create their own cases
CREATE POLICY "Clients can view their own cases"
  ON public.cases FOR SELECT
  USING (client_id = auth.uid());

CREATE POLICY "Clients can create their own cases"
  ON public.cases FOR INSERT
  WITH CHECK (client_id = auth.uid());

-- MESSAGES table policies
-- Admins have full access
CREATE POLICY "Admins have full access to messages"
  ON public.messages FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Users can view messages for cases they're involved with
CREATE POLICY "Users can view messages for their cases"
  ON public.messages FOR SELECT
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
  ON public.messages FOR INSERT
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

-- INTERNAL_NOTES table policies
-- Only agents and admins can access internal notes
CREATE POLICY "Agents can access internal notes"
  ON public.internal_notes FOR SELECT
  USING (is_agent() OR is_admin());

CREATE POLICY "Agents can create internal notes"
  ON public.internal_notes FOR INSERT
  WITH CHECK (is_agent() AND agent_id = auth.uid());

-- ATTACHMENTS and MESSAGE_ATTACHMENTS policies
-- Users can view attachments for cases they're involved with
CREATE POLICY "Users can view attachments for their cases"
  ON public.attachments FOR SELECT
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
  ON public.attachments FOR INSERT
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

-- FEEDBACK table policies
-- Clients can create feedback for their cases
CREATE POLICY "Clients can create feedback for their cases"
  ON public.feedback FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.cases
      WHERE cases.id = case_id
      AND cases.client_id = auth.uid()
    )
    AND client_id = auth.uid()
  );

-- Agents can view feedback for their cases
CREATE POLICY "Agents can view feedback"
  ON public.feedback FOR SELECT
  USING (is_agent() OR is_admin());

-- STATUSES and TAGS policies
-- Everyone can view statuses and tags
CREATE POLICY "Statuses are viewable by everyone"
  ON public.statuses FOR SELECT
  USING (true);

CREATE POLICY "Tags are viewable by everyone"
  ON public.tags FOR SELECT
  USING (true);

-- Only admins can manage statuses and tags
CREATE POLICY "Admins can manage statuses"
  ON public.statuses FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "Admins can manage tags"
  ON public.tags FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());
