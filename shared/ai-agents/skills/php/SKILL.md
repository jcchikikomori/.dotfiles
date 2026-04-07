---
name: php
description: PHP coding standards following PSR, strict types, OWASP security principles, and team coding conventions.
---

# PHP Skill

## Standards & Compliance

- Follow **PSR-1** (Basic Coding Standard): UTF-8, StudlyCaps for classes, camelCase for methods, UPPER_CASE for constants.
- Follow **PSR-12** (Extended Coding Style): 4-space indentation, LF line endings, blank lines after `namespace` and `use` blocks.
- Follow **PSR-4** (Autoloading): namespace-to-directory mapping, one class per file.
- Follow **PSR-7** / **PSR-15** for HTTP message and middleware interfaces.
- Follow **PSR-3** (Logger Interface) for logging.
- Declare strict types at the top of every file: `declare(strict_types=1);`

## Modern PHP (8.x)

- Use typed properties, union types (`string|int`), and named arguments (PHP 8.0+).
- Use `readonly` properties (PHP 8.1+) for value objects and DTOs.
- Use enums (PHP 8.1+) instead of class constants for finite sets of values.
- Use `match` expressions over `switch` where possible — always include a default arm.
- Use `null` coalescing (`??`) and nullsafe operator (`?->`) appropriately.
- Prefer `readonly` + immutable structures for data transfer objects.
- Use `from __future__ import annotations` equivalent: use constructor promotion for compact `__construct`.

## Code Style

- 4-space indentation.
- Follow existing code style and conventions in the project — consistency over strict adherence to new standards.
- Apply KISS & DRY, but prioritize consistency with existing code.
- Keep methods short and focused (Single Responsibility Principle; ideally ≤20 lines).

## Design Patterns

- Apply SOLID principles; keep classes small and single-purpose.
- Use **Dependency Injection** via constructor parameters — avoid global singletons.
- Use the **Repository pattern** to abstract data access.
- Use the **Factory pattern** (`@classmethod` / static factory methods) for complex object creation.
- Use **Service objects** for complex business logic — keep controllers thin.
- Prefer composition over inheritance.
- Avoid Feature Envy — methods should use their own object's data.

## Error Handling

- Catch specific exception types — never bare `catch (Exception $e)` unless re-throwing.
- Never swallow exceptions silently (empty catch blocks are forbidden).
- Use custom exception classes for domain errors.
- Return generic error messages to users; log full details to error tracking (Sentry, Rollbar).
- Strip sensitive fields (passwords, tokens) from logs.

## Security (OWASP Top 10)

Apply OWASP thinking for all features:
1. Secure the weakest link
2. Defence in depth
3. Fail securely
4. Least privilege
5. Compartmentalise
6. Keep it simple
7. Promote privacy
8. Hiding secrets is hard
9. Be reluctant to trust
10. Use community resources

- Always validate and sanitize user input — no input can be trusted (form data, files, params, cookies, headers).
- Use parameterized queries / prepared statements — **never interpolate user input into SQL**.
- Hash passwords with `password_hash()` / `password_verify()` (bcrypt, cost ≥12).
- Use `random_bytes()` / `random_int()` for cryptographic randomness — never `rand()`.
- Set security headers (CSP, X-Frame-Options, Strict-Transport-Security).
- Never expose stack traces or internal errors to end users in production.
- Cookies: `Secure`, `HttpOnly`, `SameSite=Lax`.
- Sessions: timeout after short idle period; regenerate session ID on login.

## Database

- Avoid **N+1 queries** — use eager loading or batch queries.
- Add **indexes** for all columns referenced in queries.
- Use **soft delete** (`deleted_at`) — never hard-delete user-facing records.
- Schema changes require team lead approval.

## Testing

- Write unit tests with PHPUnit; target **≥95% coverage** on business logic.
- Use data providers for parameterized tests.
- Mock external dependencies (DB, HTTP) with PHPUnit mocks or Mockery.
- Follow Arrange-Act-Assert (AAA) pattern.
- Expectations compare to **literal values**, not method calls.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Tooling

- Use PHPStan (level 8+) or Psalm for static analysis.
- Use PHP-CS-Fixer or PHP_CodeSniffer to enforce style.
- Use Composer for dependency management.
- Audit dependencies with `composer audit`.
