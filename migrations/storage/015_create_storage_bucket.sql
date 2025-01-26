-- Create a new storage bucket for case attachments
insert into storage.buckets (id, name, public)
values ('case-attachments', 'case-attachments', false);

-- Enable RLS
alter table storage.objects enable row level security;

-- Create policies for the case-attachments bucket
create policy "Users can upload case attachments"
  on storage.objects for insert
  with check (
    bucket_id = 'case-attachments' and
    (auth.role() = 'authenticated')
  );

create policy "Users can view their case attachments"
  on storage.objects for select
  using (
    bucket_id = 'case-attachments' and
    (
      -- Client can view their own case attachments
      exists (
        select 1 from public.cases c
        join public.attachments a on a.case_id = c.id
        where 
          c.client_id = auth.uid() and
          a.file_path = storage.objects.name
      )
      -- Agent can view attachments for assigned cases
      or exists (
        select 1 from public.cases c
        join public.attachments a on a.case_id = c.id
        where 
          c.assigned_agent_id = auth.uid() and
          a.file_path = storage.objects.name
      )
      -- Admin can view all attachments
      or exists (
        select 1 from public.users
        where id = auth.uid() and role = 'admin'
      )
    )
  );

create policy "Users can delete their case attachments"
  on storage.objects for delete
  using (
    bucket_id = 'case-attachments' and
    (
      -- Client can delete their own case attachments
      exists (
        select 1 from public.cases c
        join public.attachments a on a.case_id = c.id
        where 
          c.client_id = auth.uid() and
          a.file_path = storage.objects.name
      )
      -- Agent can delete attachments for assigned cases
      or exists (
        select 1 from public.cases c
        join public.attachments a on a.case_id = c.id
        where 
          c.assigned_agent_id = auth.uid() and
          a.file_path = storage.objects.name
      )
      -- Admin can delete all attachments
      or exists (
        select 1 from public.users
        where id = auth.uid() and role = 'admin'
      )
    )
  );

-- Create a function to clean up storage objects when attachments are deleted
create or replace function public.handle_deleted_attachment()
returns trigger
language plpgsql
security definer
as $$
declare
  storage_object record;
begin
  -- Delete the corresponding storage object
  delete from storage.objects
  where bucket_id = 'case-attachments'
  and name = old.file_path;
  
  return old;
end;
$$;

-- Create the trigger
create trigger on_attachment_deleted
  after delete on public.attachments
  for each row
  execute function public.handle_deleted_attachment();
