---
name: nodejs
description: Node.js best practices, async patterns, error handling, security, and team coding conventions.
---

# Node.js Skill

## Project Setup & Standards

- Use **ES Modules** (`"type": "module"`) for new projects.
- Use **TypeScript** for all non-trivial projects; enable strict mode (`"strict": true`).
- Pin the Node.js version via `.nvmrc` or `.node-version`.
- Follow existing code style and conventions in the project — consistency over strict adherence.
- Apply KISS & DRY, but prioritize consistency with existing code.
- Use Airbnb or StandardJS style guide; enforce with ESLint + Prettier.

## Async & Concurrency

- Prefer `async/await` over raw Promise chains.
- Never mix callbacks and Promises in the same module.
- Handle unhandled rejections: `process.on('unhandledRejection', ...)`.
- Use `Promise.all()` / `Promise.allSettled()` for parallel async operations.
- Avoid blocking the event loop — offload CPU-heavy work to Worker Threads.

## Error Handling

- Always propagate errors upward; never swallow them silently.
- Use custom `Error` subclasses with `statusCode` and `isOperational` fields.
- Distinguish operational errors (user/network issues) from programmer errors (bugs).
- Use a global error handler in Express/Fastify.
- Return generic error messages to users; log full details server-side.
- Strip sensitive fields (passwords, tokens) from logs.

## Module & Code Structure

- Keep modules small and single-purpose.
- Avoid circular dependencies.
- Separate concerns: routes, controllers, services, repositories.
- Keep controllers thin — delegate business logic to service objects.

## Security (OWASP Top 10)

Apply OWASP thinking for all features:
- Never trust user input — validate with `zod`, `joi`, or similar.
- Use parameterized queries / ORM — **never concatenate user input into SQL**.
- Use `helmet` for secure HTTP headers.
- Use rate limiting middleware to prevent abuse.
- Never log sensitive data (passwords, tokens, PII).
- Keep dependencies updated; audit with `npm audit` or `pnpm audit`.
- Use env vars for secrets — never hardcode them in source.
- Cookies: `Secure`, `HttpOnly`, `SameSite=Lax`. Sessions timeout after a short period.
- Enforce HTTPS in production; set HSTS headers.

## Database

- Avoid **N+1 queries** — use eager loading or batch fetches.
- Add **indexes** for all columns referenced in queries.
- Use **soft delete** (`deletedAt`) — never hard-delete user-facing records.
- Schema changes require team lead approval.

## Testing

- Use **Vitest** (preferred) or **Jest** for unit/integration tests.
- Use **Supertest** for HTTP endpoint testing.
- Target **≥95% coverage** on business logic.
- Expectations compare to **literal values**, not method calls.
- Mock external I/O (DB, HTTP) in unit tests.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Tooling

- Use **pnpm** (preferred) or npm.
- Lint with ESLint (`@typescript-eslint`); format with Prettier.
- Use `tsx` or `ts-node` for TypeScript in development.
- Use `esbuild` or `tsup` for bundling.
