---
name: backend
description: Backend development best practices covering APIs, database design, security, architecture, and performance optimization for Python, Node.js, Ruby, and other server-side frameworks.
---

# Backend Developer Skill

**Roadmap Alignment:** [roadmap.sh/backend](https://roadmap.sh/backend) | [roadmap.sh/python](https://roadmap.sh/python) | [roadmap.sh/nodejs](https://roadmap.sh/nodejs) | [roadmap.sh/ruby](https://roadmap.sh/ruby)

## Core Standards (Effective Software Developer)
When executing backend tasks, ensure your work adheres to the latest industry standards and roadmap milestones:

### 1. APIs (RESTful / GraphQL)
- **REST Best Practices:**
  - Pluralize resources (`/users`, not `/user`).
  - Use appropriate HTTP verbs (GET, POST, PUT, PATCH, DELETE).
  - Return standard HTTP status codes (200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Server Error).
  - Include pagination, filtering, and sorting out of the box for collection endpoints.
- **GraphQL Best Practices:**
  - Define clear mutations and queries.
  - Solve N+1 queries using DataLoaders or Eager Loading on the database side.

### 2. Database (Relational & NoSQL)
- **Relational Databases (PostgreSQL / MySQL):**
  - **Schema Design:** Use foreign keys, appropriate data types, and normalize up to 3NF unless denormalization is strictly needed for performance.
  - **Indexing:** Always index foreign keys and columns used frequently in `WHERE` and `ORDER BY` clauses.
  - **Query Optimization:** Avoid `SELECT *`. Use parameterized queries exclusively to prevent SQL injection.
- **Transactions:** Wrap multi-step mutations in database transactions ensuring ACID properties.
- **Migrations:** Always use a migration tool (Alembic, Rails ActiveRecord, Prisma, TypeORM). Never apply schema changes manually.

### 3. Application Security (OWASP Top 10)
- **Authentication & Authorization:**
  - Never store plain text passwords. Always use strong, salted hashes (Argon2, bcrypt).
  - Validate JWT signatures, expiration, and issuer.
  - Apply Role-Based Access Control (RBAC) at the route/controller level.
- **Data Validation:** 
  - Strictly validate and sanitize ALL incoming data (query parameters, JSON bodies, headers). Use validation libraries (Zod, Pydantic, Joi).
  - Defend against CSRF and XSS.
- **Rate Limiting:** Protect endpoints against brute force and DDoS attacks.

### 4. Architecture & Error Handling
- **Separation of Concerns:** Keep controllers thin. Move business logic to service layers, and data access to repository/model layers (MVC/Layered architecture).
- **Graceful Error Handling:** Implement a global error handler. Log errors with stack traces (excluding PII/credentials), but return clean, standardized JSON error messages to the client.
- **Environment Configuration:** Use `.env` files for secrets. Never hardcode API keys, DB credentials, or environment-specific toggles in code.

### 5. Performance & Scalability
- **Caching:** Identify slow queries and implement caching (Redis, Memcached) where data is frequently read but rarely updated.
- **Asynchronous Processing:** Offload heavy tasks (email sending, image processing, reporting) to background workers (Celery, Sidekiq, BullMQ) via message queues (RabbitMQ, Redis).