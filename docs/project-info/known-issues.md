
### Important considerations for building a case management system with Supabase:

- Authorization requirements with supabase built-in auth
  - Consider a single, top-layer Auth provider that is simple to implement and straightforward to maintain

- Realtime requirements with supabase built-in functionality
  - Consider realtime subscription requirements to avoid frequent reloads and latency issues, which can be caused by realtime data modifications triggering notifications to all subscribed clients
  - Consider partial updates over full refetch, where appropriate

- Storage requirements with supabase built-in storage

- State management requirements

- Well architected and well named tables and relations in the database

- Code modularity and reusability