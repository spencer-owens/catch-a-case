-- Test attachments policies
DO $$
DECLARE
    client1_id UUID;
    agent1_id UUID;
    admin_id UUID;
    case1_id UUID;
    case2_id UUID;
    attachment1_id UUID;
    attachment2_id UUID;
    v_count INTEGER;
    jwt_claims TEXT;
BEGIN
    -- Get test user IDs
    SELECT id INTO client1_id FROM auth.users WHERE email = 'client1@email.com' LIMIT 1;
    SELECT id INTO agent1_id FROM auth.users WHERE email = 'agent1@law.com' LIMIT 1;
    SELECT id INTO admin_id FROM auth.users WHERE email = 'admin@law.com' LIMIT 1;

    -- Get test case IDs
    SELECT id INTO case1_id FROM public.cases WHERE title = 'Car Accident Case' LIMIT 1;
    SELECT id INTO case2_id FROM public.cases WHERE title = 'Medical Negligence Case' LIMIT 1;

    -- Insert test attachments
    WITH inserted_attachments AS (
        INSERT INTO public.attachments (id, case_id, uploader_id, file_name, file_type, file_size, file_path)
        VALUES 
            (gen_random_uuid(), case1_id, agent1_id, 'test1.pdf', 'application/pdf', 1024, '/test1.pdf'),
            (gen_random_uuid(), case2_id, agent1_id, 'test2.pdf', 'application/pdf', 2048, '/test2.pdf')
        RETURNING id
    )
    SELECT id INTO attachment1_id FROM inserted_attachments LIMIT 1;

    -- Verify table structure
    SELECT COUNT(*) INTO v_count 
    FROM information_schema.columns 
    WHERE table_name = 'attachments';

    RAISE NOTICE 'Attachments table has % columns', v_count;

    -- Test as Client 1
    RAISE NOTICE 'Testing as Client 1';
    SET ROLE authenticated;
    jwt_claims := '{"sub": "' || client1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Client should see attachments for their cases
    SELECT COUNT(*) INTO v_count FROM public.attachments WHERE case_id = case1_id;
    RAISE NOTICE 'Client can see % attachments for their case', v_count;

    -- Client should be able to upload to their case
    BEGIN
        INSERT INTO public.attachments (case_id, uploader_id, file_name, file_type, file_size, file_path)
        VALUES (case1_id, client1_id, 'client_doc.pdf', 'application/pdf', 1024, '/client_doc.pdf');
        RAISE NOTICE 'Client successfully uploaded attachment to their case';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Client cannot upload attachment (insufficient privilege)';
    END;

    -- Client should not be able to upload to other cases
    BEGIN
        INSERT INTO public.attachments (case_id, uploader_id, file_name, file_type, file_size, file_path)
        VALUES (case2_id, client1_id, 'client_doc2.pdf', 'application/pdf', 1024, '/client_doc2.pdf');
        RAISE NOTICE 'Unexpectedly able to upload to other case';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Client cannot upload to other case (expected)';
    END;

    -- Test as Agent 1
    RAISE NOTICE 'Testing as Agent 1';
    jwt_claims := '{"sub": "' || agent1_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Agent should see all attachments
    SELECT COUNT(*) INTO v_count FROM public.attachments;
    RAISE NOTICE 'Agent can see % attachments', v_count;

    -- Agent should be able to upload to assigned case
    BEGIN
        INSERT INTO public.attachments (case_id, uploader_id, file_name, file_type, file_size, file_path)
        VALUES (case1_id, agent1_id, 'agent_doc.pdf', 'application/pdf', 1024, '/agent_doc.pdf');
        RAISE NOTICE 'Agent successfully uploaded attachment';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Agent cannot upload attachment (unexpected)';
    END;

    -- Agent should be able to update their own attachments
    BEGIN
        UPDATE public.attachments 
        SET file_name = 'updated.pdf'
        WHERE id = attachment1_id;
        RAISE NOTICE 'Agent successfully updated their attachment';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Agent cannot update their attachment (unexpected)';
    END;

    -- Test as Admin
    RAISE NOTICE 'Testing as Admin';
    jwt_claims := '{"sub": "' || admin_id::text || '"}';
    EXECUTE 'SET request.jwt.claims = ' || quote_literal(jwt_claims);

    -- Admin should see all attachments
    SELECT COUNT(*) INTO v_count FROM public.attachments;
    RAISE NOTICE 'Admin can see % attachments', v_count;

    -- Admin should be able to upload attachments
    BEGIN
        INSERT INTO public.attachments (case_id, uploader_id, file_name, file_type, file_size, file_path)
        VALUES (case1_id, admin_id, 'admin_doc.pdf', 'application/pdf', 1024, '/admin_doc.pdf');
        RAISE NOTICE 'Admin successfully uploaded attachment';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Admin cannot upload attachment (unexpected)';
    END;

    -- Admin should be able to delete any attachment
    BEGIN
        DELETE FROM public.attachments WHERE id = attachment1_id;
        RAISE NOTICE 'Admin successfully deleted attachment';
    EXCEPTION
        WHEN insufficient_privilege THEN
            RAISE NOTICE 'Admin cannot delete attachment (unexpected)';
    END;

    ROLLBACK;
END $$; 