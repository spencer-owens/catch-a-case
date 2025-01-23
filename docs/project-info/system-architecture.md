# System Architecture

Below is an overview of our app's architecture, detailing the key API routes for each data model, the planned component/page structure, and the essential middleware/auth flows.

---

## 1. API Routes with HTTP Methods and Auth Requirements

1. Users  
   1. POST /auth/register → Registers new users (Public).  
   2. POST /auth/login → Authenticates users and returns JWT (Public).  
   3. GET /users/:userId → Retrieves a user profile (Owner or Admin).  
   4. PUT /users/:userId → Updates user info (Owner or Admin).  
   5. GET /agents → Lists all agents (Admin only).  
   6. GET /admins → Lists all admins (Admin only).

2. Teams  
   1. POST /teams → Creates a new team (Admin only).  
   2. GET /teams → Retrieves all teams (Admin only).  
   3. PUT /teams/:teamId → Updates team info (Admin only).  
   4. DELETE /teams/:teamId → Removes a team (Admin only).  
   5. POST /teams/:teamId/assign-user → Manages team membership (Admin only).

3. Cases  
   1. POST /cases → Creates a new case (Client).  
   2. GET /cases/:caseId → Retrieves case details (Owner, Assigned Agent, or Admin).  
   3. PUT /cases/:caseId → Updates case info (Assigned Agent or Admin).  
   4. DELETE /cases/:caseId → Removes a case (Assigned Agent or Admin with permission).

4. Statuses  
   1. POST /statuses → Creates a status (Admin only).  
   2. GET /statuses → Lists statuses (All authenticated users).

5. Tags  
   1. POST /tags → Creates a tag (Admin only).  
   2. GET /tags → Lists tags (All authenticated users).

6. Custom Fields  
   1. POST /custom-fields → Creates a new custom field (Admin only).  
   2. GET /custom-fields → Lists all custom fields (All authenticated users).

7. Messages  
   1. POST /cases/:caseId/messages → Sends a new message (Case Owner or Assigned Agent).  
   2. GET /cases/:caseId/messages → Retrieves message history (Case Owner or Assigned Agent).

8. Internal Notes  
   1. POST /cases/:caseId/notes → Creates an internal note (Agents only).  
   2. GET /cases/:caseId/notes → Retrieves internal notes (Agents only).

9. Attachments  
   1. POST /cases/:caseId/attachments → Uploads an attachment (Case Owner or Assigned Agent).  
   2. GET /cases/:caseId/attachments → Lists attachments (Case Owner or Assigned Agent).  
   3. DELETE /cases/:caseId/attachments/:attachmentId → Removes an attachment (Case Owner, Assigned Agent, or Admin).

10. Feedback  
   1. POST /cases/:caseId/feedback → Submits feedback (Client after case resolution).  
   2. GET /cases/:caseId/feedback → Retrieves feedback (Assigned Agent or Admin).

---

## 2. Page Structure and Components Needed

1. Authentication Pages  
   1. Login Page → Provides login form and integrates with Supabase Auth.  
   2. Registration Page → Allows new users to register.

2. Dashboard Pages  
   1. Client Dashboard → Displays user's cases, notifications, and quick actions.  
   2. Agent Dashboard → Shows assigned cases, queue management tools, and filters.  
   3. Admin Dashboard → Provides team management, system settings, and reporting.

3. Case Pages  
   1. Case List Page → Shows all cases relevant to the user with search and filter.  
   2. Case Detail Page → Displays case status, messages, internal notes, attachments, and feedback (depending on role).

4. Team Management  
   1. Team List Page → Displays existing teams (Admin only).  
   2. Team Detail Page → Allows adding/removing users and editing team info.

5. Settings & Profile  
   1. Profile Page → Shows user details, update password option, and personal settings.  
   2. Custom Fields & Status Pages → Admin pages to manage dynamic fields and statuses.

6. Shared Components  
   1. Header & Nav Bar → Contains main navigation links and user info.  
   2. Notification Component → Shows real-time alerts for new messages or status changes.  
   3. Form Controls → Standardized inputs for tags, custom fields, and attachments.

---

## 3. Key Middleware Functions

1. Auth Validation Middleware  
   1. Parses JWT tokens from requests.  
   2. Validates user identity using Supabase Auth.  
   3. Attaches user info (role, userId) to request context.

2. Role-Based Access Control (RBAC)  
   1. Checks user role against route requirements.  
   2. Grants or denies access based on role (Client, Agent, Admin).  
   3. Ensures only authorized operations occur.

3. Case Ownership/Assignment Check  
   1. Confirms that a user is either the client (owner) or assigned agent.  
   2. Prevents unauthorized case data access.  
   3. Logs unauthorized attempts.

4. Input Validation & Sanitization  
   1. Validates request payloads for required fields.  
   2. Sanitizes inputs to prevent injection attacks.  
   3. Returns meaningful error responses when validation fails.

5. Error Handling  
   1. Catches exceptions within routes and middleware.  
   2. Sends standardized error structures to clients.  
   3. Logs errors appropriately for debugging.

6. Realtime Event Handling  
   1. Subscribes to Supabase database changes for case updates or new messages.  
   2. Triggers push notifications or in-app alerts.  
   3. Manages partial data refresh to optimize performance. 