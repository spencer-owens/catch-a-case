# UI Rules

This document provides guidelines for building a desktop-first, responsive, and accessible user interface. These rules incorporate insights from the Technical Requirements, Product Requirements, Tech Stack, and Tech Stack Rules documents.

---

## 1. Desktop-First & Responsive Approach

• Target desktop resolutions first, ensuring layouts and components look polished and optimized on larger screens.  
• When adjusting for smaller devices or tablets, use responsive breakpoints (e.g., lg:, md:, sm:) to reorganize content gracefully.  
• Maintain readability at all screen sizes by ensuring consistent typography scales and spacing across breakpoints.

---

## 2. Component Structure & Interaction

• Organize your Shadcn UI + Tailwind components according to their purpose (e.g., layout, sections, form controls).  
• Keep interactive elements (buttons, links, popovers) obvious and intuitive, providing clear visual cues like hover, focus, and active states.  
• Ensure reusability by abstracting repeating patterns (e.g., modals, form inputs) into shared components.  
• Provide straightforward, minimal flows for core actions, such as case creation, messaging, or team management, to respect the project's minimalist theme.

---

## 3. Accessibility & Inclusive Design

• Follow WCAG guidelines for color contrast, keyboard navigation, and semantic HTML structure.  
• Label all interactive elements (buttons, form fields) with accessible names or aria-labels.  
• Use skip-links or a visible focus state to support keyboard navigation.  
• Incorporate Shadcn UI's built-in accessibility features from Radix primitives (e.g., focus trapping in modals, correct ARIA roles).

---

## 4. Performance & Real-Time Considerations

• Integrate real-time updates (via Supabase Realtime) in key components (cases, messages) without causing excessive re-renders.  
• Provide immediate UI feedback using optimistic updates (React Query) for critical user actions (e.g., form submissions).  
• Degrade gracefully if real-time connections are lost—show the user when data may be out of sync.  
• Handle large data sets or frequent updates by periodically batching or throttling display changes to maintain UI responsiveness.

---

## 5. Error Handling & User Feedback

• Display clear, concise error messages for invalid inputs or server failures (use toast notifications or inline error states).  
• Minimize confusion with well-structured forms and informative placeholders or hints.  
• Maintain consistent inline or toasty feedback for all success and error cases to keep the UI cohesive.

---

## 6. Ties to Backend & Supabase

• Adhere to the Supabase-based routes and data models as defined in the Technical and Product Requirements:  
  – Make sure your UI routes and naming conventions match the server (e.g., referencing "cases" or "teams" consistently).  
  – Handle role-based capabilities (e.g., an "agent-only" button) by checking user roles from Supabase Auth.  
• Keep file attachment UI components in sync with Supabase Storage (e.g., previews, successful upload confirmations).  
• Leverage row-level security rules for protected resources to hide or disable UI elements the user can't access.

---

## 7. Code Organization & Reusability

• Use a clear folder structure (e.g., "components", "pages", "layouts", "hooks") and name components semantically.  
• Store shared functionality (e.g., common form controls, modals) in a dedicated "shared" or "common" folder.  
• Keep logic like data fetching and state manipulation in React Query hooks, leaving presentation to the component layer.

---

## 8. Testing & Quality Assurance

• Validate major UI flows (login, case creation, messaging) with integration tests (React Testing Library) to ensure interactions work correctly.  
• Use Cypress for e2e testing of multi-page workflows (e.g., from user login to case closure).  
• Check for accessibility issues using linting tools or aXe browser extensions.

---

By adhering to these UI Rules, the team will craft a desktop-first, responsive, and accessible interface that aligns with the project's minimalist theme and integrates seamlessly with Supabase services. 