# Row Level Security (RLS) Policies

This document outlines the access control policies for each table in our database. Use this as a reference when building frontend features to understand what data users can access.

## User Roles

1. **Client**
   - Can only access their own data
   - Cannot see other clients' information
   - Limited to their own cases and related data

2. **Agent**
   - Can access cases assigned to them
   - Can see all cases within their team
   - Can create and manage case-related content

3. **Admin**
   - Full access to all data
   - Can manage users and assignments
   - Can override normal access restrictions

## Table Access Patterns

### Users Table
- **Client**: Can only view/edit their own profile
- **Agent**: Can view client profiles for their cases
- **Admin**: Full access to all user data

### Cases Table
- **Client**: 
  - View: Own cases only
  - Create: Can create new cases
  - Update: Cannot update case status
- **Agent**: 
  - View: All assigned cases and team cases
  - Create: N/A
  - Update: Can update assigned cases
- **Admin**: Full access

### Messages Table
- **Client**:
  - View: Messages in their cases
  - Create: Can send messages in their cases
- **Agent**:
  - View: Messages in assigned cases
  - Create: Can send messages in assigned cases
- **Admin**: Full access

### Attachments Table
- **Client**:
  - View: Attachments in their cases
  - Upload: Can upload to their cases
- **Agent**:
  - View: Attachments in assigned cases
  - Upload: Can upload to assigned cases
- **Admin**: Full access

### Message Attachments Table
- **Client**:
  - View: Attachments in their messages
  - Create: Can attach to their own messages
- **Agent**:
  - View: Attachments in case messages
  - Create: Can attach to their messages
- **Admin**: Full access

### Internal Notes Table
- **Client**: No access
- **Agent**:
  - View: Notes for assigned cases
  - Create: Can add notes to assigned cases
- **Admin**: Full access

### Teams Table
- **Client**: No access
- **Agent**: Can view own team
- **Admin**: Full access

### Team Members Table
- **Client**: No access
- **Agent**: Can view own team members
- **Admin**: Full access

### Feedback Table
- **Client**:
  - View: Own feedback
  - Create: Can submit feedback for their cases
- **Agent**: Can view feedback for assigned cases
- **Admin**: Full access

### Statuses & Tags Tables
- **Client**: Read-only access
- **Agent**: Read-only access
- **Admin**: Full access

## Frontend Implementation Guide

### Fetching Data
```typescript
// RLS automatically filters results based on user role
const { data: cases } = await supabase
  .from('cases')
  .select('*')  // Returns only accessible cases

// Joining related data
const { data: messages } = await supabase
  .from('messages')
  .select(`
    *,
    attachments:message_attachments(
      id,
      attachment:attachments(*)
    )
  `)
  .eq('case_id', caseId)  // RLS applies to joined tables
```

### Common Patterns

1. **Case-based Access**
   - Most queries should include case_id
   - Access is automatically filtered by RLS
   - Example: `messages`, `attachments`, `internal_notes`

2. **User-based Access**
   - Personal data filtered by user ID
   - Example: profile information, feedback

3. **Team-based Access**
   - Agents can see team-related data
   - Filtered through team membership

### Error Handling

Common RLS-related errors to handle:
1. Permission denied (403)
2. Resource not found (404)
3. Unauthorized action (401)

Example:
```typescript
try {
  const { data, error } = await supabase
    .from('cases')
    .insert(newCase)
  
  if (error) {
    if (error.code === '42501') {
      // Permission denied
      showError('You don\'t have permission to create cases')
    }
  }
} catch (e) {
  // Handle other errors
}
```

## Testing Access Patterns

When building features, test with different user roles:
1. Log in as different user types
2. Verify correct data visibility
3. Test create/update operations
4. Verify error handling