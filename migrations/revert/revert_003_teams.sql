-- Drop tables and all dependent objects
DROP TABLE IF EXISTS team_members CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE; 