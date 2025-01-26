# Phase 5: Attachments and Feedback

> Allows file uploads via Supabase Storage (or equivalent) and provides a post-resolution feedback mechanism per @data-model.md.

## Prerequisites
- [x] Phase 4 completed (case, messaging flows)
- [x] Supabase Storage or file handling system configured

## Steps
1. [x] BACKEND: Implement POST /cases/:caseId/attachments, GET /cases/:caseId/attachments, DELETE /cases/:caseId/attachments/:attachmentId  
2. [x] FRONTEND: Build an "Upload Attachment" UI in the case detail or messaging section (drag-and-drop or file input)  
3. [x] BACKEND: Secure attachment endpoints so only case owners, assigned agents, or admins can manage attachments  
4. [x] FRONTEND: Provide a list of attachments in the case detail, with ability to download/view (if needed)  
5. [x] BACKEND: Implement POST /cases/:caseId/feedback and GET /cases/:caseId/feedback for capturing client ratings and comments  
6. [x] FRONTEND: Display a "Leave Feedback" form for clients after case resolution (e.g., case status is "Closed")  
7. [x] FRONTEND: Provide a read-only feedback view for assigned agents or admins to see aggregated ratings

## Success Criteria
- [x] Clients can upload and manage attachments on their own cases  
- [x] Agents or admins can see (and possibly remove) attachments for assigned cases  
- [x] Feedback from clients is properly stored and retrievable in a structured format  
- [x] Attachments and feedback align with minimalistic UI patterns from @ui-rules.md

## Test Cases
- [x] Happy path: Client uploads an attachment, agent sees it in the case detail; client leaves feedback upon closure, agent can view rating  
- [x] Error/edge case: Attempting to upload or delete an attachment in a case that the user doesn't own is blocked by RLS 
- [x] Validation test: Confirm file references in the DB match actual storage in Supabase 