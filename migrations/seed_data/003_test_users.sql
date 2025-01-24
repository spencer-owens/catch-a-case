-- First, create users in auth.users (minimal required fields)
INSERT INTO auth.users (
    id,
    email,
    role,
    created_at,
    updated_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    is_sso_user,
    is_anonymous
)
VALUES 
    (
        '00000000-0000-0000-0000-000000000001',
        'test.admin@example.com',
        'admin'::user_role,
        NOW(),
        NOW(),
        '{"provider": "email"}',
        '{"role": "admin"}',
        'authenticated',
        false,
        false
    ),
    (
        '00000000-0000-0000-0000-000000000002',
        'test.agent@example.com',
        'agent'::user_role,
        NOW(),
        NOW(),
        '{"provider": "email"}',
        '{"role": "agent"}',
        'authenticated',
        false,
        false
    )
ON CONFLICT (id) DO UPDATE
SET 
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    raw_user_meta_data = EXCLUDED.raw_user_meta_data;

-- Then create/update corresponding entries in public.users
INSERT INTO public.users (id, email, role, full_name, created_at, updated_at)
SELECT 
    id,
    email,
    role::text::user_role,
    CASE 
        WHEN id = '00000000-0000-0000-0000-000000000001' THEN 'Test Admin'
        WHEN id = '00000000-0000-0000-0000-000000000002' THEN 'Test Agent'
    END,
    created_at,
    updated_at
FROM auth.users
WHERE id IN (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002'
)
ON CONFLICT (id) DO UPDATE
SET 
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    full_name = EXCLUDED.full_name,
    updated_at = NOW();

-- Function to create a test user with proper role
CREATE OR REPLACE FUNCTION create_test_user(
    p_id UUID,
    p_email TEXT,
    p_role TEXT,
    p_full_name TEXT
) RETURNS void AS $$
BEGIN
    -- First ensure the user exists in public.users
    INSERT INTO public.users (id, email, role, full_name, created_at, updated_at)
    VALUES (p_id, p_email, p_role, p_full_name, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE
    SET 
        email = EXCLUDED.email,
        role = EXCLUDED.role,
        full_name = EXCLUDED.full_name,
        updated_at = NOW();

    -- Update user metadata
    UPDATE auth.users
    SET 
        role = p_role,
        raw_user_meta_data = jsonb_build_object('role', p_role)
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- Create test users
SELECT create_test_user(
    '00000000-0000-0000-0000-000000000001',
    'test.admin@example.com',
    'admin',
    'Test Admin'
);

SELECT create_test_user(
    '00000000-0000-0000-0000-000000000002',
    'test.agent@example.com',
    'agent',
    'Test Agent'
); 