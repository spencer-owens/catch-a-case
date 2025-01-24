-- Test RLS policies for internal_notes table
BEGIN;

DO $$
DECLARE
    client1_id UUID;
    agent1_id UUID;
    agent2_id UUID;
    admin_id UUID;
    case1_id UUID;
    case2_id UUID;
    v_count INTEGER;
    v_count_after INTEGER;
    new_note_id UUID;
    jwt_claims TEXT;
BEGIN
    -- Get test user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com';
    SELECT id INTO agent1_id FROM auth.users WHERE email = 'agent1@law.com';
    SELECT id INTO agent2_id FROM auth.users WHERE email = 'agent2@law.com';
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com';

    -- Get test case IDs
    SELECT id INTO case1_id FROM public.cases WHERE title = 'Car Accident Case';
    SELECT id INTO case2_id FROM public.cases WHERE title = 'Medical Negligence Case';

    -- Verify table structure
    RAISE NOTICE 'Verifying internal_notes table structure:';
    SELECT COUNT(*) INTO v_count 
    FROM information_schema.columns 
    WHERE table_name = 'internal_notes' AND table_schema = 'public';
    RAISE NOTICE 'Found % columns in internal_notes table', v_count;

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := format('{"sub": "%s"}', client1_id);
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Client should not be able to view notes
    BEGIN
        SELECT COUNT(*) INTO v_count FROM public.internal_notes;
        IF v_count > 0 THEN
            RAISE NOTICE 'Unexpectedly able to view % notes', v_count;
        END IF;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Expected: Client cannot view internal notes';
    END;

    -- Client should not be able to create notes
    BEGIN
        INSERT INTO public.internal_notes (case_id, agent_id, note_content)
        VALUES (case1_id, agent1_id, 'Test note from client')
        RETURNING id INTO new_note_id;
        RAISE NOTICE 'Unexpectedly able to create note';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Expected: Client cannot create internal notes';
    END;

    -- Test as Agent 1 (assigned to case1)
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := format('{"sub": "%s"}', agent1_id);
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Agent should be able to view notes for their cases
    SELECT COUNT(*) INTO v_count 
    FROM public.internal_notes n
    JOIN public.cases c ON c.id = n.case_id
    WHERE c.assigned_agent_id = auth.uid();
    RAISE NOTICE 'Agent can see % notes for their cases', v_count;

    -- Agent should be able to create note for their case
    INSERT INTO public.internal_notes (case_id, agent_id, note_content)
    VALUES (case1_id, agent1_id, 'Test note from agent 1')
    RETURNING id INTO new_note_id;
    RAISE NOTICE 'Agent created note successfully';

    -- Agent should be able to update their own note
    UPDATE public.internal_notes 
    SET note_content = 'Updated test note from agent 1'
    WHERE id = new_note_id;
    RAISE NOTICE 'Agent updated their note successfully';

    -- Agent should not be able to update another agent's note
    BEGIN
        UPDATE public.internal_notes 
        SET note_content = 'Trying to update other agent note'
        WHERE case_id = case2_id AND agent_id = agent2_id;
        GET DIAGNOSTICS v_count = ROW_COUNT;
        IF v_count > 0 THEN
            RAISE NOTICE 'Unexpectedly able to update % other agent notes', v_count;
        ELSE
            RAISE NOTICE 'Expected: Agent cannot update other agent notes';
        END IF;
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Expected: Agent cannot update other agent notes';
    END;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := format('{"sub": "%s"}', admin_id);
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Admin should be able to view all notes
    SELECT COUNT(*) INTO v_count FROM public.internal_notes;
    RAISE NOTICE 'Admin can see % notes', v_count;

    -- Admin should be able to create notes
    INSERT INTO public.internal_notes (case_id, agent_id, note_content)
    VALUES (case1_id, agent1_id, 'Test note from admin')
    RETURNING id INTO new_note_id;
    RAISE NOTICE 'Admin created note successfully';

    -- Admin should be able to update any note
    UPDATE public.internal_notes 
    SET note_content = 'Updated by admin'
    WHERE id = new_note_id;
    RAISE NOTICE 'Admin updated note successfully';

    -- Admin should be able to delete notes
    SELECT COUNT(*) INTO v_count FROM public.internal_notes;
    DELETE FROM public.internal_notes WHERE id = new_note_id;
    SELECT COUNT(*) INTO v_count_after FROM public.internal_notes;
    
    IF v_count > v_count_after THEN
        RAISE NOTICE 'Admin deleted note successfully';
    ELSE
        RAISE NOTICE 'Warning: Delete operation had no effect';
    END IF;

    -- Reset role
    RESET ROLE;
    RESET request.jwt.claims;
END $$;

ROLLBACK; 