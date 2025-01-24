 -- Master migration script
-- Generated on January 23, 2024

BEGIN;

-- Schema migrations
\echo 'Running schema migrations...'
\i schema/001_20240123_create_users_table.sql
\i schema/002_20240123_create_teams_tables.sql
\i schema/003_20240123_create_cases_and_related_tables.sql
\i schema/004_20240123_create_notes_messages_attachments_feedback.sql

-- Function migrations
\echo 'Running function migrations...'
\i functions/001_auth_helpers.sql

-- Trigger migrations
\echo 'Running trigger migrations...'
\i triggers/001_audit_triggers.sql
\i triggers/002_validation_triggers.sql

-- Policy migrations
\echo 'Running policy migrations...'
\i policies/001_20240123_basic_table_policies.sql
\i policies/002_20240123_message_policies.sql
\i policies/008_20240123_message_attachments_policies.sql

-- Performance migrations
\echo 'Running performance migrations...'
\i performance/001_add_performance_indexes.sql

COMMIT;

\echo 'All migrations completed successfully!'