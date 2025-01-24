-- Test RLS policies for cases_tags table
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
    tag1_id UUID;
    tag2_id UUID;
    v_count INTEGER;
    new_case_tag_id UUID;
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

    -- Get test tag IDs
    SELECT id INTO tag1_id FROM public.tags WHERE tag_name = 'Urgent';
    SELECT id INTO tag2_id FROM public.tags WHERE tag_name = 'High Value';

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || client1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Client should see tags for their cases
    SELECT COUNT(*) INTO v_count FROM public.cases_tags ct
    JOIN public.cases c ON c.id = ct.case_id
    WHERE c.client_id = client1_id;
    RAISE NOTICE 'Client 1 can see % case tags for their case', v_count;

    -- Client should not be able to create case tags
    BEGIN
        INSERT INTO public.cases_tags (case_id, tag_id)
        VALUES (case1_id, tag1_id)
        RETURNING id INTO new_case_tag_id;
        RAISE NOTICE 'Client 1 unexpectedly created case tag';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Client 1 could not create case tag (expected)';
    END;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || agent1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Agent should see case tags for their assigned cases
    SELECT COUNT(*) INTO v_count FROM public.cases_tags ct
    JOIN public.cases c ON c.id = ct.case_id
    WHERE c.assigned_agent_id = agent1_id;
    RAISE NOTICE 'Agent 1 can see % case tags for their assigned case', v_count;

    -- Agent should be able to create case tags for their assigned cases
    INSERT INTO public.cases_tags (case_id, tag_id)
    VALUES (case1_id, tag2_id)
    RETURNING id INTO new_case_tag_id;
    RAISE NOTICE 'Agent 1 created case tag successfully';

    -- Agent should not be able to create case tags for unassigned cases
    BEGIN
        INSERT INTO public.cases_tags (case_id, tag_id)
        VALUES (case2_id, tag2_id);
        RAISE NOTICE 'Agent 1 unexpectedly created case tag for unassigned case';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Agent 1 could not create case tag for unassigned case (expected)';
    END;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    RESET ROLE;
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || admin_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Admin should see all case tags
    SELECT COUNT(*) INTO v_count FROM public.cases_tags;
    RAISE NOTICE 'Admin can see % total case tags', v_count;

    -- Admin should be able to create any case tag
    INSERT INTO public.cases_tags (case_id, tag_id)
    VALUES (case2_id, tag1_id)
    RETURNING id INTO new_case_tag_id;
    RAISE NOTICE 'Admin created case tag successfully';

END;
$$;

ROLLBACK;