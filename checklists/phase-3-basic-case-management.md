# Phase 3: Basic Case Management (CRUD)

> Implements core case creation, retrieval, and updates as specified in @product-requirements.md and @routing-requirements.md.

## Prerequisites
- Phase 2 completed (authentication and roles functional)
- Database schema for Cases, Users, etc. established

## Steps
1. [ ] BACKEND: Implement POST /cases endpoint allowing a client to create new cases  
2. [ ] FRONTEND: Build a "Create Case" form or page (title, description, initial status, etc.)  
3. [ ] BACKEND: Implement GET /cases/:caseId route restricting access to case owner, assigned agent, or admin  
4. [ ] FRONTEND: Create a "Case Details" page showing case info, assigned agent, status, etc.  
5. [ ] BACKEND: Implement PUT /cases/:caseId to allow assigned agent or admin to update case data (status, description)  
6. [ ] FRONTEND: Provide a "My Cases" or "Dashboard" view for clients (lists the user's own cases)  
7. [ ] FRONTEND: Provide a "Cases Assigned to Me" or "Agent Dashboard" for agents  
8. [ ] Test integrated flows: create a case (client), assign an agent (admin or agent?), update that case, confirm only assigned roles can see it

## Success Criteria
- A verified end-to-end create -> read -> update flow for cases  
- Clients can only see or modify their own cases (except for RLS or admin overrides)  
- Agents see only cases assigned to them (plus any user interface for reassigning if that's part of the design)  
- The user experience is consistent with role-based access rules

## Test Cases
- Happy path: Client logs in, creates a case, agent or admin updates its status, verifying ownership constraints  
- Error/edge case: Another client tries to retrieve a case that isn't theirs and is denied  
- Validation test: Role checks on each endpoint (client, agent, admin) 