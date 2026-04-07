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

## Git Rules

- Load the `git` skill for all Git operations: `skill(name="git")`
- Never run specific git commands such as `commit` and `push` which is considered as the RED FLAG.
