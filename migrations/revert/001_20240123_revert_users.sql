 -- Revert script for users table
BEGIN;

DROP TABLE IF EXISTS public.users CASCADE;

ROLLBACK;