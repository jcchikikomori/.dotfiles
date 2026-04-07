---
name: fullstack
description: Full-stack development combining frontend and backend. Covers data fetching, authentication, monorepo patterns, DevOps awareness, and end-to-end security.
---

# Full Stack Developer Skill

**Roadmap Alignment:** [roadmap.sh/full-stack](https://roadmap.sh/full-stack) | [roadmap.sh/frontend](https://roadmap.sh/frontend) | [roadmap.sh/backend](https://roadmap.sh/backend)

## Core Standards (Effective Software Developer)
When executing full-stack tasks, ensure your work adheres to the latest industry standards and roadmap milestones:

### 1. Integration (Client & Server)
- **Data Fetching Strategy:**
  - Utilize React Query, SWR, or Apollo Client for seamless synchronization of server state to the UI.
  - Implement Optimistic UI updates for a snappy user experience.
- **Data Hydration:** If using SSR/SSG (Next.js, Nuxt), ensure components properly hydrate without mismatches.
- **CORS Handling:** Correctly configure Cross-Origin Resource Sharing on the backend, allowing only specific frontend domains.

### 2. Architecture & Design Patterns
- **Monorepo / Turborepo:** When working in a full-stack monorepo, utilize shared packages (like `types/` or `utils/`) effectively to maintain DRY principles between frontend and backend.
- **REST / GraphQL:** Choose the right API pattern based on the project's data requirements. (See backend skill).
- **Separation of Concerns:** Keep business logic on the server. The frontend should only be responsible for presentation, user input validation, and managing view state.

### 3. Application Security (OWASP Top 10)
- **Authentication Flow:**
  - Implement secure session management (e.g., HTTPOnly, Secure cookies for JWTs/Session IDs) rather than storing tokens in `localStorage`.
  - Handle OAuth2 or OIDC flows correctly (e.g., NextAuth, Passport).
- **Validation (End-to-End):**
  - **Frontend:** Validate forms (Zod, Yup) to provide immediate user feedback.
  - **Backend:** NEVER trust the client. Re-validate all incoming data strictly.
- **Protection:** Prevent XSS by sanitizing rich text inputs (DOMPurify). Prevent CSRF by using anti-CSRF tokens or SameSite cookies.

### 4. Database & ORM
- **Migrations:** Always manage database schemas via code migrations (Prisma, TypeORM, Alembic, ActiveRecord).
- **Optimization:** Identify N+1 query problems in GraphQL or complex REST endpoints. Use DataLoaders or Eager Loading.

### 5. DevOps & Deployment (Awareness)
- **CI/CD:** Understand basic GitHub Actions/GitLab CI pipelines for running linters and tests before merging.
- **Environment Parity:** Ensure development, staging, and production environments match as closely as possible using Docker or consistent `.env` configurations.
- **Monitoring & Logging:** Log critical application errors and performance bottlenecks (e.g., Sentry, Datadog) without exposing PII or credentials.