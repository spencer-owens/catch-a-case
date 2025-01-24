# RLS Testing Best Practices

## Common Pitfalls and Solutions

### 1. Schema Mismatches
When testing RLS policies, we encountered issues due to mismatches between our test assumptions and the actual table schema in Supabase:

- **Problem**: Test failed because we referenced a column `name` when the actual column was `status_name`
- **Solution**: Always verify the actual table structure before writing tests:
```sql
-- Get table structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'your_table' 
AND table_schema = 'public';
```

### 2. False Positives in Access Tests
We encountered misleading test results when checking if agents could delete statuses:

- **Problem**: Test showed "Unexpectedly able to delete" when the deletion actually had no effect
- **Root Cause**: The test only checked if the DELETE statement executed without an error, not if it actually modified data
- **Solution**: Always verify the actual effect of operations:
```sql
-- Before operation
SELECT COUNT(*) INTO v_count FROM your_table;

-- Attempt operation
DELETE FROM your_table WHERE id = some_id;
```

### 3. Trigger Validations vs RLS Policies
We discovered that trigger validations can interfere with RLS policy testing:

- **Problem**: Test failures might be due to trigger validations rather than RLS policies
- **Root Cause**: Tables often have both RLS policies and trigger-based validations
- **Solution**: Handle both types of restrictions in tests:
```sql
BEGIN
    INSERT INTO your_table (column1, column2) 
    VALUES ('test', 'data');
    RAISE NOTICE 'Unexpectedly succeeded';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'RLS policy blocked access (expected)';
    WHEN OTHERS THEN
        IF SQLERRM LIKE '%trigger validation%' THEN
            RAISE NOTICE 'Trigger validation blocked access';
        ELSE
            RAISE;
        END IF;
END;
```

### 4. Unique Constraints in Test Data
We found that unique constraints can affect RLS testing:

- **Problem**: Tests fail due to unique constraint violations rather than RLS policies
- **Solution**: Clean up test data before running tests and handle existing records:
```sql
-- Clean up test data
DELETE FROM your_table WHERE test_condition;

-- Check for existing records
SELECT id INTO existing_id FROM your_table 
WHERE unique_column = 'test_value';

IF existing_id IS NULL THEN
    -- Insert new test data
ELSE
    -- Use existing record
END IF;
```

## Best Practices Checklist

1. **Schema Verification**
   - [ ] Verify table structure before writing tests
   - [ ] Use column names from actual schema, not assumptions
   - [ ] Document required columns and constraints

2. **Operation Verification**
   - [ ] Check row counts before and after operations
   - [ ] Verify actual data changes, not just successful execution
   - [ ] Use explicit success/failure messages

3. **Test Organization**
   - [ ] Use transaction blocks for isolation
   - [ ] Reset context before each test
   - [ ] Clean up after tests
   - [ ] Test both positive and negative cases

4. **Policy Testing**
   - [ ] Test each operation (SELECT, INSERT, UPDATE, DELETE)
   - [ ] Test with different user roles
   - [ ] Verify both USING and WITH CHECK clauses
   - [ ] Test edge cases and boundary conditions 