-- Test RLS policies for feedback table
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
    v_count INTEGER;
    new_feedback_id UUID;
    existing_feedback_id UUID;
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

    -- Clean up any existing feedback for our test cases
    DELETE FROM public.feedback WHERE case_id IN (case1_id, case2_id);

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || client1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Client should see feedback for their cases
    SELECT COUNT(*) INTO v_count FROM public.feedback
    WHERE case_id = case1_id;
    RAISE NOTICE 'Client 1 can see % feedback entries for their case', v_count;

    -- Client should be able to create feedback for their case
    INSERT INTO public.feedback (case_id, client_id, rating, comments)
    VALUES (case1_id, client1_id, 5, 'Great service!')
    RETURNING id INTO new_feedback_id;
    RAISE NOTICE 'Client 1 created feedback successfully';

    -- Client should not be able to create feedback for another case
    BEGIN
        INSERT INTO public.feedback (case_id, client_id, rating, comments)
        VALUES (case2_id, client2_id, 4, 'Not my case!');
        RAISE NOTICE 'Client 1 unexpectedly created feedback for another case';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Client 1 could not create feedback for another case (expected)';
        WHEN OTHERS THEN
            IF SQLERRM LIKE '%Invalid case_id%' THEN
                RAISE NOTICE 'Client 1 could not create feedback for another case (trigger validation)';
            ELSE
                RAISE;
            END IF;
    END;

    -- Client should be able to update their own feedback
    UPDATE public.feedback 
    SET rating = 4, comments = 'Updated comments'
    WHERE id = new_feedback_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    IF v_count > 0 THEN
        RAISE NOTICE 'Client 1 updated their feedback successfully';
    ELSE
        RAISE NOTICE 'Client 1 could not update their feedback (unexpected)';
    END IF;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || agent1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Agent should see feedback for their assigned cases
    SELECT COUNT(*) INTO v_count FROM public.feedback f
    JOIN public.cases c ON c.id = f.case_id
    WHERE c.assigned_agent_id = agent1_id;
    RAISE NOTICE 'Agent 1 can see % feedback entries for their assigned case', v_count;

    -- Agent should not be able to create feedback
    BEGIN
        INSERT INTO public.feedback (case_id, client_id, rating, comments)
        VALUES (case1_id, client1_id, 3, 'Agent feedback');
        RAISE NOTICE 'Agent 1 unexpectedly created feedback';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Agent 1 could not create feedback (expected)';
    END;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || admin_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Admin should see all feedback
    SELECT COUNT(*) INTO v_count FROM public.feedback;
    RAISE NOTICE 'Admin can see % total feedback entries', v_count;

    -- Admin should be able to create feedback
    INSERT INTO public.feedback (case_id, client_id, rating, comments)
    VALUES (case2_id, client2_id, 5, 'Admin created feedback')
    RETURNING id INTO new_feedback_id;
    RAISE NOTICE 'Admin created feedback successfully';

END;
$$;

ROLLBACK; 