-- Update function to handle both new user creation and updates
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  role_value public.user_role;
  full_name_value text;
  existing_user RECORD;
BEGIN
  -- Get full_name from metadata or create from email
  full_name_value := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    split_part(NEW.email, '@', 1)  -- Use part before @ in email as fallback
  );

  -- Update auth.users with the full_name in metadata if it's not set
  IF NEW.raw_user_meta_data->>'full_name' IS NULL THEN
    UPDATE auth.users 
    SET raw_user_meta_data = 
      CASE 
        WHEN raw_user_meta_data IS NULL THEN 
          jsonb_build_object('full_name', full_name_value)
        ELSE 
          raw_user_meta_data || jsonb_build_object('full_name', full_name_value)
      END
    WHERE id = NEW.id;
  END IF;

  -- Check if user already exists
  SELECT * INTO existing_user FROM public.users WHERE id = NEW.id;
  
  IF existing_user.id IS NULL THEN
    -- New user - set role from metadata, defaulting to client
    BEGIN
      role_value := (COALESCE(NEW.raw_user_meta_data->>'role', 'client'))::public.user_role;
    EXCEPTION WHEN invalid_text_representation THEN
      role_value := 'client'::public.user_role;
    END;

    -- Insert new user
    INSERT INTO public.users (id, email, role, full_name)
    VALUES (
      NEW.id,
      NEW.email,
      role_value,
      full_name_value
    );
  ELSE
    -- Existing user - update email and full_name only, preserve existing role
    UPDATE public.users
    SET 
      email = NEW.email,
      full_name = full_name_value
    WHERE id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate trigger to handle both INSERT and UPDATE
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user(); 