---
name: mysql-mariadb
description: MySQL and MariaDB coding standards, query optimization, indexing, migrations, and security best practices.
---

# MySQL / MariaDB Skill

## Query Standards

- Use **ANSI SQL join syntax** (`JOIN ... ON ...`) — never comma-separated joins in `FROM`.
- Always **alias tables**: `SELECT u.name FROM users AS u`.
- Use UPPER_CASE for SQL keywords; snake_case for identifiers.
- Use **prepared statements / parameterized queries** for all user-supplied values — **never concatenate strings into SQL**.
- Format complex queries with consistent indentation; each clause on its own line.

## Schema Design

- Use `INT UNSIGNED` for auto-increment primary keys; prefer `BIGINT UNSIGNED` for large tables.
- Use `AUTO_INCREMENT` for surrogate primary keys.
- Always define `NOT NULL` with a `DEFAULT` for mandatory columns.
- Use **soft delete**: add a `deleted_at DATETIME NULL DEFAULT NULL` column — never `DELETE` user-facing records.
- Use `DATETIME` for timestamps (timezone-aware at the application layer); use `TIMESTAMP` only for auto-managed `created_at`/`updated_at`.
- Use `utf8mb4` charset and `utf8mb4_unicode_ci` collation for full Unicode support (including emoji).
- Schema changes require team lead approval.

## Indexing

- Add **indexes** on all columns used in `WHERE`, `JOIN`, `ORDER BY`, and `GROUP BY`.
- Use **composite indexes** when filtering on multiple columns; order by selectivity (most selective first).
- Avoid indexing low-cardinality columns (e.g., boolean flags) in isolation.
- Use `EXPLAIN` to inspect query execution plans before deploying complex queries.
- Avoid full table scans on large tables.
- Use **covering indexes** (include all columns needed by a query) to avoid table lookups.

## Soft Delete Pattern

```sql
-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = ?;

-- Always filter in queries
SELECT * FROM users WHERE deleted_at IS NULL;
```

Always filter `WHERE deleted_at IS NULL` in application queries.

## Migrations

- Use your framework's migration tool (Rails `db:migrate`, Flyway, Liquibase, etc.).
- Never apply schema changes directly to production without a migration file.
- Make migrations reversible where possible (add rollback/`down` steps).
- Add indexes in the same migration that adds the column.
- Schema changes require team lead approval.

## Performance

- Avoid `SELECT *` — name the columns you need.
- Avoid functions on indexed columns in `WHERE` (prevents index use).
- Use `LIMIT` + `OFFSET` (or keyset pagination) for large result sets — never fetch all rows and filter in code.
- Use `EXISTS` instead of `IN` with large subqueries.
- Use `INSERT ... ON DUPLICATE KEY UPDATE` for upsert operations.
- Batch large `UPDATE`/`DELETE` operations to avoid long locks:
  ```sql
  DELETE FROM logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY) LIMIT 1000;
  ```
- Commit in batches for large DML to reduce lock contention.

## Transactions

- Wrap multi-statement DML in explicit transactions (`START TRANSACTION` / `COMMIT` / `ROLLBACK`).
- Keep transactions short to minimize lock duration.
- Use appropriate isolation level (`READ COMMITTED` is usually sufficient; avoid `SERIALIZABLE` unless required).

## Security

- Use prepared statements / parameterized queries everywhere — **SQL injection prevention**.
- Grant minimum necessary privileges (`SELECT`, `INSERT`, `UPDATE` on specific tables — never `SUPER` or `ALL PRIVILEGES` to app users).
- Never store plain-text passwords; hash with bcrypt (application layer) or use `SHA2` only as a last resort.
- Disable remote root login; use dedicated app DB users.
- Enable `require_secure_transport` (TLS) for remote connections in production.
- Audit sensitive table access where required.
- Strip sensitive data from logs and error messages.

## Naming Conventions

| Object | Convention | Example |
|---|---|---|
| Table | snake_case, plural | `user_accounts` |
| Column | snake_case | `created_at` |
| Index | `idx_<table>_<columns>` | `idx_users_email` |
| Foreign key | `fk_<table>_<ref_table>` | `fk_posts_users` |
| Stored Procedure | `sp_<verb>_<noun>` | `sp_create_user` |
| Trigger | `trg_<table>_<event>` | `trg_users_before_insert` |

## MariaDB-Specific Notes

- MariaDB is API-compatible with MySQL; most patterns apply equally.
- MariaDB supports `FOR UPDATE SKIP LOCKED` (10.6+) for queue-style processing.
- Use `SEQUENCE` objects (MariaDB 10.3+) as an alternative to `AUTO_INCREMENT` for non-PK sequences.
- MariaDB's `JSON` support differs slightly from MySQL 8.x — test JSON functions if migrating.
