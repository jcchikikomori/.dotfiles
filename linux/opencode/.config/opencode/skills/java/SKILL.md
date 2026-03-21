---
name: java
description: Java coding standards, design patterns, modern Java features, OWASP security, and team conventions.
---

# Java Skill

## Standards & Style

- Follow Oracle's Java Code Conventions and Google Java Style Guide.
- 4-space indentation; K&R brace style.
- Class names: `UpperCamelCase`. Method/variable names: `lowerCamelCase`. Constants: `UPPER_SNAKE_CASE`. Packages: `lowercase.dot.separated`.
- One top-level class per file; file name must match the public class name.
- Keep lines ≤ 120 characters.
- Follow existing code style and conventions in the project — consistency over strict adherence to new standards.
- Apply KISS & DRY, but prioritize consistency with existing code.

## Modern Java (11+)

- Use `var` for local variables where the type is obvious (Java 10+).
- Use `record` types for immutable data carriers (Java 16+).
- Use `sealed` classes and pattern matching with `instanceof` (Java 17+).
- Use text blocks (`"""..."""`) for multi-line strings (Java 15+).
- Prefer `Optional<T>` over returning `null` from methods.
- Use `Stream` API and method references for functional-style operations.
- Prefer immutable collections: `List.of()`, `Map.of()`, `Set.of()`.

## Design Patterns & Architecture

- Apply SOLID principles; keep classes small and single-purpose (≤20 meaningful methods).
- Prefer composition over inheritance.
- Use the Builder pattern for objects with many optional parameters.
- Use Factory / Abstract Factory for object creation.
- Use the Strategy pattern to swap algorithms at runtime.
- Use **Dependency Injection** (Spring, Guice, or constructor injection) — avoid global singletons.
- Use **Service objects** for business logic — keep controllers thin.
- Avoid Feature Envy — methods should use their own object's data.

## Error Handling

- Catch specific exceptions — never bare `catch (Exception e)` unless re-throwing.
- Never swallow exceptions silently (empty catch blocks are forbidden).
- Always clean up resources with try-with-resources.
- Use checked exceptions for recoverable conditions; unchecked for programming errors.
- Return generic error messages to users; log full details to error tracking.
- Strip sensitive fields (passwords, tokens) from logs.

## Security (OWASP Top 10)

- Use parameterized queries / prepared statements — **never concatenate user input into SQL**.
- Validate and sanitize all user input — no input can be trusted.
- Hash passwords with bcrypt (cost ≥12) — never plain-text or MD5/SHA1.
- Use `SecureRandom` for cryptographic randomness — never `Math.random()`.
- Set security headers (CSP, HSTS, X-Frame-Options) in production.
- Never expose stack traces to end users in production responses.
- Cookies: `Secure`, `HttpOnly`, `SameSite=Lax`. Sessions timeout after a short period.

## Database

- Avoid **N+1 queries** — use JOIN, batch fetch, or `@BatchSize` (JPA).
- Add **indexes** for all columns referenced in queries.
- Use **soft delete** (`deletedAt` field) — never hard-delete user-facing records.
- Schema changes require team lead approval.

## Concurrency

- Prefer `java.util.concurrent` utilities over raw `synchronized` blocks.
- Use `CompletableFuture` for async pipelines.
- Use `ExecutorService` rather than creating raw `Thread` objects.
- Prefer immutable objects to avoid race conditions.
- Mark shared mutable state with `volatile` or use `AtomicXxx` classes.

## Testing

- Use JUnit 5 (`@Test`, `@ParameterizedTest`, `@BeforeEach`, etc.).
- Mock dependencies with Mockito.
- Assert with AssertJ for fluent, readable assertions.
- Expectations compare to **literal values**, not method calls.
- Target **≥95% coverage** on business logic.
- Build must be green before merging.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.

## Build & Tooling

- Use Maven or Gradle (prefer Gradle with Kotlin DSL for new projects).
- Enforce code style with Checkstyle or Spotless.
- Use SpotBugs / ErrorProne for static analysis.
- Audit dependencies for vulnerabilities in CI.
