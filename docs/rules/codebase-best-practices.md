# Codebase Best Practices

This document provides essential guidelines, architectural patterns, and a recommended file structure for building a modular, scalable, and AI-first case management application. It incorporates insights from:  
• Product Requirements  
• Data Models  
• Routing Requirements  
• Core Functionality  
• Important Considerations  
• Tech Stack  
• Tech Stack Rules  
• UI Rules  
• Theme Rules  

By following these practices, we ensure our code remains clear, maintainable, and optimized for AI tooling like Cursor.

---

## 1. Project Philosophy and AI-First Approach

1.1 Modularity  
• Break down features into independent, reusable modules.  
• Keep functions focused, each doing a single job well.  

1.2 Scalability  
• Favor folder structures and component organization that can grow without becoming unwieldy.  
• Keep files capped at ~250 lines to maintain readability for AI tools and human developers alike.

1.3 Clarity & Readability  
• At the top of each file, include a brief explanation of its purpose.  
• Document functions with proper docstrings (JSDoc/TSDoc) describing parameters, return types, and usage examples.

1.4 Separation of Concerns  
• Distinguish between business logic (data, domain) and presentation logic (UI).  
• Adhere to the Single Responsibility Principle—avoid placing large amounts of logic in single components or files.

---

## 2. File and Folder Structure

Below is an example file tree that illustrates how to separate concerns across our AI-first application. Adjust as needed for your specific workflows or additional features:

