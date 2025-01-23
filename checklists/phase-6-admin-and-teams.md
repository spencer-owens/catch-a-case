# Phase 6: Admin Dashboard & Team Management

> Implements advanced management features for Admins, including team creation and user assignment. References @routing-requirements.md and @product-requirements.md.

## Prerequisites
- Phase 5 completed (all core client/agent flows)
- Roles confirmed to include admin capabilities

## Steps
1. [ ] BACKEND: Implement routes for /teams (POST, GET, PUT, DELETE) as specified in @routing-requirements.md  
2. [ ] BACKEND: Implement /teams/:teamId/assign-user to manage agent membership  
3. [ ] FRONTEND: Create an "Admin Dashboard" page listing all teams and admin-only actions (create team, edit team, remove team)  
4. [ ] FRONTEND: Implement user assignment flow—admin picks an existing user (agent) to place in a team  
5. [ ] BACKEND: Ensure RLS or role checks prevent non-admin users from performing these actions  
6. [ ] FRONTEND: Display team info on agent dashboards (e.g., which team(s) the agent is part of) if needed  
7. [ ] Validate that team membership is reflected in the DB join table

## Success Criteria
- Admin-only team management fully functional (CRUD + user assignment)  
- Non-admin attempts to create/update/delete a team are blocked at the API level  
- UI clearly separates admin functionality from agent/client dashboards  
- Teams can be shown or integrated into agent workflows (optional, depending on product needs)

## Test Cases
- Happy path: Admin creates a new "Team A," assigns two agents, and they appear in /teams and membership lists  
- Error/edge case: Attempting to create or delete a team as a non-admin returns an error  
- Validation test: Checking agent's team membership in the database 