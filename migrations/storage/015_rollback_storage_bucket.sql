-- Drop the trigger first
drop trigger if exists on_attachment_deleted on public.attachments;

-- Drop the function
drop function if exists public.handle_deleted_attachment();

-- Drop the policies
drop policy if exists "Users can upload case attachments" on storage.objects;
drop policy if exists "Users can view their case attachments" on storage.objects;
drop policy if exists "Users can delete their case attachments" on storage.objects;

-- Delete the bucket and its contents
delete from storage.objects where bucket_id = 'case-attachments';
delete from storage.buckets where id = 'case-attachments'; 