/
├─ .gitignore  
├─ package.json  
├─ README.md  
├─ vite.config.ts  
├─ tsconfig.json  
├─ public/  
│  └─ (Static assets: images, fonts, favicon)  
├─ src/  
│  ├─ app/  
│  │  ├─ pages/  
│  │  │  ├─ LoginPage.tsx          (User login screen)  
│  │  │  ├─ DashboardPage.tsx      (Main dashboard for Agents/Admins)  
│  │  │  ├─ ClientCasesPage.tsx    (Client's cases overview)  
│  │  │  └─ …  
│  │  ├─ components/  
│  │  │  ├─ ui/  
│  │  │  │  ├─ Button.tsx          (Shadcn UI-based button)  
│  │  │  │  ├─ Modal.tsx           (Shared modal component)  
│  │  │  │  └─ …  
│  │  │  ├─ forms/  
│  │  │  │  ├─ CaseForm.tsx        (Form to create/update cases)  
│  │  │  │  └─ …  
│  │  │  └─ layout/  
│  │  │     ├─ MainLayout.tsx      (Global app shell)  
│  │  │     └─ …  
│  │  ├─ hooks/  
│  │  │  ├─ useAuth.ts             (Handles auth context/hooks)  
│  │  │  └─ useCases.ts            (Fetch/cache case data)  
│  │  ├─ state/  
│  │  │  └─ store.ts               (Zustand or React Context store)  
│  │  ├─ services/  
│  │  │  ├─ supabaseClient.ts      (Supabase initialization & config)  
│  │  │  ├─ api.ts                 (Fetch wrappers, API calls)  
│  │  │  └─ aiService.ts           (Optional integration with LangChain or other AI ops)  
│  │  ├─ routes/  
│  │  │  └─ index.ts               (Central route definitions/config)  
│  │  ├─ utils/  
│  │  │  ├─ validation.ts          (Form and data validation helpers)  
│  │  │  └─ formatters.ts          (Formatting utilities for dates, currency, etc.)  
│  │  ├─ styles/  
│  │  │  └─ globals.css            (Tailwind base styles, theme config)  
│  │  └─ index.tsx                 (Application entry, ReactDOM.render)  
│  ├─ tests/                       (Optional: e2e or integration tests)  
│  │  └─ (Test files, e.g., with Cypress or RTL)  
│  └─ assets/                      (Images, icons, or other non-public assets referenced within the app)  
├─ docs/  
│  ├─ project-info/  
│  │  └─ (Project documents such as product requirements, data models, etc.)  
│  └─ rules/  
│     ├─ tech-stack-rules.md  
│     ├─ ui-rules.md  
│     ├─ theme-rules.md  
│     └─ codebase-best-practices.md  (This file)  
└─ node_modules/  
   └─ …  

Notes:  
• "src/app" is the main application folder, containing pages, components, hooks, and services.  
• "services" is where you put all data-fetching and Supabase utility code.  
• "routes" can store route configuration/logic if you set up a custom router.  
• Each major feature (e.g., Cases, Teams) could have its own subfolder under "pages," "components," or "services" to stay organized.

---

## 3. File Naming Conventions

• Use PascalCase for React components (e.g., CaseForm.tsx).  
• Use camelCase for variables, functions, and hooks (e.g., useAuth).  
• Use snake_case or kebab-case for files hosting plain utility logic if desired—but consistency across the team is key.  
• Append .test or .spec to your test files (CaseForm.test.tsx) to distinguish them from production code.

---

## 4. Documentation and Comments

• At the top of each file, provide a short docstring or comment block describing its purpose and usage.  
• Use TSDoc or JSDoc for function signatures:  
  /**
   * handleLogin - Authenticates the user with Supabase.
   * @param email The user's email.
   * @param password The user's password.
   * @returns Promise resolving to a user session or error.
   */  
• Keep comments concise—describe "why" more than "what" if the code is self-explanatory.

---

## 5. Code Organization Guidelines

1. AI Integration Modules  
   • Keep AI or LLM-specific logic in a dedicated service (e.g., aiService.ts) so it's separate from general application logic.  
   • Document interactions with LangChain or embeddings clearly to make advanced features easy to maintain.

2. Data Models & Routing  
   • Reference the "data-model.md" and "routing-requirements.md" to ensure your code aligns with the defined endpoints and PostgreSQL schema.  
   • Use descriptive naming in your services (e.g., createCase, getUserCases) to mirror route functionality.

3. Core Functionality & Important Considerations  
   • Adhere to the "core-functionality.md" for handling cases, roles, and real-time messaging.  
   • Review "important-considerations.md" regularly (e.g., handling RLS, real-time events, caching strategies) and incorporate those best practices.

4. UI & Theme Integration  
   • Stick to the "ui-rules.md" for consistent layouts, accessible design, and a desktop-first approach.  
   • Apply "theme-rules.md" for the minimalist color palette and typography, ensuring a cohesive look across components.

5. Tech Stack Alignment  
   • Align all new code with "tech-stack.md" and "tech-stack-rules.md" (e.g., using Tailwind/Shadcn for styles, Supabase for backend, etc.).  
   • Keep your state management approach consistent (Zustand or React Context + Query) and store business logic in one place.

---

## 6. Testing Strategy

• Use Jest for unit tests, React Testing Library for component-level tests, and Cypress for end-to-end tests.  
• Organize tests within the "tests" folder or alongside the component they test (with a .test or .spec extension).  
• Focus on critical paths: user authentication, case creation, messaging, etc., as described in the "core-functionality.md" document.  
• Apply coverage thresholds to ensure new features maintain test quality.

---

## 7. Enforcing File Size Limits

• Each file must remain under ~250 lines to keep it parseable and comprehensible for both human developers and AI tools.  
• Split large modules into smaller ones if needed. For instance, break out smaller helpers or separate your types/interfaces into dedicated files in the "types" folder.

---

## 8. Maintenance and Evolution

1. Refactoring  
   • Regularly refactor stale features, particularly if the AI-assisted code becomes outdated or messy.  
   • Keep an eye on performance bottlenecks in real-time updates, especially for chat and case notifications.

2. Version Control & Collaboration  
   • Use descriptive commit messages referencing relevant tickets or features.  
   • Leverage code reviews to ensure new changes align with these best practices.

3. Documentation Updates  
   • Update these best practices and other rule documents as new technologies or patterns are introduced.  
   • Keep the README current with quick start commands, environment variables, and major project decisions.

---

By rigorously following these codebase best practices, our team will maintain a concise, AI-friendly, and feature-rich application that aligns with the project's data models, routing requirements, core functionality, UI guidelines, and theme choices. This structure promotes rapid iteration, simplified collaboration, and clarity for all stakeholders. 