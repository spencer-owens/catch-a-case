# Product Requirements

## Project Overview
A modern case management system designed for personal injury attorneys, leveraging Supabase for auth, real-time data, and storage. It provides role-based access to manage cases, communicate securely, and automate workflows.

## Core Workflows
1. Users register and authenticate with Supabase Auth.  
2. Clients create and manage their cases and communicate with Agents.  
3. Agents update case statuses, perform internal notes, and handle real-time messaging.  
4. Admins oversee Teams, system settings, and generate reports.

## Technical Foundation

### Data Models
• Users (Clients, Agents, Admins) with roles, secure credentials, and timestamps.  
• Teams for grouping Agents; association with Agents managed via a join table.  
• Cases storing client_id, assigned_agent_id, status, timestamps, and descriptions.  
• Statuses defining workflow stages (Intake, Litigation, etc.) with Admin flexibility.  
• Tags for case categorization (many-to-many link with Cases).  
• Custom Fields for dynamic data linked to each Case.  
• Internal Notes for agent-only documentation.  
• Messages for real-time client-agent communication.  
• Attachments uploaded via Supabase Storage and linked to Cases.  
• Feedback capturing client ratings and comments.

### API Endpoints
• Authentication: POST /auth/register, POST /auth/login  
• Users: GET /users/:userId, PUT /users/:userId, GET /agents, GET /admins  
• Teams: POST /teams, GET /teams, PUT /teams/:teamId, DELETE /teams/:teamId, POST /teams/:teamId/assign-user  
• Cases: POST /cases, GET /cases/:caseId, PUT /cases/:caseId, DELETE /cases/:caseId  
• Statuses: POST /statuses, GET /statuses  
• Tags: POST /tags, GET /tags  
• Custom Fields: POST /custom-fields, GET /custom-fields  
• Messages: POST /cases/:caseId/messages, GET /cases/:caseId/messages  
• Internal Notes: POST /cases/:caseId/notes, GET /cases/:caseId/notes  
• Attachments: POST /cases/:caseId/attachments, GET /cases/:caseId/attachments, DELETE /cases/:caseId/attachments/:attachmentId  
• Feedback: POST /cases/:caseId/feedback, GET /cases/:caseId/feedback  

### Components to Be Used
• Authentication Pages (Login, Registration) with Supabase Auth integration.  
• Dashboard Pages tailored to Clients, Agents, and Admins.  
• Case Pages displaying lists, detail views, messaging, notes, and attachments.  
• Team Management for Admins to create teams and assign agents.  
• Settings & Profile for user info and custom field/status management.  
• Shared Components like a Header with navigation, real-time Notification system, and reusable Form Controls for dynamic fields.  
• Middleware for RBAC, case ownership checks, input validation, and error handling.  
• Real-time subscriptions for case updates, messages, and notifications via Supabase.  
• Adherence to strict code modularity, TypeScript best practices, and thorough testing. 