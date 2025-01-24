# Row Level Security (RLS) Policies

This document outlines the Row Level Security (RLS) policies implemented in our case management system. These policies ensure data access is properly restricted based on user roles and ownership.

## Core Concepts

### User Roles
- **Admin**: Full system access
- **Agent**: Case management and client communication
- **Client**: Access to own cases and related data

### Helper Functions
```sql
-- Check if user is admin
public.is_admin() -> boolean

-- Check if user is agent
public.is_agent() -> boolean
```

## Table Access Patterns

### Users Table
- **SELECT**: Everyone (needed for UI displays)
- **INSERT/UPDATE/DELETE**: Admins only

### Teams & Team Members
- **SELECT**: Everyone
- **INSERT/UPDATE/DELETE**: Admins only

### Cases
- **Admins**: Full access to all cases
- **Agents**: 
  - Can view all cases
  - Can update cases assigned to them
- **Clients**: 
  - Can view their own cases
  - Can create new cases (automatically set as owner)

### Messages
- **Admins**: Full access
- **Agents & Clients**:
  - Can view messages for cases they're involved with
  - Can create messages for their cases (sender_id must match auth.uid())

### Internal Notes
- **Admins & Agents**: 
  - Can view all internal notes
  - Agents can create notes (agent_id must match auth.uid())
- **Clients**: No access

### Attachments
- **Access Pattern**: Similar to messages
- Users can view/upload attachments for cases they're involved with
- uploader_id must match auth.uid() for uploads

### Feedback
- **Clients**: 
  - Can create feedback for their own cases
  - client_id must match auth.uid()
- **Agents & Admins**: Can view all feedback

### Reference Data (Statuses & Tags)
- **SELECT**: Everyone
- **INSERT/UPDATE/DELETE**: Admins only

## Implementation Details

### Policy Structure
Each policy follows this pattern:
```sql
CREATE POLICY "Policy name"
  ON table_name
  FOR operation -- SELECT, INSERT, UPDATE, DELETE, or ALL
  USING (check_expression) -- For SELECT, UPDATE, DELETE
  WITH CHECK (check_expression); -- For INSERT, UPDATE
```

### Common Patterns
1. Admin full access:
```sql
USING (is_admin())
WITH CHECK (is_admin())
```

2. Owner-based access:
```sql
USING (user_id = auth.uid())
```

3. Case-based access:
```sql
USING (
  EXISTS (
    SELECT 1 FROM cases
    WHERE cases.id = table.case_id
    AND (
      cases.client_id = auth.uid()
      OR cases.assigned_agent_id = auth.uid()
      OR is_agent()
    )
  )
)
```

## Testing RLS Policies

To test these policies:
1. Create users with different roles
2. Try accessing data as different users
3. Verify access is properly restricted

Example test cases:
- Client trying to view another client's cases (should fail)
- Agent trying to update a case not assigned to them (should fail)
- Admin performing any operation (should succeed)

## Maintenance

When adding new tables:
1. Enable RLS: `ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;`
2. Consider access patterns based on user roles
3. Create appropriate policies following patterns above
4. Document new policies in this README

## Troubleshooting

Common issues:
1. **No access to any rows**: Check if RLS is enabled and policies exist
2. **Unexpected access denied**: Verify user role and ownership
3. **Policy conflicts**: Policies are OR'ed together; ensure they don't grant unintended access
