# Tech Stack Rules

This document outlines best practices, limitations, and conventions for the technologies listed in our "Selected Tech Stack" and "Technical Requirements." By following these guidelines, we ensure a consistent, maintainable, and performant case management system.

---

## Table of Contents
1. React + TypeScript + Vite  
2. Shadcn UI + Tailwind CSS  
3. React Query + React Context  
4. Supabase (PostgreSQL, Auth, Realtime, Storage)  
5. Deployment & Hosting  
6. Testing & Quality Assurance  
7. Additional Best Practices (From Technical Requirements)  

---

## 1. React + TypeScript + Vite

### Best Practices
• Keep component logic and rendering separated as much as possible for clarity.  
• Favor functional components with hooks to keep code concise and maintainable.  
• Leverage Vite's fast dev server and HMR for efficient iteration.  
• Use TypeScript to ensure type safety and reduce runtime errors.  

### Limitations
• Vite does not provide built-in server-side rendering or file-based routing (unlike Next.js); add packages only if necessary.  
• Large TypeScript projects can increase build times; keep an eye on build performance.  

### Conventions
• Place components in a structured folder hierarchy (e.g., "components", "pages", etc.).  
• Use PascalCase for component names and camelCase for variables/functions.  
• Document props and return types with TypeScript interfaces whenever possible.  

---

## 2. Shadcn UI + Tailwind CSS

### Best Practices
• Use Tailwind utility classes for layouts, spacing, and typography, wrapping them in Shadcn UI components for consistency.  
• Keep layout elements (e.g., containers, grids) consistent across pages for a unified UX.  
• Extend Tailwind's configuration (e.g., theme colors) to align with your design system.  

### Limitations
• Overusing inline utility classes can become unwieldy; create custom classes or components for repeated patterns.  
• Shadcn UI may require occasional updates if breaking changes are introduced.  

### Conventions
• Rely on a mobile-first approach (sm:, md:, lg:) to ensure responsive design.  
• Organize Shadcn UI components in a common library folder if extending or customizing them.  
• Maintain a style guide or reference doc for consistent usage of Tailwind and Shadcn UI classes.  

---

## 3. React Query + React Context

### Best Practices
• Use React Query for server-state management (caching, refetching, and background updates).  
• Leverage React Context sparingly for global UI state (e.g., user sessions, theme settings) to avoid prop drilling.  
• Implement optimistic updates where user feedback is time-sensitive (e.g., toggling a case status).  

### Limitations
• Overusing React Context for every piece of data can lead to unnecessary re-renders; use local component state when feasible.  
• React Query is primarily for server state, so store ephemeral or UI-only data separately (e.g., in local component state).  

### Conventions
• Keep React Query queries logically grouped (e.g., "useCasesQuery", "useMessagesQuery").  
• Name context providers clearly (e.g., "AuthContext", "ThemeContext").  
• Reference the same query keys for consistent data caching across components.  

---

## 4. Supabase (PostgreSQL, Auth, Realtime, Storage)

### PostgreSQL & Schema
• Follow consistent naming conventions (snake_case) for tables and columns, as stated in the Technical Requirements.  
• Index frequently queried fields (e.g., user_id, status) to optimize performance.  
• Enforce foreign key relationships (e.g., assigned_agent_id references Users table).  

### Auth & Row-Level Security
• Rely on Supabase Auth for user registration, login, and role-based controls.  
• Use RLS policies to restrict access to rows based on user role or ownership (client, agent, admin).  
• Always verify JWT tokens from the frontend to protect privileged routes.  

### Realtime
• Subscriptions should be specific to relevant tables or channels to prevent overfetching.  
• Implement partial data updates instead of full reloads to minimize latency and bandwidth usage.  
• Handle edge cases where real-time events might race with user interactions (e.g., confirmation modals).  

### Storage
• Use Supabase Storage for file attachments, restricting read/write access based on user roles.  
• Store file metadata (e.g., file size, MIME type) in the database for quick lookups and consistent referencing.  
• Clean up orphaned storage files when a case or attachment record is deleted.  

---

## 5. Deployment & Hosting

### Recommended Approach
• Host the database and serverless functions on Supabase.  
• Deploy the React app on Vercel or Netlify for fast builds, SSL, and CDN distribution.  

### Limitations
• Each platform has environment variable constraints; ensure proper secrets management.  
• Large traffic spikes may incur higher costs or performance overhead on free tiers.  

### Conventions
• Separate dev/staging/production environments; use environment variables for configurations (API keys, database URLs).  
• Set up automatic deployments with build artifacts and logs (e.g., GitHub Actions or Netlify/Vercel build hooks).  

---

## 6. Testing & Quality Assurance

### Best Practices
• Use Jest for unit tests on logic and utilities.  
• Implement React Testing Library (RTL) for component and integration-level tests.  
• Cypress for end-to-end flows (e.g., from login to creating or updating a case).  

### Limitations
• Cypress can be slower for large test suites; break them down into test specs for better performance.  
• Mocking Supabase's Realtime can require additional libraries or custom test setups.  

### Conventions
• Organize tests by feature or component in a __tests__ folder near the source code.  
• Maintain a coverage threshold and generate reports to ensure code remains well-tested.  
• Write descriptive test names describing the expected behavior (e.g., "logs the user in with valid credentials").  

---

## 7. Additional Best Practices (From Technical Requirements)

• Maintain a modular, reusable code structure (e.g., shared hooks, utility functions, and UI components).  
• Keep front-end state logically grouped to prevent inconsistencies or data collisions.  
• Adhere to naming conventions for clarity (matching "Users," "Cases," etc. in both the front end and database).  
• Always handle errors gracefully, providing meaningful feedback to the user (e.g., toast notifications, modals).  
• Stay consistent with pinned versions of critical libraries to avoid unexpected breaking changes.

---

By following these Tech Stack Rules, our team ensures a clean, efficient, and robust implementation aligned with our "Selected Tech Stack" and "Technical Requirements." 