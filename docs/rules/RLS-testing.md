# Common Testing Pitfalls

## Access Check Reliability
- Avoid using `PERFORM` for access checks as it can give false results
- Instead use explicit `SELECT COUNT(*)` queries to verify access
- For update/delete operations, compare row counts before and after to verify the effect

Example:
```sql
-- DON'T ❌
BEGIN
    PERFORM 1 FROM my_table LIMIT 1;
    RAISE NOTICE 'Unexpectedly able to access table';
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'Expected: Cannot access table';
END;

-- DO ✅
BEGIN
    SELECT COUNT(*) INTO v_count FROM my_table;
    IF v_count > 0 THEN
        RAISE NOTICE 'Unexpectedly able to view % rows', v_count;
    END IF;
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'Expected: Cannot access table';
END;
```

## Policy Design for Testability
- Keep policy conditions simple and direct
- Avoid complex nested CASE statements that make testing harder
- Use separate policies for different operations (SELECT, INSERT, UPDATE, DELETE)
- Include both USING and WITH CHECK clauses for INSERT/UPDATE policies

Example:
```sql
-- DON'T ❌ (Hard to test and maintain)
CREATE POLICY "Complex policy" ON my_table
FOR ALL TO authenticated
USING (
    CASE 
        WHEN is_admin() THEN true
        WHEN is_agent() THEN EXISTS (SELECT 1 FROM ...)
        ELSE false
    END
);

-- DO ✅ (Clear and testable)
CREATE POLICY "Admins have full access" ON my_table
FOR ALL TO authenticated
USING (is_admin());

CREATE POLICY "Agents can view assigned" ON my_table
FOR SELECT TO authenticated
USING (
    is_agent() AND EXISTS (
        SELECT 1 FROM related_table
        WHERE related_table.id = my_table.related_id
        AND related_table.assigned_to = auth.uid()
    )
);
```

## Verifying Write Operations
- For INSERT/UPDATE/DELETE operations, always verify:
  1. Whether the operation was allowed/denied (insufficient_privilege)
  2. Whether the operation had the intended effect (row count changes)
  3. Whether any trigger validations are hit before RLS policies

Example:
```sql
-- Check update operation
BEGIN
    -- Get count before
    SELECT COUNT(*) INTO v_count FROM my_table WHERE condition;
    
    -- Attempt update
    UPDATE my_table SET field = 'new value' WHERE condition;
    
    -- Verify effect
    SELECT COUNT(*) INTO v_count_after FROM my_table WHERE condition AND field = 'new value';
    
    IF v_count = v_count_after THEN
        RAISE NOTICE 'Update had no effect';
    ELSE
        RAISE NOTICE 'Unexpectedly able to update % rows', v_count - v_count_after;
    END IF;
EXCEPTION
    WHEN insufficient_privilege THEN
        RAISE NOTICE 'Expected: Cannot update rows';
END;
``` 