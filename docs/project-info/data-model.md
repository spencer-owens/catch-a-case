# Data Models

This document outlines the core database entities, including fields and relationships. We use Supabase/PostgreSQL as the primary data layer.

## 1. Users
• Stores all platform users (Clients, Agents, and Admins)  
• Key fields:  
  – id (UUID, primary key)  
  – email (string, unique)  
  – password_hash (string, stored securely or managed via Supabase Auth)  
  – role (string, e.g., "client", "agent", "admin")  
  – full_name (string)  
  – created_at (timestamp)  
  – updated_at (timestamp)  
• Relationships:  
  – A user can have many Cases (if role = "client")  
  – A user (agent) may be assigned to multiple Cases  
  – An admin user manages Teams

## 2. Teams
• Used by Admins to manage Agents or group them by skill  
• Key fields:  
  – id (UUID, primary key)  
  – team_name (string, unique)  
  – created_at (timestamp)  
  – updated_at (timestamp)  
• Relationships:  
  – A Team has many Users (agents)  
  – A user can belong to one or more Teams  
  – A join table (team_members) includes fields: team_id, user_id

## 3. Cases
• Central table for storing each legal matter  
• Key fields:  
  – id (UUID, primary key)  
  – client_id (references Users table, required if user is a Client)  
  – assigned_agent_id (references Users table)  
  – status (string or foreign key to a Statuses table)  
  – title (string)  
  – description (text)  
  – created_at (timestamp)  
  – updated_at (timestamp)  
• Relationships:  
  – Belongs to exactly one client (client_id)  
  – May be assigned to one agent (assigned_agent_id)  
  – Has many Internal Notes, Tags, Attachments, and Messages

## 4. Statuses
• Captures the complete "Case Status Flow" (Intake, Pre-litigation, Litigation, etc.)  
• Admins can modify these statuses dynamically

## 5. Tags
• Provides flexible labeling of Cases  
• Key fields:  
  – id (UUID, primary key)  
  – tag_name (string, unique)  
• Relationship:  
  – Many-to-many with Cases via a join table: cases_tags (case_id, tag_id)

## 6. Custom Fields
• Used to capture extra data dynamically  
• Implementation options:  
  – Separate table: id, case_id, field_name, field_value  
  – JSONB column in Cases table or cases_custom_fields table

## 7. Internal Notes
• Agent-only notes on a Case  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – agent_id (references Users table)  
  – note_content (text)  
  – created_at (timestamp)  
• Relationship:  
  – Belongs to one Case, belongs to one Agent

## 8. Messages / Conversation History
• Logs all client-agent communications  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – sender_id (references Users table)  
  – message_content (text)  
  – attachments (array of references to the Attachments table)  
  – created_at (timestamp)  
• Relationship:  
  – Many-to-one with Cases  
  – Many Messages can belong to one Case  
  – Each Message connects to a sender

## 9. Attachments
• Stores file references  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – uploader_id (references Users table)  
  – file_url (string)  
  – created_at (timestamp)  
• Relationship:  
  – Belongs to one Case  
  – Belongs to one User (uploader)  
  – Can be referenced in Messages

## 10. Feedback
• Used by Clients for post-resolution feedback  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – client_id (references Users table)  
  – rating (integer or numeric)  
  – comments (text)  
  – created_at (timestamp)  
• Relationship:  
  – Each Feedback entry belongs to one Case  
  – Linked to the Client who created it 