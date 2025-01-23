# Project Map

This document describes the high-level website map for our modern case management system. It is organized by user type, linking back to relevant features mentioned in the project overview and user stories.

---

## 1. Unauthenticated Visitors
1. **Home / Landing Page**  
   - Overview of platform services and benefits  
   - Quick links (e.g., "Contact Us," "Sign Up," "Login")  
   - References:  
     - [Project Overview - Customer Features → Self-Service Tools]  
     - [User Stories - Unauthenticated Visitors → Evaluate Services Before Signing Up]  

2. **Public FAQ and Help Articles**  
   - Searchable knowledge base for general case/law FAQs  
   - Visible without registration  
   - References:  
     - [Project Overview - Customer Features → Knowledge Base]  
     - [User Stories - Unauthenticated Visitors → Browse FAQs and Help Articles]  

---

## 2. Clients (Portal)
1. **Client Portal Dashboard**  
   - Shows case overview and important milestones  
   - Quick links to create a new case, view active cases, or submit documents  
   - References:  
     - [Project Overview - Customer Features → Case Tracking]  
     - [User Stories - Clients → Create and Track Cases]  

2. **My Cases**  
   - Lists user's current/past cases with brief status overview  
   - Links to detailed Case Details page  
   - References:  
     - [Project Overview - Case Data Model & Dynamic Status Tracking]  
     - [User Stories - Clients → Track Cases]  

3. **Case Details**  
   - Full conversation history, internal notes (agent-provided summary), relevant attachments  
   - Ability to upload new documentation or fill out forms  
   - References:  
     - [Project Overview - Customer Features → History of Interactions, Attachments]  
     - [User Stories - Clients → Submit Documentation and Evidence]  

4. **Notifications & Alerts**  
   - Displays real-time or recent notifications about status changes, new messages, or upcoming tasks  
   - References:  
     - [Project Overview - Real-Time Updates / Proactive Notifications]  
     - [User Stories - Clients → Receive Notifications on Case Milestones]  

5. **Feedback / Ratings**  
   - Prompted once a case is resolved or closed; rating and feedback submission  
   - References:  
     - [Project Overview - Customer Features → Ratings System]  
     - [User Stories - Clients → Provide Feedback on Resolution Experience]  

---

## 3. Agents (Paralegals)
1. **Agent Dashboard**  
   - Overview of assigned and active cases; quick stats (open cases, pending tasks, etc.)  
   - References:  
     - [Project Overview - Agent Interface → Queue Management]  
     - [User Stories - Agents → Manage and Prioritize Case Queues]  

2. **Case Queue / Worklist**  
   - Comprehensive list of open cases assigned to this agent (or team)  
   - Filters (status, priority, tags)  
   - Bulk update functionality  
   - References:  
     - [Project Overview - Agent Interface → Bulk Operations, Quick Filters]  
     - [User Stories - Agents → Bulk Operations]  

3. **Case Handling / Detail View**  
   - Shows full conversation history, ability to add internal notes, attach files, send macros/quick responses  
   - Links to relevant documents or forms needed for each case stage  
   - References:  
     - [Project Overview - Agent Interface → Collaboration Tools]  
     - [User Stories - Agents → Collaborate with Internal Notes, Use Macros and Quick Responses]  

4. **Performance / Statistics**  
   - Personal and team-level analytics (mean resolution time, assigned vs. closed cases, etc.)  
   - References:  
     - [Project Overview - Agent Interface → Metrics Tracking, Personal Stats]  
     - [User Stories - Agents → Monitor Personal and Team Performance]  

---

## 4. Admins (Attorneys and Other Staff)
1. **Admin Dashboard**  
   - Global overview of all open cases, agent workloads, system alerts  
   - Key performance metrics (load balancing, team efficiency)  
   - References:  
     - [Project Overview - Administrative Control → Team Management, Routing Intelligence]  
     - [User Stories - Admins → Monitor Overall Queue and Load Balancing]  

2. **Team Management**  
   - Create teams, assign roles, configure coverage schedules  
   - References:  
     - [Project Overview - Administrative Control → Team Management]  
     - [User Stories - Admins → Manage Teams and Agent Assignments]  

3. **Routing Rules**  
   - Manage skill-based routing and automated case distribution  
   - References:  
     - [Project Overview - Administrative Control → Rule-Based Assignment, Skills-Based Routing]  
     - [User Stories - Admins → Configure Routing Rules]  

4. **Customization & Schema Updates**  
   - Manage custom fields, tags, categories, or system definitions  
   - Adjust or update the case pipeline to match new practice areas  
   - References:  
     - [Project Overview - Data Management → Schema Flexibility]  
     - [User Stories - Admins → Oversee System Customization and Schema Updates]  

5. **Reporting & Audits**  
   - Generate reports on agent performance, case outcomes, or other metrics  
   - Export data for compliance or internal record-keeping  
   - References:  
     - [Project Overview - Administrative Control → Team Performance, Data Management → Audit Logging]  
     - [User Stories - Admins → Perform Audits and Generate Reports]  

---

## Relationship to Other Features

- **Security & Auth**  
  - Login and role-based access control for Clients, Agents, and Admins  
  - References:  
    - [Project Overview - Customer Features → Secure Login]  
    - [Project Overview - API Features → Granular Permissions]

- **API Integrations**  
  - Potential external integrations for advanced tasks and data exchange  
  - Webhooks to notify external tools about case events  
  - References:  
    - [Project Overview - API Features → Integration, Webhooks]

---

## Conclusion
This project map provides a high-level overview of the site structure, with each user type accessing different pages and functionalities. It ties together the key features identified in the project overview and user stories, offering a reliable reference for future planning and implementation. 