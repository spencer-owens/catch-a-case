# Routing Requirements

This document outlines all necessary API routes and endpoints required for the application. All routes implement role-based access control for Agents and Admins.

## Authentication Routes
• POST `/auth/register`  
  – Register new users  
  – Handled by Supabase Auth  

• POST `/auth/login`  
  – Authenticate users  
  – Returns JWT token  

## User Management Routes
• GET `/users/:userId`  
  – Retrieve user profile  
  – Access: Own profile or Admin  

• PUT `/users/:userId`  
  – Update user information  
  – Access: Own profile or Admin  

• GET `/agents`  
  – List all agents  
  – Access: Admin only  

• GET `/admins`  
  – List all admins  
  – Access: Admin only  

## Case Management Routes
• POST `/cases`  
  – Create new case  
  – Access: Client  

• GET `/cases/:caseId`  
  – Retrieve case details  
  – Access: Case owner, assigned agent, or admin  

• PUT `/cases/:caseId`  
  – Update case information  
  – Access: Assigned agent or admin  

• DELETE `/cases/:caseId`  
  – Remove case  
  – Access: Admin or agent with permission  

## Custom Fields Routes
• POST `/custom-fields`  
  – Create new custom field definition  
  – Access: Admin only  

• GET `/custom-fields`  
  – List all custom fields  
  – Access: All authenticated users  

## Tags Routes
• POST `/tags`  
  – Create new tag  
  – Access: Admin only  

• GET `/tags`  
  – List all tags  
  – Access: All authenticated users  

## Status Routes
• POST `/statuses`  
  – Create new status  
  – Access: Admin only  

• GET `/statuses`  
  – List all statuses  
  – Access: All authenticated users  

## Messaging Routes
• POST `/cases/:caseId/messages`  
  – Send new message  
  – Access: Case owner or assigned agent  

• GET `/cases/:caseId/messages`  
  – Retrieve message history  
  – Access: Case owner or assigned agent  

## Internal Notes Routes
• POST `/cases/:caseId/notes`  
  – Create internal note  
  – Access: Agents only  

• GET `/cases/:caseId/notes`  
  – Retrieve internal notes  
  – Access: Agents only  

## Attachments Routes
• POST `/cases/:caseId/attachments`  
  – Upload new attachment  
  – Access: Case owner or assigned agent  

• GET `/cases/:caseId/attachments`  
  – List case attachments  
  – Access: Case owner or assigned agent  

• DELETE `/cases/:caseId/attachments/:attachmentId`  
  – Remove attachment  
  – Access: Case owner, assigned agent, or admin  

## Feedback Routes
• POST `/cases/:caseId/feedback`  
  – Submit feedback  
  – Access: Client after case resolution  

• GET `/cases/:caseId/feedback`  
  – Retrieve feedback  
  – Access: Admin or assigned agent  

## Team Management Routes
• POST `/teams`  
  – Create new team  
  – Access: Admin only  

• GET `/teams`  
  – List all teams  
  – Access: Admin only  

• PUT `/teams/:teamId`  
  – Update team information  
  – Access: Admin only  

• DELETE `/teams/:teamId`  
  – Remove team  
  – Access: Admin only  

• POST `/teams/:teamId/assign-user`  
  – Manage team membership  
  – Access: Admin only 