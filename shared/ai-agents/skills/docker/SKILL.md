---
name: docker
description: Docker and Docker Compose best practices, multi-stage builds, container security, and performance optimization.
---

# Docker & Containerization Skill

**Roadmap Alignment:** [roadmap.sh/docker](https://roadmap.sh/docker)
**Reference:** [Docker Documentation](https://docs.docker.com/)

## Core Standards (Effective Software Developer)
When writing or reviewing Dockerfiles and `docker-compose.yml` configurations, ensure they adhere to modern containerization best practices.

### 1. Dockerfile Best Practices
- **Base Images:** Always use official, minimal base images (e.g., `alpine`, `slim`, or `distroless`) to reduce attack surface and download size. Pin specific versions (e.g., `node:18-alpine` instead of `node:latest`).
- **Multi-Stage Builds:** Use multi-stage builds to separate build dependencies from runtime execution. Never ship source code, compilers, or test dependencies in a production image.
- **Layer Caching:** Order commands from least likely to change to most likely to change. Copy dependency files (like `package.json` or `Gemfile`) and install dependencies *before* copying the rest of the source code.
- **Non-Root User:** Never run containers as the `root` user in production. Always create a dedicated user and switch to it using the `USER` instruction.
- **Environment Variables:** Use `ENV` to set defaults, but prefer passing secrets at runtime. Avoid hardcoding credentials in the Dockerfile.
- **Graceful Shutdown:** Handle `SIGTERM` properly. Use `CMD ["executable", "param1"]` (exec form) rather than `CMD command param1` (shell form) so the process receives signals correctly.

### 2. Docker Compose Standards
- **Version:** Omit the `version` field in modern Docker Compose (Compose V2+ ignores it).
- **Service Naming:** Keep service names short and logical (e.g., `api`, `db`, `redis`, `web`).
- **Networking:** Define custom networks rather than relying solely on the `default` network, especially for isolating backend databases from public-facing services.
- **Volumes:** Use named volumes for persistent data (e.g., database storage) to prevent data loss when containers are recreated.
- **Healthchecks:** Implement `healthcheck` blocks for services (like databases) to ensure dependent services wait for them to be truly ready (using `depends_on: ... condition: service_healthy`).
- **Environment Files:** Use `env_file: .env` to inject configurations rather than placing them directly in the `docker-compose.yml`.

### 3. Container Security (OWASP)
- **Secrets Management:** Never use build arguments (`ARG`) or environment variables (`ENV`) for sensitive data during build time. Use Docker BuildKit's `--secret` mounts.
- **Read-Only Filesystem:** Where possible, run containers with a read-only root filesystem (`read_only: true` in Compose) and mount a temporary `tmpfs` volume for necessary writable directories.
- **Scan for Vulnerabilities:** Encourage the use of `docker scout` or `trivy` to scan images for CVEs before deployment.

### Output Format
When generating a Dockerfile or Compose file, provide a brief explanation of the optimizations you made (e.g., "I implemented a multi-stage build to reduce the final image size and added a non-root user for security").