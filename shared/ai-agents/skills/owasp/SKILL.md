---
name: owasp
description: OWASP Top 10 security principles, input handling, auth, output encoding, and secure coding checklist.
---

# OWASP Security Skill

Apply OWASP thinking for **all features**, especially input handling, authentication, and data access.

## 10 Core Security Principles

1. **Secure the weakest link** — identify and harden the most vulnerable component first.
2. **Defence in depth** — layer multiple security controls; never rely on a single barrier.
3. **Fail securely** — on error, default to denying access, not granting it.
4. **Least privilege** — grant only the minimum permissions necessary; deny by default.
5. **Compartmentalise** — isolate components so a breach in one doesn't compromise all.
6. **Keep it simple** — complex security is hard to audit and easy to break.
7. **Promote privacy** — collect only necessary data; protect it at every layer.
8. **Hiding secrets is hard** — assume secrets in code will leak; use env vars and secret managers.
9. **Be reluctant to trust** — verify inputs, identities, and systems; trust nothing by default.
10. **Use community resources** — prefer well-tested libraries over custom implementations.

## Input Handling

- **No input can be trusted**: form data, files, params, cookies, headers, query strings — all are untrusted.
- Use Strong Parameters / allowlists to whitelist attributes (Rails, Laravel, etc.).
- Validate at **both** application and database layers.
- File uploads: whitelist content types, enforce size limits, store outside the web root.
- Sanitize before displaying user-controlled content in HTML, SQL, shell, XML, or JSON contexts.

## Output & Encoding

- Use your framework's default HTML escaping to prevent **XSS**.
- Use parameterized queries / prepared statements to prevent **SQL injection** — never interpolate user input into SQL strings.
- Encode output for the correct context (HTML, JavaScript, URL, CSS).

## Authentication & Sessions

- Use established auth libraries (Devise for Rails, Passport for Node, etc.) — never roll your own.
- Hash passwords with bcrypt (minimum cost factor 12) + unique salts.
- Sessions: timeout after a short idle period; regenerate session ID on login.
- Cookies: `Secure`, `HttpOnly`, `SameSite=Lax` (or `Strict`), encrypted/signed.
- CSRF: use your framework's built-in CSRF protection — never disable it.
- Implement account lockout / rate limiting on login endpoints.

## Authorization

- **Deny by default** — every request requiring auth must be explicitly authorized.
- Apply least necessary privilege per user/role.
- Validate authorization on every request (not just at login).
- Use RBAC (Role-Based Access Control) — cancancan (Rails), Pundit, etc.

## Error Handling & Logging

- Return **generic error messages** to users — never expose stack traces, internal paths, or DB errors.
- Log detailed errors to a server-side error tracking service (Sentry, Rollbar, etc.).
- Strip sensitive fields (passwords, tokens, PII, credit card numbers) from logs before sending.
- Use structured logging; do not log request bodies unless you have scrubbed them.

## Sensitive Data

- Use TLS/HTTPS everywhere; enforce HSTS (`Strict-Transport-Security`).
- Encrypt sensitive fields at rest (e.g., using `attr_encrypted` in Rails).
- Use a secrets manager (Vault, AWS Secrets Manager, env vars) — never hardcode secrets in source code.
- Use `secrets` / `SecureRandom` / `crypto.randomBytes()` for cryptographic randomness — never `Math.random()`.
- Avoid `pickle` (Python), `eval()`, `exec()`, or `YAML.load` with untrusted data.

## Dependencies & Supply Chain

- Keep dependencies updated; audit regularly (`pip-audit`, `npm audit`, `bundle audit`).
- Prefer well-maintained, widely-used libraries.
- Pin dependency versions in production; use a lockfile.
- Review new dependencies before adding them (discuss with team).

## SAST / Code Review Security Checklist

Before merging, verify:
- [ ] No SQL injection vectors (parameterized queries used everywhere).
- [ ] No XSS vectors (output encoded; no raw `html_safe` / `innerHTML` with user data).
- [ ] No hardcoded secrets, API keys, or passwords.
- [ ] No insecure deserialization (`pickle`, `eval`, unsafe YAML).
- [ ] Authorization checks present on all sensitive endpoints.
- [ ] Error messages are generic (no stack traces exposed to users).
- [ ] Sensitive fields stripped from logs.
- [ ] File uploads validated for type and size.
- [ ] CSRF protection enabled.
- [ ] Rate limiting applied to auth endpoints.

**Any code that introduces security flaws will not be approved for merge.**
