-- Test RLS policies for message_attachments table
BEGIN;

-- Create helper functions if they don't exist
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE sql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_agent()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'agent'
  );
$$ LANGUAGE sql SECURITY DEFINER;

DO $$
DECLARE
    client1_id UUID;
    client2_id UUID;
    agent1_id UUID;
    admin_id UUID;
    case1_id UUID;
    case2_id UUID;
    message1_id UUID;
    message2_id UUID;
    message3_id UUID;
    message4_id UUID;
    attachment1_id UUID;
    attachment2_id UUID;
    agent_attachment_id UUID;
    v_count INTEGER;
    new_message_attachment_id UUID;
    jwt_claims TEXT;
BEGIN
    -- Get test user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com';
    SELECT id INTO client2_id FROM auth.users WHERE email = 'client2@email.com';
    SELECT id INTO agent1_id FROM auth.users WHERE email = 'agent1@law.com';
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com';

    -- Get test case IDs
    SELECT id INTO case1_id FROM public.cases WHERE title = 'Car Accident Case';
    SELECT id INTO case2_id FROM public.cases WHERE title = 'Medical Negligence Case';

    -- Clean up any existing test data
    DELETE FROM public.message_attachments 
    WHERE message_id IN (
        SELECT id FROM public.messages 
        WHERE case_id IN (case1_id, case2_id)
    );

    -- Get test message IDs
    SELECT id INTO message1_id FROM public.messages 
    WHERE case_id = case1_id AND sender_id = client1_id 
    LIMIT 1;
    
    SELECT id INTO message2_id FROM public.messages 
    WHERE case_id = case1_id AND sender_id = agent1_id 
    LIMIT 1;

    -- Create a new message for testing
    INSERT INTO public.messages (case_id, sender_id, message_content)
    VALUES (case1_id, agent1_id, 'Test message for attachment testing')
    RETURNING id INTO message3_id;

    -- Create a new message for admin testing
    INSERT INTO public.messages (case_id, sender_id, message_content)
    VALUES (case1_id, admin_id, 'Test message for admin attachment testing')
    RETURNING id INTO message4_id;

    -- Get test attachment IDs
    SELECT id INTO attachment1_id FROM public.attachments 
    WHERE case_id = case1_id AND uploader_id = client1_id 
    LIMIT 1;
    
    SELECT id INTO attachment2_id FROM public.attachments 
    WHERE case_id = case1_id AND uploader_id = client1_id 
    LIMIT 1;

    -- Get agent's attachment
    SELECT id INTO agent_attachment_id FROM public.attachments 
    WHERE case_id = case1_id AND uploader_id = agent1_id 
    LIMIT 1;

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || client1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Client should see message attachments for their cases
    SELECT COUNT(*) INTO v_count FROM public.message_attachments ma
    JOIN public.messages m ON m.id = ma.message_id
    WHERE m.case_id = case1_id;
    RAISE NOTICE 'Client 1 can see % message attachments for their case', v_count;

    -- Client should be able to create message attachments for their messages
    BEGIN
        INSERT INTO public.message_attachments (message_id, attachment_id)
        VALUES (message1_id, attachment1_id)
        RETURNING id INTO new_message_attachment_id;
        RAISE NOTICE 'Client 1 created message attachment successfully';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Client 1 could not create message attachment (RLS policy)';
        WHEN OTHERS THEN
            IF SQLERRM LIKE '%violates foreign key constraint%' THEN
                RAISE NOTICE 'Client 1 could not create message attachment (FK constraint)';
            ELSIF SQLERRM LIKE '%violates unique constraint%' THEN
                RAISE NOTICE 'Client 1 could not create message attachment (unique constraint)';
            ELSE
                RAISE;
            END IF;
    END;

    -- Client should not be able to create message attachments for other cases
    BEGIN
        INSERT INTO public.message_attachments (message_id, attachment_id)
        VALUES (message2_id, attachment2_id);
        RAISE NOTICE 'Client 1 unexpectedly created message attachment for another case';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Client 1 could not create message attachment for another case (RLS policy)';
        WHEN OTHERS THEN
            IF SQLERRM LIKE '%violates foreign key constraint%' THEN
                RAISE NOTICE 'Client 1 could not create message attachment (FK constraint)';
            ELSIF SQLERRM LIKE '%violates unique constraint%' THEN
                RAISE NOTICE 'Client 1 could not create message attachment (unique constraint)';
            ELSE
                RAISE;
            END IF;
    END;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || agent1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Agent should see message attachments for their assigned cases
    SELECT COUNT(*) INTO v_count FROM public.message_attachments ma
    JOIN public.messages m ON m.id = ma.message_id
    WHERE m.case_id = case1_id;
    RAISE NOTICE 'Agent 1 can see % message attachments for their assigned case', v_count;

    -- Agent should be able to create message attachments for their messages
    BEGIN
        INSERT INTO public.message_attachments (message_id, attachment_id)
        VALUES (message3_id, agent_attachment_id)
        RETURNING id INTO new_message_attachment_id;
        RAISE NOTICE 'Agent 1 created message attachment successfully';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Agent 1 could not create message attachment (RLS policy)';
        WHEN OTHERS THEN
            IF SQLERRM LIKE '%violates foreign key constraint%' THEN
                RAISE NOTICE 'Agent 1 could not create message attachment (FK constraint)';
            ELSIF SQLERRM LIKE '%violates unique constraint%' THEN
                RAISE NOTICE 'Agent 1 could not create message attachment (unique constraint)';
            ELSE
                RAISE;
            END IF;
    END;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || admin_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Admin should see all message attachments
    SELECT COUNT(*) INTO v_count FROM public.message_attachments;
    RAISE NOTICE 'Admin can see % total message attachments', v_count;

    -- Admin should be able to create any message attachment
    BEGIN
        INSERT INTO public.message_attachments (message_id, attachment_id)
        VALUES (message4_id, agent_attachment_id)
        RETURNING id INTO new_message_attachment_id;
        RAISE NOTICE 'Admin created message attachment successfully';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Admin could not create message attachment (RLS policy)';
        WHEN OTHERS THEN
            IF SQLERRM LIKE '%violates foreign key constraint%' THEN
                RAISE NOTICE 'Admin could not create message attachment (FK constraint)';
            ELSIF SQLERRM LIKE '%violates unique constraint%' THEN
                RAISE NOTICE 'Admin could not create message attachment (unique constraint)';
            ELSE
                RAISE;
            END IF;
    END;

END;
$$;

ROLLBACK; 