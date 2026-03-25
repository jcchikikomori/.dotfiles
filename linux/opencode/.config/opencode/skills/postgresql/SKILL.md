---
name: postgresql
description: PostgreSQL coding standards, query optimization, indexing, migrations, and security best practices. Initial scaffold.
---

# PostgreSQL Skill

**Roadmap Alignment:** [roadmap.sh/postgresql-dba](https://roadmap.sh/postgresql-dba)  
**Reference:** [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)

> **Status:** Initial scaffold. Foundational guidance for PostgreSQL development and administration.

## When to Use This Skill

- Writing and reviewing SQL queries and schema designs
- Creating database migrations (standalone or framework-integrated)
- Performance tuning and index optimization
- Database security and access control
- Connection pooling and transaction management
- Replication and backup strategies

## Core Standards

### 1. Query Best Practices

- **Use Parameterized Queries:** Always use prepared statements with placeholders (`$1`, `$2`, etc.) to prevent SQL injection. Never concatenate user input into SQL strings.
- **Avoid N+1 Queries:** Fetch related data in a single query using `JOIN` or `WITH` (CTEs) rather than multiple round-trips.
- **Efficient WHERE Clauses:** Place indexed columns first in `WHERE` conditions. Use `EXPLAIN ANALYZE` to verify index usage.
- **Explicit Column Selection:** Select only required columns (`SELECT col1, col2`) rather than `SELECT *`.
- **Case Sensitivity:** PostgreSQL identifiers are case-insensitive but stored lowercase unless quoted. Quote names consistently or use lowercase conventions.

### 2. Indexing Conventions

- **Primary Keys:** Always define a primary key (surrogate or natural). Use `SERIAL` or `BIGSERIAL` for auto-incrementing IDs, or `UUID` for distributed systems.
- **Foreign Keys:** Enforce referential integrity with `FOREIGN KEY` constraints. Use `ON DELETE CASCADE` or `ON DELETE SET NULL` as appropriate.
- **Composite Indexes:** For multi-column `WHERE` clauses, create indexes on the combination of columns in the order they appear in the query (equality conditions first, range conditions last).
- **PARTIAL Indexes:** Use partial indexes for filtered queries (e.g., `WHERE status = 'active'`) to reduce index size.
- **Index Monitoring:** Regularly check for unused or duplicate indexes; remove them to reduce write overhead.

### 3. Schema Design

- **Naming Convention:** Use lowercase with underscores for tables and columns (e.g., `user_accounts`, `created_at`). Avoid reserved keywords.
- **Data Types:** Use appropriate types (`BOOLEAN`, `INTEGER`, `BIGINT`, `DECIMAL`, `TEXT`, `TIMESTAMP`, `UUID`). Avoid `TEXT` when a fixed-size type will suffice.
- **Nullable Columns:** Minimize `NULL` columns. Use `NOT NULL` with sensible defaults where possible.
- **Constraints:** Always define constraints (`NOT NULL`, `UNIQUE`, `CHECK`, `PRIMARY KEY`, `FOREIGN KEY`) to maintain data integrity at the database level.

### 4. Migration Strategies

- **Idempotent Migrations:** Migrations should be safe to run multiple times (use `IF NOT EXISTS` and `IF EXISTS`).
- **Minimal Per Migration:** One logical change per migration file for easy rollback and debugging.
- **Test Before Deploy:** Always test migrations on a copy of production data before running them in production.
- **Large Tables:** For adding columns to large tables, consider using `CONCURRENTLY` for index creation and `DEFAULT` values that don't lock the table.

### 5. Security

- **Least Privilege:** Create role/user accounts with minimal required permissions. Avoid using the superuser account for application connections.
- **Row-Level Security (RLS):** Use `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` and policies to enforce data isolation.
- **Secrets Management:** Store connection strings and credentials in environment variables or secure vaults. Never hardcode them.
- **Connection Pooling:** Use tools like `pgbouncer` or application-level pooling (e.g., Hikari for Java, `psycopg2-pool` for Python) to limit open connections.

### 6. Common Safe Query Patterns

**Basic SELECT with WHERE and ORDER BY:**
```sql
SELECT user_id, username, email
FROM users
WHERE status = $1 AND created_at > $2
ORDER BY created_at DESC
LIMIT $3 OFFSET $4;
```

**JOIN with aggregation:**
```sql
SELECT u.user_id, u.username, COUNT(o.order_id) AS order_count
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE u.status = $1
GROUP BY u.user_id, u.username
HAVING COUNT(o.order_id) > $2
ORDER BY order_count DESC;
```

**CTE (Common Table Expression) for complex queries:**
```sql
WITH active_users AS (
  SELECT user_id, username
  FROM users
  WHERE status = 'active'
)
SELECT au.user_id, au.username, COUNT(o.order_id) AS total_orders
FROM active_users au
LEFT JOIN orders o ON au.user_id = o.user_id
GROUP BY au.user_id, au.username;
```

**Upsert (INSERT ... ON CONFLICT):**
```sql
INSERT INTO users (user_id, username, email)
VALUES ($1, $2, $3)
ON CONFLICT (user_id) DO UPDATE
SET email = EXCLUDED.email, updated_at = NOW();
```

### 7. Performance Tips

- **VACUUM and ANALYZE:** Schedule regular maintenance to reclaim disk space and update query planner statistics.
- **Connection Pool Sizing:** Set connection pool size to 2–4 × number of CPU cores to avoid contention.
- **Slow Query Logs:** Enable `log_min_duration_statement` (e.g., 1000 ms) to capture slow queries for analysis.
- **Replication Lag Monitoring:** Monitor standby lag in streaming replication setups to ensure data freshness.

## Output Format

When generating SQL or migration scripts, provide:
1. A brief explanation of the logic and any optimization choices
2. The SQL code with comments for non-obvious sections
3. Any indexing or constraint recommendations
4. Testing guidance (e.g., expected row counts, query plan)

---

**Next Steps:** This scaffold will expand with advanced topics (partitioning, window functions, advanced replication, monitoring) in future iterations.
