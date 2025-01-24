DO $$
DECLARE
    admin_id UUID;
    agent_id UUID;
    test_team_id UUID;
    v_count INT;
BEGIN
    -- Get existing users with admin and agent roles
    SELECT id INTO admin_id FROM auth.users WHERE role = 'admin' LIMIT 1;
    SELECT id INTO agent_id FROM auth.users WHERE role = 'agent' LIMIT 1;
    
    IF admin_id IS NULL OR agent_id IS NULL THEN
        RAISE EXCEPTION 'Test requires at least one admin and one agent user in auth.users';
    END IF;

    -- 1. Test admin creating a team
    SET ROLE authenticated;
    EXECUTE 'SET LOCAL "request.jwt.claims" = ''{"sub": "' || admin_id || '", "role": "admin"}''';
    
    INSERT INTO teams (team_name)
    VALUES ('Test Team')
    RETURNING id INTO test_team_id;
    
    RAISE NOTICE 'Admin created team successfully';

    -- 2. Test agent trying to create a team (should fail)
    EXECUTE 'SET LOCAL "request.jwt.claims" = ''{"sub": "' || agent_id || '", "role": "agent"}''';
    
    BEGIN
        INSERT INTO teams (team_name)
        VALUES ('Agent Team');
        RAISE EXCEPTION 'Expected failure: Agent should not be able to create teams';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Agent blocked from creating team (expected)';
    END;

    -- 3. Test admin adding agent to team
    EXECUTE 'SET LOCAL "request.jwt.claims" = ''{"sub": "' || admin_id || '", "role": "admin"}''';
    
    INSERT INTO team_members (team_id, user_id)
    VALUES (test_team_id, agent_id);
    
    RAISE NOTICE 'Admin added agent to team successfully';

    -- 4. Test agent viewing their team
    EXECUTE 'SET LOCAL "request.jwt.claims" = ''{"sub": "' || agent_id || '", "role": "agent"}''';
    
    SELECT COUNT(*) INTO v_count 
    FROM teams 
    WHERE id = test_team_id;
    
    IF v_count = 1 THEN
        RAISE NOTICE 'Agent can view their team (expected)';
    ELSE
        RAISE EXCEPTION 'Agent cannot view their team (unexpected)';
    END IF;

    -- 5. Test agent trying to add another user (should fail)
    BEGIN
        INSERT INTO team_members (team_id, user_id)
        VALUES (test_team_id, gen_random_uuid());
        RAISE EXCEPTION 'Expected failure: Agent should not be able to add team members';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'Agent blocked from adding team members (expected)';
    END;

    -- Clean up
    EXECUTE 'SET LOCAL "request.jwt.claims" = ''{"sub": "' || admin_id || '", "role": "admin"}''';
    DELETE FROM teams WHERE id = test_team_id;
    
    -- Reset role
    RESET ROLE;
    RESET "request.jwt.claims";
    
    RAISE NOTICE 'All Teams RLS tests completed successfully';
END $$; 