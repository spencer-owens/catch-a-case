-- First, create test users in auth.users (required for public.users foreign key)
INSERT INTO auth.users (id, email, raw_user_meta_data)
VALUES 
    ('d7bed82f-5222-4920-b3a5-2f6765249a82', 'admin@law.com', '{"full_name":"Admin User"}'::jsonb),
    ('e3721c90-8c0f-4eac-a682-5d5227b20754', 'agent1@law.com', '{"full_name":"Agent One"}'::jsonb),
    ('f4b73d73-c6f5-4f45-82f5-8d9c3f3b2d2b', 'agent2@law.com', '{"full_name":"Agent Two"}'::jsonb),
    ('9b146b32-4272-4a06-9492-9d67f6d22895', 'client1@email.com', '{"full_name":"Client One"}'::jsonb),
    ('7a29e8f3-5c4a-4c51-b5d4-96e756f2b2d2', 'client2@email.com', '{"full_name":"Client Two"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Manually confirm the users (this requires superuser privileges)
UPDATE auth.users SET email_confirmed_at = NOW() WHERE email LIKE '%@law.com' OR email LIKE '%@email.com';

-- Create test users
INSERT INTO public.users (id, email, role, full_name)
VALUES
    ('d7bed82f-5222-4920-b3a5-2f6765249a82', 'admin@law.com', 'admin', 'Admin User'),
    ('e3721c90-8c0f-4eac-a682-5d5227b20754', 'agent1@law.com', 'agent', 'Agent One'),
    ('f4b73d73-c6f5-4f45-82f5-8d9c3f3b2d2b', 'agent2@law.com', 'agent', 'Agent Two'),
    ('9b146b32-4272-4a06-9492-9d67f6d22895', 'client1@email.com', 'client', 'Client One'),
    ('7a29e8f3-5c4a-4c51-b5d4-96e756f2b2d2', 'client2@email.com', 'client', 'Client Two')
ON CONFLICT (id) DO NOTHING;

-- Create test teams
INSERT INTO public.teams (id, team_name)
VALUES
    ('a1b2c3d4-e5f6-4920-b3a5-2f6765249a82', 'Personal Injury Team'),
    ('b2c3d4e5-f6a7-4eac-a682-5d5227b20754', 'Medical Malpractice Team')
ON CONFLICT (team_name) DO NOTHING;

-- Assign agents to teams
INSERT INTO public.team_members (team_id, user_id)
VALUES
    ((SELECT id FROM public.teams WHERE team_name = 'Personal Injury Team'),
     (SELECT id FROM public.users WHERE email = 'agent1@law.com')),
    ((SELECT id FROM public.teams WHERE team_name = 'Medical Malpractice Team'),
     (SELECT id FROM public.users WHERE email = 'agent2@law.com'))
ON CONFLICT ON CONSTRAINT team_members_team_id_user_id_key DO NOTHING;

-- Create test tags
INSERT INTO public.tags (id, tag_name)
VALUES
    ('c3d4e5f6-a7b8-4920-b3a5-2f6765249a82', 'Urgent'),
    ('d4e5f6a7-b8c9-4eac-a682-5d5227b20754', 'High Value'),
    ('e5f6a7b8-c9d0-4f45-82f5-8d9c3f3b2d2b', 'Complex')
ON CONFLICT (tag_name) DO NOTHING;

-- Create test cases
INSERT INTO public.cases (id, client_id, assigned_agent_id, status_id, title, description, custom_fields)
VALUES
    ('f6a7b8c9-d0e1-4920-b3a5-2f6765249a82',
     (SELECT id FROM public.users WHERE email = 'client1@email.com'),
     (SELECT id FROM public.users WHERE email = 'agent1@law.com'),
     (SELECT id FROM public.statuses WHERE status_name = 'Intake'),
     'Car Accident Case',
     'Client involved in a car accident on Main Street',
     '{"accident_date": "2024-01-15", "injury_type": "Whiplash"}'::jsonb),
    
    ('a7b8c9d0-e1f2-4eac-a682-5d5227b20754',
     (SELECT id FROM public.users WHERE email = 'client2@email.com'),
     (SELECT id FROM public.users WHERE email = 'agent2@law.com'),
     (SELECT id FROM public.statuses WHERE status_name = 'Pre-litigation'),
     'Medical Negligence Case',
     'Surgery complications at City Hospital',
     '{"incident_date": "2023-12-20", "hospital": "City Hospital"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- Tag the cases
INSERT INTO public.cases_tags (case_id, tag_id)
VALUES
    ((SELECT id FROM public.cases WHERE title = 'Car Accident Case'),
     (SELECT id FROM public.tags WHERE tag_name = 'Urgent')),
    ((SELECT id FROM public.cases WHERE title = 'Medical Negligence Case'),
     (SELECT id FROM public.tags WHERE tag_name = 'Complex'))
ON CONFLICT ON CONSTRAINT cases_tags_case_id_tag_id_key DO NOTHING;

-- Create test internal notes
INSERT INTO public.internal_notes (case_id, agent_id, note_content)
VALUES
    ((SELECT id FROM public.cases WHERE title = 'Car Accident Case'),
     (SELECT id FROM public.users WHERE email = 'agent1@law.com'),
     'Initial consultation completed. Client has medical records ready.'),
    ((SELECT id FROM public.cases WHERE title = 'Medical Negligence Case'),
     (SELECT id FROM public.users WHERE email = 'agent2@law.com'),
     'Requested additional documentation from hospital.')
ON CONFLICT DO NOTHING;

-- Create test messages
INSERT INTO public.messages (case_id, sender_id, message_content)
VALUES
    ((SELECT id FROM public.cases WHERE title = 'Car Accident Case'),
     (SELECT id FROM public.users WHERE email = 'client1@email.com'),
     'When is our next meeting scheduled?'),
    ((SELECT id FROM public.cases WHERE title = 'Car Accident Case'),
     (SELECT id FROM public.users WHERE email = 'agent1@law.com'),
     'I can meet this Thursday at 2 PM. Does that work for you?')
ON CONFLICT DO NOTHING;

-- Create test attachments
INSERT INTO public.attachments (case_id, uploader_id, file_name, file_type, file_size, file_path)
VALUES
    ((SELECT id FROM public.cases WHERE title = 'Car Accident Case'),
     (SELECT id FROM public.users WHERE email = 'client1@email.com'),
     'medical_report.pdf',
     'application/pdf',
     1024576,
     'cases/car-accident/medical_report.pdf'),
    ((SELECT id FROM public.cases WHERE title = 'Medical Negligence Case'),
     (SELECT id FROM public.users WHERE email = 'agent2@law.com'),
     'hospital_records.pdf',
     'application/pdf',
     2048576,
     'cases/medical-negligence/hospital_records.pdf')
ON CONFLICT DO NOTHING;

-- Create test feedback
INSERT INTO public.feedback (case_id, client_id, rating, comments)
VALUES
    ((SELECT id FROM public.cases WHERE title = 'Car Accident Case'),
     (SELECT id FROM public.users WHERE email = 'client1@email.com'),
     5,
     'Very satisfied with the service and communication.')
ON CONFLICT ON CONSTRAINT one_feedback_per_case_client DO NOTHING;
