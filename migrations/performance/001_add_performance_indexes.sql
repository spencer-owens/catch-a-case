-- Add performance indexes for common queries and RLS policies

-- Cases table indexes
CREATE INDEX IF NOT EXISTS idx_cases_client_id ON public.cases(client_id);
CREATE INDEX IF NOT EXISTS idx_cases_assigned_agent_id ON public.cases(assigned_agent_id);
CREATE INDEX IF NOT EXISTS idx_cases_status_id ON public.cases(status_id);
CREATE INDEX IF NOT EXISTS idx_cases_created_at ON public.cases(created_at DESC);

-- Messages table indexes
CREATE INDEX IF NOT EXISTS idx_messages_case_id ON public.messages(case_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);

-- Attachments table indexes
CREATE INDEX IF NOT EXISTS idx_attachments_case_id ON public.attachments(case_id);
CREATE INDEX IF NOT EXISTS idx_attachments_uploader_id ON public.attachments(uploader_id);
CREATE INDEX IF NOT EXISTS idx_attachments_created_at ON public.attachments(created_at DESC);

-- Message Attachments table indexes
CREATE INDEX IF NOT EXISTS idx_message_attachments_message_id ON public.message_attachments(message_id);
CREATE INDEX IF NOT EXISTS idx_message_attachments_attachment_id ON public.message_attachments(attachment_id);

-- Internal Notes table indexes
CREATE INDEX IF NOT EXISTS idx_internal_notes_case_id ON public.internal_notes(case_id);
CREATE INDEX IF NOT EXISTS idx_internal_notes_agent_id ON public.internal_notes(agent_id);
CREATE INDEX IF NOT EXISTS idx_internal_notes_created_at ON public.internal_notes(created_at DESC);

-- Feedback table indexes
CREATE INDEX IF NOT EXISTS idx_feedback_case_id ON public.feedback(case_id);
CREATE INDEX IF NOT EXISTS idx_feedback_client_id ON public.feedback(client_id);
CREATE INDEX IF NOT EXISTS idx_feedback_created_at ON public.feedback(created_at DESC);

-- Users table indexes
CREATE INDEX IF NOT EXISTS idx_users_role ON public.users(role);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Teams and Team Members indexes (already exist but included for completeness)
CREATE INDEX IF NOT EXISTS idx_team_members_user_id ON public.team_members(user_id);
CREATE INDEX IF NOT EXISTS idx_team_members_team_id ON public.team_members(team_id);
CREATE INDEX IF NOT EXISTS idx_teams_name ON public.teams(team_name);

-- Cases Tags indexes
CREATE INDEX IF NOT EXISTS idx_cases_tags_case_id ON public.cases_tags(case_id);
CREATE INDEX IF NOT EXISTS idx_cases_tags_tag_id ON public.cases_tags(tag_id);

-- Compound indexes for common queries
CREATE INDEX IF NOT EXISTS idx_messages_case_created ON public.messages(case_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_attachments_case_created ON public.attachments(case_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_internal_notes_case_created ON public.internal_notes(case_id, created_at DESC);

-- Partial indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_agents ON public.users(id) WHERE role = 'agent';
CREATE INDEX IF NOT EXISTS idx_users_clients ON public.users(id) WHERE role = 'client';
CREATE INDEX IF NOT EXISTS idx_users_admins ON public.users(id) WHERE role = 'admin';

-- Full text search indexes for search functionality
CREATE INDEX IF NOT EXISTS idx_messages_content_search ON public.messages USING gin(to_tsvector('english', message_content));
CREATE INDEX IF NOT EXISTS idx_internal_notes_content_search ON public.internal_notes USING gin(to_tsvector('english', note_content));

-- Add table statistics for query optimization
ANALYZE public.cases;
ANALYZE public.messages;
ANALYZE public.attachments;
ANALYZE public.message_attachments;
ANALYZE public.internal_notes;
ANALYZE public.feedback;
ANALYZE public.users;
ANALYZE public.teams;
ANALYZE public.team_members;
ANALYZE public.cases_tags;
ANALYZE public.tags;
ANALYZE public.statuses;