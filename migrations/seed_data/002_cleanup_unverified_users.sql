-- Delete feedback (depends on cases and users)
DELETE FROM public.feedback;

-- Delete message_attachments (junction table)
DELETE FROM public.message_attachments;

-- Delete attachments (depends on cases and users)
DELETE FROM public.attachments;

-- Delete messages (depends on cases and users)
DELETE FROM public.messages;

-- Delete internal_notes (depends on cases and users)
DELETE FROM public.internal_notes;

-- Delete cases_tags (junction table)
DELETE FROM public.cases_tags;

-- Delete cases (depends on users)
DELETE FROM public.cases;

-- Delete team_members (depends on teams and users)
DELETE FROM public.team_members;

-- Delete teams
DELETE FROM public.teams;

-- Delete users (depends on auth.users)
DELETE FROM public.users;

-- Delete from auth.users
DELETE FROM auth.users;
