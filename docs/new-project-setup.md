## Below is a recommended order for creating these documents so each naturally builds upon the previous. This sequence ensures we first set the project context (overview, user flow, tech decisions), then define our rules (tech stack, UI, theme, code organization), and finally outline our phased approach and detailed workflows.

1. @project-overview.md
   - Establish overall project purpose, scope, and goals.

2. @user-stories.md
   - Break down the user stories for each user type (customers, agents, admins, unauthenticated users).

3. @project-map.md
   - Generate site map 

4. @user-flow.md
   - Clarify how users will interact with the application (registration, navigation, messaging flows).

5. @technical-requirements.md
   - Generate comprehensive overview of the data models, core functionality, authorization, and real-time requirements needed to fulfill the user stories and features we've outlined.

6. @data-model.md
   - Break down the data models and relationships needed for our project.
  
7. @core-functionality.md
   - Break down the core functionality requirements for our project.

8. @important-considerations.md
   - Break down the important considerations for our project.

9.  @system-architecture.md
   - Provide segmented overview of our project's system architecture, including api routes. 

10. @product-requirements.md
   - Create actionable and implementation-ready set of requirements for our project.

11. @tech-stack.md
   - Describe the core technologies used (Node, Vite, React, TypeScript, etc.) and their roles.

12. @tech-stack-rules.md
   - Lay out best practices, limitations, and conventions for using the selected technologies.

13. @ui-rules.md
   - Define visual and interaction guidelines for building components (including accessibility and design principles).

14. @theme-rules.md
   - Establish theming foundations (colors, typography, animations) to be incorporated into UI development.

15. @codebase-best-practices.md  
   - Outline folder structure, file naming conventions, and Vite + React best practices.

16. ./checklists/
   - Outline the different phases of the project, and the different tasks and features we'll need to complete in order to complete our goal. Each feature (or group of features) should have its own phase document.

17.  @ui-workflow-checklist.md  
    - Provide a step-by-step "state machine" for implementing or modifying front-end/UI features in detail.

18.  @backend-workflow-checklist.md  
    - Similarly, provide a systematic approach for creating or updating back-end logic, route handlers, and real-time functionality.


<hr></hr>

## Below are recommended steps/prompts for creating these files from scratch, with only the project overview to guide you.


1. `o1`
```
Use @project-overview.md to create a document called `user-stories.md`. This document should consider four types of users:
Customers
Agents (employees)
Admins
Unauthenticated Users

Think step by step about these four user types and their needs. For each role:

Identify their main goals
List their key permissions
Describe their typical workflows

Frame your analysis as detailed user stories that capture:

What they need to accomplish
Why they need it
How they'll interact with the system

Output the user stories by role in a numbered list. 

Provide the file in markdown format.
```


2. `o1`
```
Use @project-overview.md and @user-stories.md to create a document called `project-map.md`, which should be a high-level website map (site structure).

It should be organized by user type (unauthenticated visitors, customers, agents, and admins), with each section linking back to features described in the specs. Make this thorough and exhaustive so it can be a reliable reference for other parts of the build process.

Provide the file in markdown format.
```


3. `o1`
```
Use @project-overview, @user-stories.md, and @project-map.md to create a document called `user-flow.md`, which should define the user journey through different segments of the map. 

The user journey should take into account the different features the app has & how they are connected to one-another. This document will later serve as a guide for building out our project architecture and UI elements.

Provide the file in markdown format.
```


4. `o1`
```
Use @project-overview.md, @user-stories.md, @project-map.md, and user-flow.md to create a document called `technical-requirements.md`, which should be a thorough and exhaustive list of technical requirements.

Think step by step about:

What data models we need to store
What fields each model requires
Relationships between models

Frame your response as:

- Data Models with fields and relationships
- Core functionality requirements
- Other considerations
   - reference @known-issues.md for any known issues and important considerations.

Provide the file in markdown format. 
```


5. `claude` agent
```
breakdown @technical-requirements into three additional documents:
`data-model.md`
`core-functionality.md`
`important-considerations.md`
```


6. `o1` 
```
Use @data-model.md, @core-functionality.md, and @important-considerations.md to create a document called `system-architecture.md` for our zendesk clone app. Think step by step about:

1. Define API endpoints needed for each data model
2. Plan the component hierarchy and page structure
3. Outline key middleware and auth flows

Frame your response as:
1. API Routes with HTTP methods and auth requirements
2. Page structure and components needed
3. Key middleware functions

Number each item and use single, clear sentences. Focus on what we need for implementation. 

Provide the file in markdown format. 
```


7. `o1`
```
Use @system-architecture.md, @data-model.md, @core-functionality.md, and @important-considerations.md to create a document called `product-requirements.md`. This should provide a roadmap for delivering our project efficiently.

Structure our PRD as follows:

Project Overview (2-3 sentences max)
Core Workflows (numbered list, one sentence each)
Technical Foundation

Data models
API endpoints
Components to be used

Keep each point actionable and implementation-ready. Use clear, direct language with no fluff. but be exhaustive and include everything we will need. 

Provide the file in markdown format. 
```


