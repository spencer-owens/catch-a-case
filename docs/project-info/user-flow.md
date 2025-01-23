# User Flow

This document outlines how different user types will navigate through our modern case management system, detailing the journey from first contact to core interactions. It draws from the Project Overview, User Stories, and Project Map to illustrate how the different features connect and support each step of the user's journey.

---

## 1. Unauthenticated Visitors

1. **Landing on the Home Page**  
   - Users arrive at the platform and see an overview of services and benefits.  
   - Primary calls to action are "Sign Up" or "Login."

2. **Exploring FAQs and Help Articles**  
   - Visitors can browse or search public help articles to learn about the legal process and how the system works.  
   - If satisfied, they may choose to sign up or log in to access more features.

3. **Evaluating Services**  
   - By reading background, feature highlights, or success stories, visitors decide whether the system meets their needs.  
   - Once convinced, they proceed to registration or consultation options.

4. **Transition to Client Portal**  
   - Upon registration/login, they become Clients and are redirected to the Client Dashboard.  
   - References:  
     - Project Map: [Unauthenticated Visitors → Home / Landing Page, Public FAQs]  
     - User Stories: [Unauthenticated Visitors → Evaluate Services Before Signing Up]  

---

## 2. Clients

### 2.1 Onboarding and Portal Entry
1. **Registration & Secure Login**  
   - Clients create an account, providing relevant personal details.  
   - Post-login, they gain access to the Client Portal Dashboard.

2. **Client Portal Dashboard**  
   - Displays overall case status, important milestones, and quick links ("Create New Case," "My Cases," "Notifications").  
   - References:  
     - Project Map: [Client Portal Dashboard → Show overview, Quick links]  

### 2.2 Managing Cases
1. **Create a New Case**  
   - Users submit essential case details—personal info, incident description, etc.  
   - The newly created case appears in "My Cases" with an initial status.  
   - References:  
     - User Stories: [Clients → Create and Track Cases]  

2. **My Cases View**  
   - Lists all open and closed cases with summaries and statuses.  
   - Users can click a case to see details or upload documents.  
   - References:  
     - Project Map: [My Cases → Lists user's cases]  

3. **Case Details & Documentation**  
   - Includes conversation history, attorney/paralegal notes, and file attachments.  
   - Clients can upload new evidence (e.g., medical records), tagged for easy reference.  
   - References:  
     - User Stories: [Clients → Submit Documentation and Evidence]  

4. **Notifications and Alerts**  
   - Clients receive real-time updates about status changes, upcoming deadlines, or messages from paralegals.  
   - References:  
     - Project Overview: [Proactive Notifications]  
     - User Stories: [Clients → Receive Notifications on Case Milestones]  

### 2.3 Feedback and Resolution
1. **Case Closure and Feedback**  
   - Once a case is resolved, the user can rate the experience and provide feedback.  
   - This helps improve future workflows and user satisfaction.  
   - References:  
     - User Stories: [Clients → Provide Feedback on Resolution Experience]  

2. **Post-Case Maintenance**  
   - Clients may keep the case record for reference, or start a new case if needed.  
   - Retains access to all prior data and documentation.  

---

## 3. Agents (Paralegals)

### 3.1 Logging In and Accessing the Agent Dashboard
1. **Secure Login**  
   - Agents sign in, gaining access to the Agent Dashboard.  
   - References:  
     - Project Overview: [User Roles → Agents]  

2. **Agent Dashboard Overview**  
   - Displays overall workload and quick stats (open cases, pending tasks).  
   - Direct links to case queues and performance metrics.  
   - References:  
     - Project Map: [Agent Dashboard → Overview of assigned and active cases]  

### 3.2 Case Workflows
1. **Navigating the Case Queue**  
   - Provides filters (by status, priority, tags) for efficient triage.  
   - Agents can perform bulk actions (e.g., changing statuses, leaving internal notes).  
   - References:  
     - User Stories: [Agents → Manage and Prioritize Case Queues, Bulk Operations]  

2. **Case Detail View**  
   - Shows full conversation history, relevant documentation, and the option to add internal notes.  
   - Agents can send quick responses, use macros, or escalate for attorney review.  
   - References:  
     - Project Map: [Agent → Case Handling / Detail View]  
     - User Stories: [Agents → Collaborate with Internal Notes, Use Macros]  

3. **Performance Tracking**  
   - Agents monitor key metrics—average resolution time, number of open cases, or client satisfaction.  
   - References:  
     - User Stories: [Agents → Monitor Personal and Team Performance]  

---

## 4. Admins (Attorneys and Other Staff)

### 4.1 Administrative Dashboard
1. **Global View**  
   - Admins see the entire system's workload, agent assignments, and alerts.  
   - References:  
     - Project Map: [Admins → Admin Dashboard]  

2. **Team Management and Assignments**  
   - Admins create or manage teams, configure agent permissions, and auto-route incoming cases.  
   - References:  
     - User Stories: [Admins → Manage Teams and Agent Assignments, Configure Routing Rules]  

3. **Load Balancing and Monitoring**  
   - Admins ensure agents aren't overloaded and make adjustments in real-time.  
   - References:  
     - Project Overview: [Administrative Control → Load Balancing]  
     - User Stories: [Admins → Monitor Overall Queue and Load Balancing]  

### 4.2 Customization and Reporting
1. **Customization & Schema Updates**  
   - Admins can add or modify custom fields, tags, and categories.  
   - Keeps the system adaptable to evolving legal needs.  
   - References:  
     - Project Map: [Admins → Customization & Schema Updates]  
     - User Stories: [Admins → Oversee System Customization and Schema Updates]  

2. **Audits & Reporting**  
   - Admins generate reports (case outcomes, agent performance, financials).  
   - Tools for compliance checks or improvements based on data insights.  
   - References:  
     - User Stories: [Admins → Perform Audits and Generate Reports]  

---

## 5. Cross-Functional Journeys

### 5.1 Security and Authentication
- All roles must pass through secure login with role-based permissions.  
- The system ensures only authorized actions are taken based on user type.  
- References:  
  - Project Overview: [API Features → Granular Permissions]  
  - Project Map: [Security & Auth]  

### 5.2 Notifications and Real-Time Updates
- Clients, Agents, and Admins rely on live signals to track changing case statuses, new messages, and assigned tasks.  
- Agents or Admins can respond instantly to meet urgent needs.  

### 5.3 API Integrations
- The platform may push or pull case data from external applications, or trigger webhooks on significant events.  
- Supports advanced features like AI-driven suggestions or chatbots.  

---

## Conclusion

The user flows above demonstrate how each role navigates the system's features and how these features interconnect. By mapping these journeys—beginning with unauthenticated visitors evaluating services, continuing through clients managing and tracking their cases, and culminating in agents/admins overseeing case progress—this document provides a holistic view of the platform's functionality.

These flows will guide decisions about UI design, data architecture, and iterative development strategies. They ensure every user interaction aligns with the core requirements outlined in the Project Overview, User Stories, and Project Map. 