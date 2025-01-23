# Phase 5: Attachments and Feedback

> Allows file uploads via Supabase Storage (or equivalent) and provides a post-resolution feedback mechanism per @data-model.md.

## Prerequisites
- Phase 4 completed (case, messaging flows)
- Supabase Storage or file handling system configured

## Steps
1. [ ] BACKEND: Implement POST /cases/:caseId/attachments, GET /cases/:caseId/attachments, DELETE /cases/:caseId/attachments/:attachmentId  
2. [ ] FRONTEND: Build an "Upload Attachment" UI in the case detail or messaging section (drag-and-drop or file input)  
3. [ ] BACKEND: Secure attachment endpoints so only case owners, assigned agents, or admins can manage attachments  
4. [ ] FRONTEND: Provide a list of attachments in the case detail, with ability to download/view (if needed)  
5. [ ] BACKEND: Implement POST /cases/:caseId/feedback and GET /cases/:caseId/feedback for capturing client ratings and comments  
6. [ ] FRONTEND: Display a "Leave Feedback" form for clients after case resolution (e.g., case status is "Closed")  
7. [ ] FRONTEND: Provide a read-only feedback view for assigned agents or admins to see aggregated ratings

## Success Criteria
- Clients can upload and manage attachments on their own cases  
- Agents or admins can see (and possibly remove) attachments for assigned cases  
- Feedback from clients is properly stored and retrievable in a structured format  
- Attachments and feedback align with minimalistic UI patterns from @ui-rules.md

## Test Cases
- Happy path: Client uploads an attachment, agent sees it in the case detail; client leaves feedback upon closure, agent can view rating  
- Error/edge case: Attempting to upload or delete an attachment in a case that the user doesn’t own is blocked by RLS 
- Validation test: Confirm file references in the DB match actual storage in Supabase 