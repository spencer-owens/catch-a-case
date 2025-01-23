# Phase 4: Messaging & Internal Notes

> Implements the real-time or near-real-time communication aspects, as well as agent-only internal notes. References @important-considerations.md for performance tips.

## Prerequisites
- Phase 3 completed (basic CRUD for cases)
- Real-time strategy understood (Supabase Realtime or other socket-based approach)

## Steps
1. [ ] BACKEND: Implement POST /cases/:caseId/messages and GET /cases/:caseId/messages endpoints for client-agent communication  
2. [ ] FRONTEND: Build a messages UI on "Case Details" or a dedicated "Messaging" tab  
3. [ ] BACKEND: Create a subscription channel in Supabase or websockets for new messages, if real-time updates are required  
4. [ ] FRONTEND: Subscribe to the relevant message channel for live updates (agent sees new client messages instantly, and vice versa)  
5. [ ] BACKEND: Implement POST /cases/:caseId/notes and GET /cases/:caseId/notes for agent-only internal notes  
6. [ ] FRONTEND: Provide an "Internal Notes" section visible only to agents, ignoring for clients  
7. [ ] Validate RLS policies for messages and notes (clients can't see agent notes, agents can't see messages for unassigned cases, etc.)

## Success Criteria
- Real-time or near-real-time messaging between client and assigned agent is functional  
- Internal notes remain hidden from clients  
- Subscriptions or polling solutions ensure message updates appear without manual refresh  
- RLS/permissions thoroughly enforced

## Test Cases
- Happy path: Client and agent exchange messages in real-time; agent sees and creates internal notes not visible to client  
- Error/edge case: Unassigned agent attempts to POST a message to a case not assigned to them, receiving an error  
- Validation test: Confirm that clients never see internal notes on the case detail or API calls 