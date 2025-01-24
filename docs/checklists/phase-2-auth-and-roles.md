# Phase 2: Authentication & Role Management

> Builds on @product-requirements.md, ensuring Supabase Auth integration (or custom JWT if you prefer). References RLS and role-based access guidelines.

## Prerequisites
- [x] Phase 1 completed (database schema in place)
- [x] Familiarity with Supabase Auth or chosen auth provider

## Steps
1. [x] BACKEND: Configure Supabase Auth for email/password signups
   - [x] Set up Supabase client
   - [x] Configure email templates (if needed)
   - [x] Set up auth callback handling

2. [x] BACKEND: Check or refine RLS policies to align with user roles (client, agent, admin)
   - [x] Review existing RLS policies
   - [x] Verify policies match requirements
   - [x] Test policy effectiveness

3. [x] FRONTEND: Build a "Register" page or component for new user signups
   - [x] Create SignUpForm component
   - [x] Add form validation
   - [x] Handle registration errors
   - [x] Show success message

4. [x] FRONTEND: Create a "Login" page or modal that integrates with Supabase Auth's login endpoint
   - [x] Create LoginForm component
   - [x] Add form validation
   - [x] Handle login errors
   - [x] Redirect after successful login

5. [x] FRONTEND: Implement a global auth store (React Context) storing the current user's token and role
   - [x] Create AuthContext
   - [x] Add auth state management
   - [x] Implement auth methods (login, logout, etc.)
   - [x] Add loading states

6. [x] FRONTEND: Add route guards or protected routes for agent/admin-only pages
   - [x] Create ProtectedRoute component
   - [x] Add role-based access control
   - [x] Handle unauthorized access
   - [x] Add loading states

7. [x] BACKEND: Validate that newly registered users appear correctly in the "Users" table with their assigned role
   - [x] Verify user data storage
   - [x] Check role assignment
   - [x] Test user metadata

8. [ ] FRONTEND/BACKEND: Test user flows
   - [ ] Test registration flow
   - [ ] Test login flow
   - [ ] Test role-based access
   - [ ] Test email confirmation
   - [ ] Test error handling

## Success Criteria
- [ ] A working signup/login flow with session storage (JWT, local storage, or Supabase session)
- [ ] Role-based route protection verified on both front and back end (RLS for DB, protected routes for UI)
- [ ] Admin users can potentially manage other users or roles, as specified
- [ ] Auth session renews or logs out gracefully

## Test Cases
- [ ] Happy path: User registers as "client," logs in, sees client dashboard, but can't access agent/admin areas
- [ ] Error/edge case: Duplicates or invalid role creation gracefully handled
- [ ] Validation test: Admin route returns 403 for a logged-in client, verifying backend checks 