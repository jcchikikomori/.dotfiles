---
name: oracle-sql
description: Oracle SQL coding standards, query optimization, indexing, PL/SQL best practices, and security.
---

# Oracle SQL Skill

## Query Standards

- Use **ANSI SQL join syntax** (`JOIN ... ON ...`) — never comma-separated joins in `FROM`.
- Always **alias tables** with meaningful short names: `SELECT u.name FROM users u`.
- Qualify all column references with the table alias to avoid ambiguity.
- Use **UPPER_CASE** for SQL keywords (`SELECT`, `FROM`, `WHERE`); use snake_case for identifiers.
- Format complex queries with consistent indentation (2 or 4 spaces); each clause on its own line.
- Use `:bind_variable` syntax for all user-supplied values — **never interpolate strings into SQL**.

## Indexing

- Add **indexes** on all columns used in `WHERE`, `JOIN`, `ORDER BY`, and `GROUP BY`.
- Use **composite indexes** when queries filter on multiple columns together; put the most selective column first.
- Use **function-based indexes** for queries that apply functions to indexed columns (e.g., `UPPER(email)`).
- Use `EXPLAIN PLAN FOR ...` to inspect execution plans before deploying complex queries.
- Avoid full table scans on large tables — always verify index usage in the plan.

## Data Integrity & Soft Delete

- Use **soft delete**: add a `deleted_at DATE` (or `is_deleted NUMBER(1) DEFAULT 0`) column — never hard-delete user-facing records.
- Add a `NOT NULL` constraint + `DEFAULT` for mandatory columns.
- Use **foreign key constraints** to enforce referential integrity.
- Add **unique constraints** for naturally unique fields (email, username).
- Schema changes require team lead approval.

## Sequences & Auto-increment

```sql
-- Create a sequence
CREATE SEQUENCE users_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Use in insert
INSERT INTO users (id, name) VALUES (users_seq.NEXTVAL, 'Alice');
```

- Prefer sequences over triggers for ID generation (simpler, more portable).
- In Oracle 12c+, use **identity columns**: `id NUMBER GENERATED ALWAYS AS IDENTITY`.

## PL/SQL Best Practices

- Name variables with a prefix to distinguish from column names: `v_user_id`, `p_input_param`, `l_local_var`.
- Always handle exceptions with `EXCEPTION WHEN OTHERS THEN` — log and re-raise; never silently swallow errors.
- Use `%TYPE` and `%ROWTYPE` for variable declarations to stay in sync with table schema.
- Prefer **stored procedures** for reusable DML; use **functions** only when a return value is needed.
- Avoid DDL inside PL/SQL blocks unless absolutely necessary.
- Use `BULK COLLECT` + `FORALL` for batch DML operations on large datasets.

## Performance

- Avoid `SELECT *` — always name the columns you need.
- Avoid functions on indexed columns in `WHERE` clauses (use function-based indexes if needed).
- Use `EXISTS` instead of `IN` with subqueries for better performance on large sets.
- Use `ROWNUM` / `FETCH FIRST n ROWS ONLY` (12c+) for pagination; never retrieve all rows then filter in application code.
- Commit large DML operations in batches to avoid redo log pressure.

## Security

- Use bind variables (`:param`) for all user input — **SQL injection prevention**.
- Grant minimum necessary privileges (`SELECT`, `INSERT` on specific tables — not `DBA`).
- Use **Virtual Private Database (VPD)** / row-level security for multi-tenant data isolation.
- Audit sensitive table access with `AUDIT SELECT ON table_name`.
- Never store plain-text passwords; use Oracle's `DBMS_CRYPTO` or application-layer hashing.
- Strip sensitive data from logs and error messages returned to users.

## Naming Conventions

| Object | Convention | Example |
|---|---|---|
| Table | snake_case, plural | `user_accounts` |
| Column | snake_case | `created_at` |
| Index | `idx_<table>_<columns>` | `idx_users_email` |
| Sequence | `<table>_seq` | `users_seq` |
| Stored Procedure | `sp_<verb>_<noun>` | `sp_create_user` |
| Function | `fn_<verb>_<noun>` | `fn_get_balance` |
| Trigger | `trg_<table>_<event>` | `trg_users_before_insert` |
