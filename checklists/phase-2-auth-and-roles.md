# Phase 2: Authentication & Role Management

> Builds on @product-requirements.md, ensuring Supabase Auth integration (or custom JWT if you prefer). References RLS and role-based access guidelines.

## Prerequisites
- Phase 1 completed (database schema in place)
- Familiarity with Supabase Auth or chosen auth provider

## Steps
1. [ ] BACKEND: Configure Supabase Auth for email/password signups, or set up custom token handling  
2. [ ] BACKEND: Write or refine RLS policies to align with user roles (client, agent, admin)  
3. [ ] FRONTEND: Build a "Register" page or component for new user signups (optional if Admin only can create accounts)  
4. [ ] FRONTEND: Create a "Login" page or modal that integrates with Supabase Auth's login endpoint  
5. [ ] FRONTEND: Implement a global auth store (Zustand or React Context) storing the current user's token and role  
6. [ ] FRONTEND: Add route guards or protected routes for agent/admin-only pages (e.g., admin dashboards, team management)  
7. [ ] BACKEND: Validate that newly registered users appear correctly in the "Users" table with their assigned role  
8. [ ] FRONTEND/BACKEND: Test user flows: register -> login -> restricted page access

## Success Criteria
- A working signup/login flow with session storage (JWT, local storage, or Supabase session)  
- Role-based route protection verified on both front and back end (RLS for DB, protected routes for UI)  
- Admin users can potentially manage other users or roles, as specified  
- Auth session renews or logs out gracefully

## Test Cases
- Happy path: User registers as "client," logs in, sees client dashboard, but can't access agent/admin areas  
- Error/edge case: Duplicates or invalid role creation gracefully handled  
- Validation test: Admin route returns 403 for a logged-in client, verifying backend checks 