# Phase 0: Setup & Environment Configuration

> This phase ensures a stable foundation for the project, installing dependencies and establishing a working development environment. See @codebase-best-practices.md for guidelines on file structure and naming.

## Prerequisites
- Node.js (LTS) and a package manager (npm, yarn) installed
- Supabase account (optional but recommended if testing immediately)
- Git repo initialized for version control
- Familiarity with Vite, React, and Tailwind

## Steps
1. [ ] FRONTEND: Initialize a new Vite + React + TypeScript project  
2. [ ] FRONTEND: Install primary dependencies:  
   - React, ReactDOM  
   - TypeScript  
   - Tailwind CSS  
   - Shadcn UI (Radix UI + Shadcn setup)  
   - React Context for global state management 
   - React Query or React-Query-like library  
3. [ ] FRONTEND: Configure Tailwind and verify basic styling  
4. [ ] BACKEND: Verify or create a Supabase project (for remote usage)
5. [ ] FRONTEND: Create basic folder structure adhering to @codebase-best-practices.md (e.g., /src/app, /src/components, /src/hooks, /src/services, etc.)  
6. [ ] BOTH: Add environment variables for Supabase (if applicable), ensuring .env files are ignored in .gitignore
7. [ ] FRONTEND: Create a simple "App.tsx" and/or "MainLayout.tsx" verifying that Tailwind and Shadcn UI styles are applied  
8. [ ] FRONTEND: Confirm dev server functionality (npm run dev) and see a basic Shadcn UI component test

## Success Criteria
- A running Vite + React + TS project in dev mode without errors  
- Tailwind and Shadcn UI confirmed (basic component or style check)  
- Git repo with .gitignore configured (ignoring .env files)  
- Optional Supabase initialization (if connecting early to test DB queries)

## Test Cases
- Happy path: Developer can clone the repo, install dependencies, and run the app immediately  
- Error/edge case: Missing environment variables produce helpful error messages, not silent failures  
- Validation test: Simple Shadcn UI button or component renders correctly 