# Phase Creation Guide

## Core Principles

1. **Database First**
   - Implement database schema and tables before building features
   - This prevents architectural changes later and ensures data consistency
   - Include proper relationships, constraints, and indexes from the start

2. **Test Data Strategy**
   - Populate test data immediately after creating each table
   - Create realistic dummy data that covers edge cases
   - Include a mix of data states (active, archived, different statuses)
   - Document test data creation scripts for reproducibility

3. **Task Granularity**
   - Keep tasks atomic and focused
   - Each task should be completable by an agent in one prompt
   - Avoid tasks that require complex decision trees or multiple major decisions
   - Target 15-30 minutes of work per task for an agent
  
4. **Component-Driven Development**
   - Create UI components before or alongside feature implementation
   - Include basic styling and responsiveness in component tasks
   - Ensure components are reusable and well-documented
   - Test components in isolation before integration

5. **Task Structure**
   - Break complex tasks into multiple sequential tasks
   - Each task should have clear success criteria
   - Clearly label tasks as frontend or backend
   - Don't hesitate to create long checklists for complex features

6. **Testing and Validation**
   - Include explicit testing tasks after each feature implementation
   - Define test cases before implementation
   - Include both happy path and error scenarios
   - Document expected behavior and edge cases

7. **Dependencies and Order**
   - List all prerequisites at the start of each phase
   - Ensure tasks flow logically (e.g., create form before submit handler)
   - Consider cross-cutting concerns (auth, logging, error handling)
   - Document any external service dependencies

8. **Phase Organization Best Practices**
   - Create a separate document for each phase
   - Focus each phase on a specific feature or closely-related feature group
   - Include setup and cleanup tasks in each phase
   - Document phase completion criteria
   - Create as many phases as needed to maintain specificity
   - Break down complex features into multiple phases if necessary

## Implementation Order Guidelines

1. **Foundation First**
   - Database schema and migrations
   - Authentication system
   - Core API structure
   - Base UI components and layouts
   - Error handling and logging

2. **Core Features**
   - Essential CRUD operations
   - Basic user flows
   - Primary navigation
   - Form validation

3. **Enhancement Layers**
   - Real-time features
   - Advanced search/filtering
   - Batch operations
   - Performance optimizations

4. **Polish and Integration**
   - UI/UX improvements
   - Analytics
   - Documentation
   - Deployment configuration

## Common Pitfalls to Avoid

1. **Overscoping Tasks**
   - Tasks should be completable in one prompt
   - Break down complex features into smaller steps
   - Avoid tasks with many decision points
   - Don't combine frontend and backend tasks

2. **Missing Dependencies**
   - Ensure all required components exist
   - Check for necessary API endpoints
   - Verify database schema support

3. **Unclear Success Criteria**
   - Define what "done" means for each task
   - Include specific acceptance criteria
   - List expected outputs or artifacts

4. **Poor Test Coverage**
   - Include testing in task estimates
   - Define test scenarios upfront
   - Consider edge cases and error states

5. **Phase Organization Issues**
   - Mixing unrelated features in one phase
   - Creating overly broad phases
   - Not separating frontend and backend concerns
   - Insufficient task breakdown

