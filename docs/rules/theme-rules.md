# Theme Rules (Minimalist)

This document outlines the design principles and guidelines for our Minimalist theme, ensuring visual consistency and a user-friendly experience across the application. These rules build on our Technical Requirements, Product Requirements, Tech Stack, and Tech Stack Rules.

---

## 1. Core Principles of Minimalism

• Reduce visual clutter by focusing on essential elements; keep interfaces clean and direct.  
• Use plenty of whitespace to draw attention to critical components and data.  
• Limit color usage to a simple palette, relying on neutral shades for backgrounds and subtle accent colors for highlights or interactive states.  
• Support quick scanning by maintaining a clear hierarchy in typography (headings vs. body text).

---

## 2. Color Palette

• Base / Background: Light grays or whites (e.g., #FFFFFF, #F9FAFB) for a clean foundation.  
• Text & Icons: Dark grays or black (e.g., #111827) for high contrast.  
• Accents: A single accent color (e.g., a subdued blue #3B82F6 or a green #10B981) for call-to-action elements like buttons or active states.  
• Error States: A subtle but visible red (#EF4444) when inputs or operations fail, ensuring strong contrast.  

Note: Tailwind's default color palette is sufficient, but keep usage minimal to maintain the theme's aesthetic.

---

## 3. Typography & Scale

• Adopt a minimalistic typography set, typically one primary typeface for headings and body text (e.g., Inter, Roboto).  
• Ensure heading sizes are clearly distinct (e.g., text-2xl for H1, text-xl for H2) while body text remains comfortable at text-base or text-sm.  
• Maintain consistent line-heights and letter-spacing across all text styles for readability.

---

## 4. Layout & Spacing

• Maintain moderate padding and margins between components (e.g., p-4 or p-6) for a clean composition.  
• Utilize Tailwind's spacing utilities to ensure consistent vertical and horizontal spacing.  
• Keep section dividers subtle—rely on whitespace or faint borders (e.g., border-gray-200) instead of heavy lines or backgrounds.

---

## 5. Iconography & Imagery

• Use simple, flat icons that match the minimalist style.  
• Limit decorative imagery; only include relevant diagrams or screenshots for clarity.  
• Keep icons consistent in stroke weight and style (e.g., Heroicons).

---

## 6. Accessibility & Contrast

• Maintain sufficient color contrast, particularly for text and interactive elements, to meet WCAG AA standards.  
• Use focus outlines or highlights that complement your chosen accent color for keyboard navigability.

---

## 7. Component & Page-Level Consistency

• Apply the same spacing, color usage, and font styles across all pages (client dashboard, agent queue, admin management).  
• Keep form controls, buttons, and modals aligned with the overarching minimalist design by limiting extraneous borders, shadows, or patterns.  
• Rely on standardized Shadcn UI components so each page feels cohesive within the theme.

---

## 8. Animation & Effects

• Keep animations subtle and purposeful, avoiding excessive movement that might distract users.  
• Favor short transitions (e.g., 150-300ms) for hover states or page load transitions, enabling a subtle sense of responsiveness.  
• Avoid large, invasive animations that detract from the minimalist user experience.

---

## 9. Tie-Ins with the Tech Stack

• Ensure any real-time UI changes (e.g., new messages, updated case statuses) respect the minimalist design—display small, unobtrusive notifications or badges.  
• Sync with Supabase attachment capabilities in a clean, streamlined manner—for instance, minimal drag-and-drop areas or simple file input fields.  
• Use Shadcn UI's built-in theming capabilities to refine color and spacing variables once, allowing easy global design updates.

---

By following these Theme Rules, we create a cohesive, minimalist aesthetic that supports clear communication and a refined user experience. All design choices should be deliberate, focusing on simplicity, usability, and alignment with our project's desktop-first strategy. 