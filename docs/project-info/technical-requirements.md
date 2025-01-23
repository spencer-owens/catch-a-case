# Technical Requirements

Below is a comprehensive outline of the technical requirements for our modern case management system. These requirements incorporate insights from the Project Overview, User Stories, Project Map, User Flow, and Known Issues documentation.

---

## Data Models with Fields and Relationships

This section describes the core database entities, including the fields each model requires and how these models are related. We will use Supabase/PostgreSQL as the primary data layer, following recommended best practices for naming and structuring tables.

### 1. Users
• Stores all platform users (Clients, Agents, and Admins).  
• Key fields:  
  – id (UUID, primary key)  
  – email (string, unique)  
  – password_hash (string, stored securely or managed via Supabase Auth)  
  – role (string, e.g., "client", "agent", "admin")  
  – full_name (string)  
  – created_at (timestamp)  
  – updated_at (timestamp)  
• Relationships:  
  – A user can have many Cases (if role = "client").  
  – A user (agent) may be assigned to multiple Cases.  
  – An admin user manages Teams, based on how teams are structured (see below).

### 2. Teams
• Used by Admins to manage Agents or group them by skill.  
• Key fields:  
  – id (UUID, primary key)  
  – team_name (string, unique)  
  – created_at (timestamp)  
  – updated_at (timestamp)  
• Relationships:  
  – A Team has many Users (agents).  
  – A user can belong to one or more Teams as needed.  
  – A join table (team_members) includes fields: team_id, user_id.

### 3. Cases
• Central table for storing each legal matter.  
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
  – Belongs to exactly one client (client_id).  
  – May be assigned to one agent (assigned_agent_id).  
  – Has many Internal Notes, Tags, Attachments, and Messages.

### 4. Statuses
• Captures the complete "Case Status Flow" (Intake, Pre-litigation, Litigation, etc.).  
• Admins can modify these statuses dynamically.

### 5. Tags
• Provides flexible labeling of Cases.  
• Key fields:  
  – id (UUID, primary key)  
  – tag_name (string, unique)  
• Relationship:  
  – Many-to-many with Cases via a join table: cases_tags (case_id, tag_id).

### 6. Custom Fields
• Used to capture extra data dynamically (e.g., specialized metadata for a particular practice area).  
• Implemented as a distinct table or a JSONB column in the Cases table:  
  – If a separate table, store: id, case_id, field_name, field_value.  
  – If JSON, store structured data in a JSONB column within Cases or a child table "cases_custom_fields."

### 7. Internal Notes
• Agent-only notes on a Case.  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – agent_id (references Users table)  
  – note_content (text)  
  – created_at (timestamp)  
• Relationship:  
  – Belongs to one Case, belongs to one Agent.

### 8. Messages / Conversation History
• Logs all client-agent communications pertaining to a particular Case.  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – sender_id (references Users table)  
  – message_content (text)  
  – attachments (array of references to the Attachments table)  
  – created_at (timestamp)  
• Relationship:  
  – Many-to-one with Cases.  
  – Many Messages can belong to one Case.  
  – Each Message connects to a sender (Client or Agent).

### 9. Attachments
• Stores file references (documents, images, evidence).  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – uploader_id (references Users table)  
  – file_url (string)  
  – created_at (timestamp)  
• Relationship:  
  – Belongs to one Case.  
  – Belongs to one User (the uploader).  
  – Attachments can be referenced in Messages if needed.

### 10. Feedback
• Used by Clients to provide post-resolution feedback.  
• Key fields:  
  – id (UUID, primary key)  
  – case_id (references Cases table)  
  – client_id (references Users table)  
  – rating (integer or numeric)  
  – comments (text)  
  – created_at (timestamp)  
• Relationship:  
  – Each Feedback entry belongs to one Case.  
  – Linked to the Client who created it.

---

## Required Routing / Structure

Below is a high-level summary of routes necessary to fulfill application needs. In addition to the endpoints below, we will use role-based checks for Agents and Admins.

• Auth Routes  
  – POST /auth/register  
  – POST /auth/login  
  – Usage of Supabase Auth policies for role-based access

• User Routes  
  – GET /users/:userId  
  – PUT /users/:userId  
  – (Admin only) GET /agents, GET /admins, etc.

