# Global Agent Instructions

These rules apply across all AI coding agent sessions on this machine.

## Output Style (Mandatory)

- Keep completion messages short and direct.
- After actions, report only a concise status and changed files.
- Do **not** create auto-summary markdown files (e.g., implementation summaries, architecture reports, checklists) unless the user explicitly requests documentation output.

## Docker-First Execution Policy (Mandatory)

For projects with `docker-compose.yml` or `compose.yml`, run **linting, tests, and framework commands in Docker by default**.

- Prefer `docker compose run --rm <service> <command>` over host-local commands.
- Only use host-local execution when Docker is unavailable or the user explicitly requests local execution.

## Docker Compose Commands

- In ruby-based projects with Docker compose in it, run commands using:

```bash
docker compose run --rm -e RUBYOPT='-W0' <container_name> <command>
```

- Otherwise, use:

```bash
docker compose run --rm <container_name> <command>
```

## Skill Auto-Loading (Mandatory)

Always invoke the relevant skill(s) before starting any task. Detect project type from files present in the working directory.

### By Technology

| Detected | Skills to Load |
|----------|----------------|
| `Gemfile` / Rails | `skill(name="ruby")` + `skill(name="ruby-on-rails")` |
| `package.json` + React | `skill(name="nodejs")` + `skill(name="reactjs")` |
| `package.json` + Vue | `skill(name="nodejs")` + `skill(name="vuejs")` |
| `package.json` + Angular | `skill(name="nodejs")` + `skill(name="angularjs")` |
| `pyproject.toml` / FastAPI | `skill(name="python")` + `skill(name="fastapi")` |
| `pom.xml` / Spring Boot | `skill(name="java")` + `skill(name="spring-boot")` |
| `build.gradle` / Grails | `skill(name="java")` + `skill(name="grails")` |
| `composer.json` | `skill(name="php")` |
| `AndroidManifest.xml` | `skill(name="android")` |
| Any SQL work | relevant SQL skill first (`postgresql`, `mysql-mariadb`, or `oracle-sql`) |
| Security audit requested | `skill(name="owasp")` first |

### By Task Type

| Task | Skill to Load |
|------|---------------|
| Git operations | `skill(name="git")` |
| Docker / Kubernetes | `skill(name="docker")` or `skill(name="kubernetes")` |
| Debugging / bug investigation | `skill(name="debug")` |
| MCP configuration | `skill(name="mcp")` |
| New component or module documentation | `skill(name="component-doc")` |
| Project onboarding / structure explanation | `skill(name="project-onboarding")` |
| Rails DB migrations | `skill(name="rails-migration")` |
| Python data models / validation | `skill(name="pydantic")` |
| SQLAlchemy ORM work | `skill(name="sqlalchemy")` |

### Invoking Skills via Command

Users can invoke skills directly with `/skill-name` (e.g., `/git`, `/docker`, `/debug`).

## Git Rules (Mandatory)

- Load the `git` skill for all operations that involves using Git: `skill(name="git")`
- Never run specific git commands such as `commit` and `push` which is considered as the RED FLAG.
- For revert/undo, use `git blame` to identify changes and reduce mistakes.
- Do not change the existing values on repository's config (`git config --local`) unless you have been asked to.
- Use `git stash` or `git checkout <different-branch>` to archive the existing/untrackes changes, before writing/editing the changes.
- Fetch the current repository first before doing any changes. If there's a ongoing change from upstream or main development branch, ask if you needed to merge/rebase.
- For comparing changes, use `git diff` or `diff` commands.

## Code Style (Mandatory)

- Keep code formatted.
- Use spaces as indentation (2 spaces for Ruby, 4 spaces for Python).
- Follow existing code style and conventions in the project.
- For new code, follow the style of the most similar existing code, and reuse existing patterns and structures when possible.
- Apply principles such as KISS & DRY, but prioritize consistency with existing code over strict adherence to these principles.

## Code Testing

- Any change must include tests.
- Any UI change particularly for web, should use web browser (either existing automated tools or DevTools MCP) for validating tests.
- Target code coverage ≥95%.
- Prioritize positive & negative test cases.

## Pull Request Standards

- **PR size ≤ 200 lines** (unless no reasonable simplification possible).
- **Limited scope:** Only changes for the ticket/story (no unrelated refactoring).
- **Short description** or dot points explaining the changes.

## Database Practices (Mandatory)

- Avoid **N+1 queries**.
- AVOID DROPPING or RESETTING the LOCAL DATABASE unless user told you so.
- Add **indexes** for columns referenced in queries.
- Use **soft delete** for deletions.

## Error Handling (Mandatory)

- Minimal info to users (generic messages).
- Detailed logs to error tracking service.
- Strip sensitive fields (passwords, tokens) from logs.
