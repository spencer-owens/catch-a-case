-- Test RLS policies for tags table
BEGIN;

DO $$
DECLARE
    client1_id UUID;
    agent1_id UUID;
    admin_id UUID;
    v_count INTEGER;
    v_count_after INTEGER;
    new_tag_id UUID;
BEGIN
    -- Get test user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com';
    SELECT id INTO agent1_id FROM auth.users WHERE email = 'agent1@law.com';
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com';

    -- Verify table structure (following @RLS-testing.md best practices)
    RAISE NOTICE 'Verifying tags table structure:';
    SELECT COUNT(*) INTO v_count 
    FROM information_schema.columns 
    WHERE table_name = 'tags' AND table_schema = 'public';
    RAISE NOTICE 'Found % columns in tags table', v_count;

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    RESET ROLE;
    SET ROLE authenticated;
    EXECUTE format('SET request.jwt.claims = ''{"sub": "%s"}''', client1_id);

    -- Client should be able to view tags
    SELECT COUNT(*) INTO v_count FROM public.tags;
    RAISE NOTICE 'Client visible tags: %', v_count;

    -- Client should not be able to create tags
    BEGIN
        INSERT INTO public.tags (tag_name)
        VALUES ('New Tag')
        RETURNING id INTO new_tag_id;
        RAISE NOTICE 'Unexpectedly able to create tag';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Expected: Client cannot create tag';
    END;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    EXECUTE format('SET request.jwt.claims = ''{"sub": "%s"}''', agent1_id);

    -- Agent should be able to view tags
    SELECT COUNT(*) INTO v_count FROM public.tags;
    RAISE NOTICE 'Agent visible tags: %', v_count;

    -- Agent should not be able to create/update/delete tags
    BEGIN
        INSERT INTO public.tags (tag_name)
        VALUES ('Agent Tag')
        RETURNING id INTO new_tag_id;
        RAISE NOTICE 'Unexpectedly able to create tag';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Expected: Agent cannot create tag';
    END;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    EXECUTE format('SET request.jwt.claims = ''{"sub": "%s"}''', admin_id);

    -- Admin should be able to do everything
    SELECT COUNT(*) INTO v_count FROM public.tags;
    RAISE NOTICE 'Admin visible tags: %', v_count;

    -- Test creation
    INSERT INTO public.tags (tag_name)
    VALUES ('Admin Tag')
    RETURNING id INTO new_tag_id;
    RAISE NOTICE 'Admin created tag successfully';

    -- Test update
    UPDATE public.tags 
    SET tag_name = 'Updated Admin Tag'
    WHERE id = new_tag_id;
    RAISE NOTICE 'Admin updated tag successfully';

    -- Test deletion with verification
    SELECT COUNT(*) INTO v_count FROM public.tags;
    DELETE FROM public.tags WHERE id = new_tag_id;
    SELECT COUNT(*) INTO v_count_after FROM public.tags;
    
    IF v_count > v_count_after THEN
        RAISE NOTICE 'Admin deleted tag successfully';
    ELSE
        RAISE NOTICE 'Warning: Delete operation had no effect';
    END IF;

    -- Reset role
    RESET ROLE;
    RESET request.jwt.claims;
END $$;

ROLLBACK; 