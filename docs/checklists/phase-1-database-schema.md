# Phase 1: Database Schema & Migrations

> In accordance with @phase-creation-guide.md (database first principle) and @data-model.md. Keep RLS in mind and set up skeleton migrations.

## Prerequisites
- Phase 0 completed (project structure and dev environment ready)
- Supabase project created (if using Supabase) or local PostgreSQL environment

## Steps
1. [ ] BACKEND: Create "Users" table (id, email, password_hash, role, full_name, created_at, updated_at)  
2. [ ] BACKEND: Create "Teams" table + join table (team_members) referencing Users  
3. [ ] BACKEND: Create "Cases" table referencing Users (client_id, assigned_agent_id), plus fields for status, title, and description  
4. [ ] BACKEND: Create "Statuses" (dynamic), "Tags" + join table (cases_tags), "Custom Fields" table, "Internal Notes," "Messages," "Attachments," and "Feedback" as specified in @data-model.md  
5. [ ] BACKEND: Apply any indexing or constraints for performance (e.g., unique indexes on email or tag_name)  
6. [ ] BACKEND: Enable basic Row Level Security (RLS) in Supabase (or PostgreSQL) for each table, ensuring only owners or assigned roles can access data  
7. [ ] BACKEND: Generate sample migrations or SQL scripts to recreate the schema consistently  
8. [ ] BACKEND: Load realistic test data (Clients, Agents, Admins, sample Cases, etc.) to validate relationships

## Success Criteria
- All tables and relationships match @data-model.md specs  
- RLS is in place and tested (e.g., a non-owner user cannot see data)  
- Migrations or SQL dumps are available for new developers  
- Test data verifies that relationships work (e.g., queries return Cases for a specific client)

## Test Cases
- Happy path: Running the migrations creates all tables without errors  
- Error/edge case: Attempting to read data from a table without the correct RLS policy is blocked  
- Validation test: Sample queries confirm foreign key constraints and relationships are correct 