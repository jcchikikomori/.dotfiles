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
