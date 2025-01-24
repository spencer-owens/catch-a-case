-- Test RLS policies for statuses table
BEGIN;

-- Variables to store test data
DO $$
DECLARE
    client1_id UUID;
    agent1_id UUID;
    admin_id UUID;
    v_count INTEGER;
    new_status_id UUID;
    max_order INTEGER;
    v_count_after INTEGER;
BEGIN
    -- Get test user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com';
    SELECT id INTO agent1_id FROM auth.users WHERE email = 'agent1@law.com';
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com';

    -- Get max order_index for new statuses
    SELECT COALESCE(MAX(order_index), 0) INTO max_order FROM public.statuses;

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    RESET ROLE;
    SET ROLE authenticated;
    EXECUTE format('SET request.jwt.claims = ''{"sub": "%s"}''', client1_id);

    -- Client should be able to view statuses
    SELECT COUNT(*) INTO v_count FROM public.statuses;
    RAISE NOTICE 'Client visible statuses: %', v_count;

    -- Client should not be able to create/update/delete statuses
    BEGIN
        INSERT INTO public.statuses (status_name, description, order_index)
        VALUES ('New Status', 'Created by client', max_order + 1)
        RETURNING id INTO new_status_id;
        RAISE NOTICE 'Unexpectedly able to create status';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Expected: Client cannot create status';
    END;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    EXECUTE format('SET request.jwt.claims = ''{"sub": "%s"}''', agent1_id);

    -- Agent should be able to view statuses
    SELECT COUNT(*) INTO v_count FROM public.statuses;
    RAISE NOTICE 'Agent visible statuses: %', v_count;
    
    -- Agent should be able to create and update statuses
    INSERT INTO public.statuses (status_name, description, order_index)
    VALUES ('Agent Status', 'Created by agent', max_order + 2)
    RETURNING id INTO new_status_id;
    RAISE NOTICE 'Agent created status successfully';

    UPDATE public.statuses 
    SET description = 'Updated by agent'
    WHERE id = new_status_id;
    RAISE NOTICE 'Agent updated status successfully';

    -- Get count after creation but before deletion attempt
    SELECT COUNT(*) INTO v_count FROM public.statuses;
    RAISE NOTICE 'Status count before deletion attempt: %', v_count;
    
    -- Try to delete and verify if deletion actually occurred
    DELETE FROM public.statuses WHERE id = new_status_id;
    
    -- Check if number of rows changed
    SELECT COUNT(*) INTO v_count_after FROM public.statuses;
    RAISE NOTICE 'Status count after deletion attempt: %', v_count_after;
    
    IF v_count = v_count_after THEN
        RAISE NOTICE 'Agent cannot delete status (deletion had no effect)';
    ELSIF v_count > v_count_after THEN
        RAISE NOTICE 'WARNING: Agent successfully deleted status!';
    ELSE
        RAISE NOTICE 'WARNING: Unexpected count change!';
    END IF;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    EXECUTE format('SET request.jwt.claims = ''{"sub": "%s"}''', admin_id);

    -- Admin should be able to do everything
    SELECT COUNT(*) INTO v_count FROM public.statuses;
    RAISE NOTICE 'Admin visible statuses: %', v_count;

    INSERT INTO public.statuses (status_name, description, order_index)
    VALUES ('Admin Status', 'Created by admin', max_order + 3)
    RETURNING id INTO new_status_id;
    RAISE NOTICE 'Admin created status successfully';

    UPDATE public.statuses 
    SET description = 'Updated by admin'
    WHERE id = new_status_id;
    RAISE NOTICE 'Admin updated status successfully';

    DELETE FROM public.statuses WHERE id = new_status_id;
    RAISE NOTICE 'Admin deleted status successfully';

    -- Reset role
    RESET ROLE;
    RESET "request.jwt.claims";
END $$;

ROLLBACK; 