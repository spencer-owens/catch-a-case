# UI Development Process

This document outlines our approach to building UI components and features using Tailwind CSS and manually created Shadcn UI components. Follow these guidelines to maintain consistency and efficiency in UI development.

## Component Development Flow

### 1. Component Planning
- Review requirements against `ui-rules.md` and `theme-rules.md`
- Check if a Shadcn UI pattern exists for the needed component
- Break down the component into smaller, reusable parts if necessary
- Consider responsive design requirements upfront

### 2. Component Creation

#### For Shadcn UI-based Components:
1. Create component in `src/components/ui/`
2. Follow Shadcn UI's component structure:
   ```typescript
   import * as React from "react"
   import { cn } from "@/lib/utils"
   
   interface ComponentProps {
     // Strong TypeScript types
   }
   
   const Component = React.forwardRef<HTMLElement, ComponentProps>((
     { className, ...props }, 
     ref
   ) => {
     return (
       <element
         ref={ref}
         className={cn(
           "shadcn-base-styles",
           className
         )}
         {...props}
       />
     )
   })
   Component.displayName = "Component"
   ```

#### For Custom Components:
1. Create in appropriate feature directory
2. Use Tailwind's utility classes following our class order convention:
   ```
   layout → positioning → display → spacing → sizing → typography → visual → interactive → misc
   ```
   Example:
   ```tsx
   <div className="
     flex flex-col          {/* layout */}
     relative              {/* positioning */}
     hidden md:block       {/* display/responsive */}
     p-4 gap-2            {/* spacing */}
     w-full max-w-md      {/* sizing */}
     text-sm font-medium  {/* typography */}
     bg-background        {/* visual */}
     hover:bg-muted       {/* interactive */}
     dark:bg-slate-800    {/* misc/theme */}
   ">
   ```

### 3. Styling Guidelines

#### Tailwind CSS Usage:
- Use semantic color variables from our theme:
  ```tsx
  // DO ✅
  className="bg-background text-foreground"
  
  // DON'T ❌
  className="bg-white text-black"
  ```

- Responsive Design:
  ```tsx
  // Mobile-first approach
  className="
    flex-col sm:flex-row    // Stack on mobile, row on larger screens
    w-full md:w-auto        // Full width mobile, auto on medium
    text-sm lg:text-base    // Smaller text mobile, larger on desktop
  "
  ```

#### Theme Integration:
- Use CSS variables for dynamic values:
  ```tsx
  // In Tailwind classes
  className="bg-primary text-primary-foreground"
  
  // In custom CSS if needed
  style={{
    borderRadius: 'var(--radius)',
    transition: 'var(--transition-default)'
  }}
  ```

### 4. Component Organization

```
src/
├── components/
│   ├── ui/               # Shadcn UI base components
│   │   ├── button.tsx
│   │   └── card.tsx
│   ├── features/         # Feature-specific components
│   │   ├── cases/
│   │   └── dashboard/
│   └── shared/          # Shared composite components
├── lib/
│   ├── utils.ts         # Utility functions (cn, etc.)
│   ├── supabase.ts      # Supabase client
│   └── context/         # React Context providers
└── styles/
    └── globals.css      # Global styles and Tailwind directives
```

### 5. Best Practices

1. **Component Composition**
   - Build larger components from smaller, reusable ones
   - Use Shadcn UI components as building blocks
   ```tsx
   // Good composition example
   function CaseCard({ case, ...props }) {
     return (
       <Card>
         <CardHeader>
           <CardTitle>{case.title}</CardTitle>
           <CardDescription>{case.description}</CardDescription>
         </CardHeader>
         <CardContent>
           <StatusBadge status={case.status} />
           <AssigneeAvatar user={case.assignee} />
         </CardContent>
       </Card>
     )
   }
   ```

2. **State Management**
   - Use React Query for server state
   - Use React Context for theme/global UI state
   - Keep component state minimal and focused
   - Implement loading and error states consistently

3. **Accessibility**
   - Maintain ARIA attributes from Shadcn UI components
   - Ensure keyboard navigation works
   - Test with screen readers
   - Maintain sufficient color contrast

4. **Performance**
   - Use `React.memo()` for expensive renders
   - Implement virtualization for long lists
   - Lazy load components when appropriate
   - Monitor bundle size impact

### 6. Testing Components

1. Visual Testing:
   - Test in light/dark modes
   - Verify responsive breakpoints
   - Check animations/transitions

2. Functional Testing:
   - Test user interactions
   - Verify accessibility
   - Check error states
   - Validate form inputs

## Example Implementation

```tsx
// src/components/features/cases/CaseList.tsx
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { useQuery } from "@tanstack/react-query"

export function CaseList() {
  const { data: cases, isLoading } = useQuery({
    queryKey: ['cases'],
    queryFn: async () => {
      // Fetch cases from Supabase
    }
  })

  if (isLoading) return <div>Loading...</div>

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {cases?.map((case) => (
        <Card key={case.id} className="hover:shadow-lg transition-shadow">
          <CardHeader>
            <CardTitle className="flex items-center justify-between">
              {case.title}
              <StatusBadge status={case.status} />
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground">{case.description}</p>
            <div className="mt-4 flex justify-end">
              <Button variant="outline" size="sm">
                View Details
              </Button>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
```

## Workflow Integration

This process integrates with our existing workflows:
1. Follow the UI Workflow checklist from `ui-workflow.md`
2. Reference this document for implementation details
3. Use `codebase-best-practices.md` for file organization
4. Validate against `ui-rules.md` and `theme-rules.md` 