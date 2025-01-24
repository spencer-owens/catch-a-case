# Database Migrations

This directory contains all database migrations for the case management system.

## Directory Structure

```
migrations/
├── schema/                 # Core table definitions and relationships
│   ├── 001_users.sql
│   ├── 002_teams.sql
│   └── 003_cases.sql
├── policies/              # Row Level Security (RLS) policies
│   ├── 001_basic_policies.sql
│   └── 002_message_policies.sql
├── functions/             # Helper functions and stored procedures
│   ├── 001_auth_helpers.sql
│   └── 002_validation.sql
├── triggers/              # Database triggers and event handlers
│   ├── 001_audit_triggers.sql
│   └── 002_validation_triggers.sql
├── performance/           # Indexes and optimizations
│   └── 001_add_indexes.sql
├── seed_data/            # Test and sample data
│   ├── 001_test_data.sql
│   └── 002_sample_cases.sql
└── revert/               # Rollback scripts for each migration
    └── 001_revert_basic_tables.sql
```

## Migration Naming Convention

Format: `{sequence}_{timestamp}_{description}.sql`

Example: `001_20240123_create_users_table.sql`

## Migration Order

1. Schema migrations (create tables)
2. Function definitions
3. Trigger setup
4. RLS policy implementation
5. Performance optimizations
6. Test data insertion

## Running Migrations

Connect to the database:
```bash
psql "postgresql://postgres:[password]@[host]/postgres"
```

Run a migration:
```bash
psql "postgresql://postgres:[password]@[host]/postgres" -f migrations/schema/001_users.sql
```

## Testing

Each policy has a corresponding test file in the policies directory:
```bash
psql "postgresql://postgres:[password]@[host]/postgres" -f migrations/policies/test_messages_policies.sql
```

## Best Practices

1. Always include both up and down migrations
2. Test migrations in development first
3. Document any manual steps required
4. Keep migrations idempotent
5. Use IF EXISTS/IF NOT EXISTS
6. Include relevant indexes with table creation 