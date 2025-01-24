-- Enable RLS testing by setting up auth context
CREATE OR REPLACE FUNCTION set_authenticated_context()
RETURNS TEXT LANGUAGE SQL SECURITY DEFINER AS $$
  SELECT set_config('role', 'authenticated', false);
$$;

-- Function to set auth.uid() to a specific user
CREATE OR REPLACE FUNCTION set_user_id(user_email TEXT)
RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_uid UUID;
BEGIN
  SELECT id INTO v_uid FROM auth.users WHERE email = user_email;
  PERFORM set_config('request.jwt.claims', json_build_object('sub', v_uid::TEXT)::TEXT, false);
  RETURN v_uid;
END;
$$;

-- Test Cases
DO $$
DECLARE
  client1_id UUID;
  client2_id UUID;
  agent3_id UUID;
  admin_id UUID;
  v_count INT;
  v_case_id UUID;
BEGIN
    -- Get user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com';
    SELECT id INTO client2_id FROM auth.users WHERE email = 'client2@email.com';
    SELECT id INTO agent3_id FROM auth.users WHERE email = 'agent3@law.com';
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com';

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || client1_id::text || '"}'';';
    
    -- Should see only their own cases
    RAISE NOTICE 'Viewing cases (should see only their own):';
    SELECT COUNT(*) INTO v_count FROM public.cases;
    RAISE NOTICE 'Client 1 can see % cases', v_count;
    
    -- Should not see internal notes
    RAISE NOTICE 'Trying to view internal notes (should fail):';
    BEGIN
        SELECT COUNT(*) INTO v_count FROM public.internal_notes;
        RAISE NOTICE 'Unexpectedly able to see % internal notes', v_count;
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Access denied for internal notes (expected)';
    END;

    -- Test as Agent 3
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 3';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || agent3_id::text || '"}'';';
    
    -- Should see all cases
    RAISE NOTICE 'Viewing all cases (should see all):';
    SELECT COUNT(*) INTO v_count FROM public.cases;
    RAISE NOTICE 'Agent 3 can see % cases', v_count;
    
    -- Should see internal notes
    RAISE NOTICE 'Viewing internal notes (should succeed):';
    SELECT COUNT(*) INTO v_count FROM public.internal_notes;
    RAISE NOTICE 'Agent 3 can see % internal notes', v_count;
    
    -- Should not be able to update unassigned case
    RAISE NOTICE 'Trying to update an unassigned case (should fail):';
    
    -- Get the Car Accident Case ID (assigned to agent1)
    SELECT id INTO v_case_id FROM public.cases WHERE title = 'Car Accident Case';
    
    UPDATE public.cases 
    SET description = 'Updated description'
    WHERE id = v_case_id;
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE NOTICE 'Unexpectedly able to update unassigned case';
    ELSE
        RAISE NOTICE 'Access denied for unassigned case (expected)';
    END IF;

    -- Should be able to update assigned case
    RAISE NOTICE 'Trying to update an assigned case (should succeed):';
    BEGIN
        -- Get the Personal Injury Case ID (assigned to agent3)
        SELECT id INTO v_case_id FROM public.cases WHERE title = 'Personal Injury Case';
        
        UPDATE public.cases 
        SET description = 'Updated by assigned agent'
        WHERE id = v_case_id;
        
        GET DIAGNOSTICS v_count = ROW_COUNT;
        RAISE NOTICE 'Successfully updated % assigned case', v_count;
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Unexpected access denial for assigned case';
    END;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || admin_id::text || '"}'';';
    
    -- Should see everything
    RAISE NOTICE 'Viewing all cases (should see all):';
    SELECT COUNT(*) INTO v_count FROM public.cases;
    RAISE NOTICE 'Admin can see % cases', v_count;
    
    -- Should be able to update any case
    RAISE NOTICE 'Updating any case (should succeed):';
    UPDATE public.cases 
    SET description = 'Admin updated description'
    WHERE title = 'Car Accident Case';
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Admin updated % cases', v_count;

    -- Test as Client 2
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 2';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || client2_id::text || '"}'';';
    
    -- Should not see Client 1's cases
    RAISE NOTICE 'Trying to view another clients case (should not see it):';
    SELECT COUNT(*) INTO v_count FROM public.cases WHERE client_id = client1_id;
    RAISE NOTICE 'Client 2 can see % of Client 1''s cases', v_count;

END;
$$;