• Case Routes  
  – POST /cases (client creates new case)  
  – GET /cases/:caseId  
  – PUT /cases/:caseId  
  – DELETE /cases/:caseId (admin or agent with permission)  

• Custom Fields / Tags / Statuses  
  – CRUD endpoints to manage these as needed by admins

• Messaging Routes  
  – POST /cases/:caseId/messages  
  – GET /cases/:caseId/messages  

• Internal Notes Routes  
  – POST /cases/:caseId/notes (agent only)  
  – GET /cases/:caseId/notes (agent only)

• Attachments Routes  
  – POST /cases/:caseId/attachments  
  – GET /cases/:caseId/attachments  
  – DELETE /cases/:caseId/attachments/:attachmentId  

• Feedback Routes  
  – POST /cases/:caseId/feedback (client after resolution)  
  – GET /cases/:caseId/feedback (admin or agent)

• Admin / Team Management Routes  
  – POST /teams  
  – GET /teams  
  – PUT /teams/:teamId  
  – DELETE /teams/:teamId  
  – POST /teams/:teamId/assign-user (manage membership)

---

## Core Functionality Requirements

1. **Authentication & Authorization**  
   - Secure login for Clients, Agents, and Admins using Supabase Auth.  
   - Role-based access to ensure correct permissions (e.g., only Admin can manage Teams, only Agents can create Internal Notes).

2. **Case Creation & Management**  
   - Clients can create, view, and track Cases.  
   - Agents and Admins can update Case status, reassign Cases, or close Cases.

3. **Communication & Collaboration**  
   - Real-time messaging between Clients and Agents.  
   - Internal Notes for private Agent/Attorney discussions on each Case.

4. **Queue Management & Assignment**  
   - Agents see a prioritized list of assigned Cases with filtering options.  
   - Admins can configure auto-routing rules and load balancing.

5. **Flexible Data Model**  
   - Custom Fields to store unique practice-area data.  
   - Tags to categorize Cases for quick searching and workflow automation.

6. **Notifications & Real-Time Updates**  
   - Supabase Realtime to push notifications (Case status changes, new messages).  
   - Minimizes page reloads and improves user experience.

7. **Feedback & Reporting**  
   - Clients can provide feedback or ratings on their case experience.  
   - Admins can generate reports on performance, agent productivity, and more.

8. **File Attachments**  
   - Secure, scalable storage for case documents and evidence.  
   - Integrated with Supabase Storage for efficient file handling.

9. **Performance & Scalability**  
   - Use caching and query optimization for frequent data operations.  
   - Well-designed indexes and foreign keys to handle large volumes of Cases.

10. **API & Integrations**  
   - Synchronous endpoints for immediate user actions.  
   - Webhooks to notify external systems of events (case creation, messages posted).

---

## Other Considerations

Below are important considerations gathered from the Known Issues document and best practices for this system:

1. **Supabase Auth & Roles**  
   - Use a single, top-layer Auth provider that is simple to implement and straightforward to maintain with role-based checks for route protection.  
   - Apply Supabase policy rules to enforce row-level security where needed.

2. **Real-Time Requirements**  
   - Use Supabase real-time subscriptions to update Agents and Clients about case updates, new messages, etc.  
   - Avoid full data refetch for every minor update and enforce partial or incremental updates to reduce latency.

3. **Storage & File Handling**  
   - Store attachments in Supabase Storage and keep references in the database.  
   - Handle file versioning or replacement as necessary.

4. **State Management**  
   - Rely on React (React Context) real-time data sync, local caching, or global state management to provide a smooth user experience.  
   - Structure front-end state carefully to avoid inconsistencies.

5. **Database Schema & Naming Conventions**  
   - Maintain consistent naming conventions for all tables and foreign keys.  
   - Use well-structured primary/foreign keys to keep queries efficient and clear.

6. **Modularity & Reusability**  
   - Keep code modular, reusing UI components (e.g., form controls) and back-end utilities.  
   - Follow TypeScript, Node.js, and React best practices for maintainability.

---

## Conclusion

These technical requirements—spanning database design, routing structure, and application logic—form the foundation of a robust, scalable case management system. By adhering to the outlined data models, routes, core functionality, and key considerations, the project team can ensure this solution provides high security, performance, and reliability for all users. 