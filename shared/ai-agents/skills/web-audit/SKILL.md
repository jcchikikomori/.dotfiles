---
name: web-audit
description: Audit web applications for browser compatibility and security vulnerabilities following OWASP API Security Top 10 guidelines.
---

# Web Compatibility & Security Audit Skill

**Roadmap Alignment:** [roadmap.sh/frontend](https://roadmap.sh/frontend) | [roadmap.sh/cyber-security](https://roadmap.sh/cyber-security)
**Security References:** [OWASP API Security Top 10](https://owasp.org/API-Security) | [OWASP GitHub](https://github.com/OWASP/API-Security)

## Core Standards (Effective Software Developer)

When auditing code for compatibility and security, act as a strict reviewer enforcing modern web standards and OWASP principles.

### 1. Browser Compatibility
- **HTML5:** Ensure semantic elements (`<article>`, `<nav>`, `<main>`) are used correctly. Be wary of cutting-edge elements like `<dialog>` without polyfills if legacy support is needed.
- **CSS:** Check support for modern features (Grid subgrid, `:has()`, container queries). Ensure fallbacks exist or autoprefixer is configured.
- **JavaScript:** Ensure modern syntax (Optional chaining, Nullish coalescing, Top-level await) aligns with the project's build target (Babel/SWC) or `browserslist`.

### 2. OWASP Security Audit
Whenever auditing, implicitly review against the latest [OWASP API Security Top 10](https://owasp.org/API-Security):
- **Input Validation:** Ensure ALL user input is sanitized before rendering or querying. 
- **XSS Prevention:** Reject any use of `dangerouslySetInnerHTML`, `v-html`, or `innerHTML` with unsanitized user data.
- **SQL Injection:** Verify that ONLY parameterized queries or secure ORM methods are used.
- **Authentication/Session:** Verify tokens are stored securely (HttpOnly cookies, not localStorage). Check for CSRF tokens on state-mutating requests.
- **Access Control:** Ensure proper authorization checks exist before returning sensitive data or performing actions.
- **Data Breaches:** Look for PII or sensitive info exposure in logs or unauthenticated endpoints.

### Output Format
When asked to perform a web audit, format your response as follows:

```markdown
## Compatibility & Security Audit

**File:** [File Path]

### Compatibility Status: [⚠️ Issues Found / ✅ Clean]
| Feature | Code | Support | Recommendation |
|---------|------|---------|---------------|
| [Feature] | `[snippet]` | [97%+] | [Recommendation] |

### Security Status: [🔴 Vulnerabilities Found / ✅ Clean]
| Issue | Line | Severity | Fix |
|-------|------|----------|-----|
| [XSS Risk] | [52] | [High] | [Use textContent / Sanitize] |

### Actionable Recommendations
1. [Specific code fix]
2. [Configuration fix]
```