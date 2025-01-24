-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  role_value public.user_role;
  full_name_value text;
BEGIN
  -- Safely cast the role, defaulting to 'client' if invalid
  BEGIN
    role_value := (COALESCE(NEW.raw_user_meta_data->>'role', 'client'))::public.user_role;
  EXCEPTION WHEN invalid_text_representation THEN
    role_value := 'client'::public.user_role;
  END;

  -- Get full_name from metadata or create from email
  full_name_value := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    split_part(NEW.email, '@', 1)  -- Use part before @ in email as fallback
  );

  INSERT INTO public.users (id, email, role, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    role_value,
    full_name_value
  )
  ON CONFLICT (id) DO UPDATE
  SET 
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    full_name = EXCLUDED.full_name;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user(); 