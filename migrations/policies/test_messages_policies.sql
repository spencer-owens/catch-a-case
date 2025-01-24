-- Test RLS policies for messages table
BEGIN;

DO $$
DECLARE
    client1_id UUID;
    client2_id UUID;
    agent1_id UUID;
    admin_id UUID;
    case1_id UUID;
    case2_id UUID;
    v_count INTEGER;
    v_count_after INTEGER;
    new_message_id UUID;
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

    -- Verify table structure
    RAISE NOTICE 'Verifying messages table structure:';
    SELECT COUNT(*) INTO v_count 
    FROM information_schema.columns 
    WHERE table_name = 'messages' AND table_schema = 'public';
    RAISE NOTICE 'Found % columns in messages table', v_count;

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || client1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Client should see messages for their own cases
    SELECT COUNT(*) INTO v_count FROM public.messages WHERE case_id = case1_id;
    RAISE NOTICE 'Client 1 can see % messages for their case', v_count;

    -- Client should not see messages for other cases
    SELECT COUNT(*) INTO v_count FROM public.messages WHERE case_id = case2_id;
    RAISE NOTICE 'Client 1 can see % messages for other cases (should be 0)', v_count;

    -- Client should be able to create messages for their own case
    INSERT INTO public.messages (case_id, sender_id, message_content)
    VALUES (case1_id, client1_id, 'Test message from client 1')
    RETURNING id INTO new_message_id;
    RAISE NOTICE 'Client 1 created message successfully';

    -- Client should be able to update their own message
    UPDATE public.messages 
    SET message_content = 'Updated test message from client 1'
    WHERE id = new_message_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE NOTICE 'Client 1 updated their message successfully';
    ELSE
        RAISE NOTICE 'Client 1 could not update their message (unexpected)';
    END IF;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || agent1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Agent should see messages for their assigned cases
    SELECT COUNT(*) INTO v_count FROM public.messages WHERE case_id = case1_id;
    RAISE NOTICE 'Agent 1 can see % messages for their assigned case', v_count;

    -- Agent should be able to create messages for their assigned case
    INSERT INTO public.messages (case_id, sender_id, message_content)
    VALUES (case1_id, agent1_id, 'Test message from agent 1')
    RETURNING id INTO new_message_id;
    RAISE NOTICE 'Agent 1 created message successfully';

    -- Agent should be able to update their own message
    UPDATE public.messages 
    SET message_content = 'Updated test message from agent 1'
    WHERE id = new_message_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE NOTICE 'Agent 1 updated their message successfully';
    ELSE
        RAISE NOTICE 'Agent 1 could not update their message (unexpected)';
    END IF;

    -- Agent should not be able to update client's message
    UPDATE public.messages 
    SET message_content = 'Trying to update client message'
    WHERE sender_id = client1_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE NOTICE 'Agent 1 unexpectedly updated client message';
    ELSE
        RAISE NOTICE 'Agent 1 could not update client message (expected)';
    END IF;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || admin_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Admin should see all messages
    SELECT COUNT(*) INTO v_count FROM public.messages;
    RAISE NOTICE 'Admin can see % total messages', v_count;

    -- Admin should be able to create messages
    INSERT INTO public.messages (case_id, sender_id, message_content)
    VALUES (case1_id, admin_id, 'Test message from admin')
    RETURNING id INTO new_message_id;
    RAISE NOTICE 'Admin created message successfully';

    -- Admin should be able to update any message
    UPDATE public.messages 
    SET message_content = 'Admin updated this message'
    WHERE sender_id = client1_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE NOTICE 'Admin updated client message successfully';
    ELSE
        RAISE NOTICE 'Admin could not update client message (unexpected)';
    END IF;

END;
$$;

ROLLBACK; 