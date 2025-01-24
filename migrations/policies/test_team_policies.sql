-- Test Cases for Team Policies
DO $$
DECLARE
    client1_id UUID;
    client2_id UUID;
    agent1_id UUID;
    admin_id UUID;
    team1_id UUID;
    team2_id UUID;
    v_count INT;
BEGIN
    -- Get user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com';
    SELECT id INTO client2_id FROM auth.users WHERE email = 'client2@email.com';
    SELECT id INTO agent1_id FROM auth.users WHERE email = 'agent1@law.com';
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com';

    -- Create test data as postgres role to bypass RLS
    SET ROLE postgres;
    
    INSERT INTO public.teams (team_name)
    VALUES ('Test Team 1')
    RETURNING id INTO team1_id;

    INSERT INTO public.team_members (team_id, user_id)
    VALUES 
        (team1_id, agent1_id),
        (team1_id, client1_id);

    -- Test as Client 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Client 1';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || client1_id::text || '"}'';';
    
    -- Should see their team
    RAISE NOTICE 'Viewing specific team (should see Test Team 1):';
    SELECT COUNT(*) INTO v_count 
    FROM public.teams 
    WHERE id = team1_id;
    RAISE NOTICE 'Client 1 can see their team: %', v_count = 1;
    
    -- Should see team members
    RAISE NOTICE 'Viewing team members:';
    SELECT COUNT(*) INTO v_count 
    FROM public.team_members 
    WHERE team_id = team1_id;
    RAISE NOTICE 'Client 1 can see % team members', v_count;
    
    -- Should not be able to create teams
    RAISE NOTICE 'Trying to create a team (should fail):';
    BEGIN
        INSERT INTO public.teams (team_name) VALUES ('Client Team');
        GET DIAGNOSTICS v_count = ROW_COUNT;
        IF v_count > 0 THEN
            RAISE NOTICE 'Unexpectedly able to create team';
        END IF;
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Access denied for team creation (expected)';
    END;

    -- Test as Agent 1
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Agent 1';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || agent1_id::text || '"}'';';
    
    -- Should see all teams
    RAISE NOTICE 'Viewing teams:';
    SELECT COUNT(*) INTO v_count 
    FROM public.teams;
    RAISE NOTICE 'Agent 1 can see % teams', v_count;
    
    -- Should be able to create teams
    RAISE NOTICE 'Creating a team (should succeed):';
    INSERT INTO public.teams (team_name) 
    VALUES ('Agent Team')
    RETURNING id INTO team2_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Successfully created team (rows: %)', v_count;
    
    -- Should be able to add team members
    RAISE NOTICE 'Adding team member (should succeed):';
    INSERT INTO public.team_members (team_id, user_id) 
    VALUES (team2_id, client2_id);
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Successfully added team member (rows: %)', v_count;

    -- Test as Admin
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Testing as Admin';
    SET ROLE authenticated;
    EXECUTE 'SET request.jwt.claims = ''{"sub": "' || admin_id::text || '"}'';';
    
    -- Should be able to do everything
    RAISE NOTICE 'Admin operations:';
    
    -- Create team
    INSERT INTO public.teams (team_name) 
    VALUES ('Admin Team')
    RETURNING id INTO team2_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Created team (rows: %)', v_count;
    
    -- Update team
    UPDATE public.teams 
    SET team_name = 'Updated Team 1' 
    WHERE id = team1_id;
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Updated % teams', v_count;
    
    -- Delete team
    DELETE FROM public.teams 
    WHERE team_name = 'Admin Team';
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RAISE NOTICE 'Deleted % teams', v_count;

    -- Cleanup (as postgres to bypass RLS)
    RAISE NOTICE '--------------------';
    RAISE NOTICE 'Cleaning up test data...';
    SET ROLE postgres;
    DELETE FROM public.team_members WHERE team_id IN (team1_id, team2_id);
    DELETE FROM public.teams WHERE id IN (team1_id, team2_id);
    
END;
$$; 