8. `o1` NOTE: if you have any stack preferences, mention them here. It will make a much better plan that way.
```
Use  @project-overview.md , @project-map.md , and @user-flow.md to make recommendations for our stack. I already know I want to use: 

Frontend: TypeScript, Vite/React, Tailwind, Shadcn
Backend: postgres on Supabase for the backend 
Other Supabase features: Realtime, Auth, Storage, pgvector,
AI endpoint: Langchain and fastapi

For each anticipated part of our stack, propose and describe an industry standard and a popular alternative, as well as a list of 1 or more other options. We will work through the list together to determine what we'll use for the project.

Put this in a markdown file called `tech-stack-options.md`.
```


9. `claude` USER ACTION: Look through the proposed file and think about what you want to pick. For ones you're unsure of, talk to Claude about pros/cons, have it look at the other selections from the stack to maybe see what's most compatible, etc.


10. `claude` NOTE: Give it back your final stack choices, and ask it to evaluate it for compatibility. If it looks good to you, ask it to clean @tech-stack-options.md to only include your decisions, then proceed.


11. `o1` NOTE: Make sure you've finalized @tech-stack-options.md and renamed it to @tech-stack.md.
```
Use @tech-stack.md to create a document called `tech-stack-rules.md`.
This file should cover all best-practices, limitations, and conventions for using the selected technologies.
It should be thorough, and include important considerations and common pitfalls for each technology.

Provide the file in markdown format.
```


12. `o1` NOTE: If you don't know much about UI, UX, design, or theming, this is a great opportunity to learn.
```
I want to learn more about common design principles, and how they might be applied to our project.
Give me a list of 15 possible themes (e.g. "minimalist", "retro", "futuristic", "glassmorphic", etc), with a description of each one.
Observe @project-overview.md and @user-flow.md for context about the project to guide your recommendations.
```


13. `o1` NOTE: Edit the blank spaces in the prompt to suit your desires for the project.
```
I want my project to be ____ (mobile-first, responsive, animated, etc). We need to define the visual and interaction guidelines for building components (including accessibility and design principles), as well as any tie-ins with the tech stack (consider our backend, for example).

Also, I have decided I want my theme to be ____ (minimalist, retro, futuristic, glassmorphic, etc).

Use @user-flow.md, @tech-stack.md, and @tech-stack-rules.md to put together two new files, called `ui-rules.md` and `theme-rules.md`.
```


14. `o1`
```
We need to define our project's folder structure, file naming conventions, and any other rules we need to follow.

We are building an AI-first codebase, which means it needs to be modular, scalable, and easy to understand. The file structure should be highly navigable, and the code should be well-organized and easy to read.
All files should have an explanation of their contents at the top, and all functions should have proper commentation of their purpose and parameters (JSDoc, TSDoc, etc, whatever is appropriate).
To maintain readability by Cursor's AI tools, files should not exceed 250 lines.

Use @tech-stack.md, @tech-stack-rules.md, @ui-rules.md, and @theme-rules.md to put together a new file called `codebase-best-practices.md`. This document should also include a file tree demonstrating the proper separation of concerns given our project's expected structure.
```


15. `o1`
```
We need to define the different tasks and features we'll need to complete in order to build our project.

Create a phased approach to building the application, and define the different tasks and features we'll need to complete in order to complete our goal.

Rules to follow:
- Each phase should have its own document
- Each phase should be specific to a feature, or a group of closely-related features
- Each feature should have a checklist of actionable steps, clearly specifying which steps are frontend and which are backend (frontend first, backend second)
- Some tasks will be more complex than others, and will require more steps to complete. Don't be afraid to break down a task into multiple steps-- the checklist can be as long as you want.
- Create as many phases as you deem appropriate, as long as they are specific.

Use @project-overview.md , @user-flow.md , @tech-stack.md , @tech-stack-rules.md , @ui-rules.md , @theme-rules.md , and @codebase-best-practices.md to put together each of these new files.
```


16. `o1`
```
Please also create a `phase-0-setup.md` file, which will be a checklist of the initial setup of the project, including installing dependencies, setting up dev tools, and configuring the environment.
```


17. `o1` (OPTIONAL)
```
For each of the files attached, within each one, flatten its lists into a single list of actionable steps. Format each checklist item with "[ ]" to denote empty completions status. Also, follow the bracket with either "FRONTEND: " or "BACKEND: ", based on the nature of the task.
```


18. USER ACTION: Make a brief Agent Rules document, which will be a list of rules for the agent to follow.
```
# Rules for AI Agents

- ALWAYS use @ui-workflow.md and @backend-workflow.md when beginning (or continuing) implementation for a feature phase.
- ALWAYS validate any changes to the codebase against @codebase-best-practices.md
```


14. `claude` ATTACH: `Agent Rules`, `phase-0-setup.md` (current phase doc), `ui-workflow.md` (one of our interactive workflow docs), `backend-workflow.md` (our other interactive workflow doc), and `codebase-best-practices.md` (just good to always have in context)
```
Let's get started on our project.
```
