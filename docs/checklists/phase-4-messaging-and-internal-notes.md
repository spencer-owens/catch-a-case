# Phase 4: Messaging & Internal Notes

> Implements the real-time or near-real-time communication aspects, as well as agent-only internal notes. References @important-considerations.md for performance tips.

## Prerequisites
- [x] Phase 3 completed (basic CRUD for cases)
- [x] Real-time strategy understood (Supabase Realtime or other socket-based approach)

## Steps
1. [x] BACKEND: Implement POST /cases/:caseId/messages and GET /cases/:caseId/messages endpoints for client-agent communication  
2. [x] FRONTEND: Build a messages UI on "Case Details" or a dedicated "Messaging" tab  
3. [x] BACKEND: Create a subscription channel in Supabase Realtime for new messages 
4. [x] FRONTEND: Subscribe to the relevant message channel for live updates (agent sees new client messages instantly, and vice versa)  
5. [x] BACKEND: Implement POST /cases/:caseId/notes and GET /cases/:caseId/notes for agent-only internal notes  
6. [x] FRONTEND: Provide an "Internal Notes" section visible only to agents, ignoring for clients  
7. [x] Validate RLS policies for messages and notes (clients can't see agent notes, agents can't see messages for unassigned cases, etc.)

## Success Criteria
- [x] Real-time or near-real-time messaging between client and assigned agent is functional  
- [x] Internal notes remain hidden from clients  
- [x] Subscriptions or polling solutions ensure message updates appear without manual refresh  
- [x] RLS/permissions thoroughly handled

## Test Cases
- [x] Happy path: Client and agent exchange messages in real-time; agent sees and creates internal notes not visible to client  
- [x] Error/edge case: Unassigned agent attempts to POST a message to a case not assigned to them, receiving an error  
- [x] Validation test: Confirm that clients never see internal notes on the case detail or API calls 