---
name: python
description: Python best practices following PEP 8, ruff, type hints, and lightweight design patterns for developers coming from PHP, Java, or Ruby.
---

# Python Skill

> Concepts are related to PHP, Java, and Ruby where helpful. Keep code simple and readable — follow the Zen of Python.

## Style & Conventions (PEP 8 + ruff)

- 4-space indentation (unlike Ruby's 2 spaces).
- Follow **PEP 8** strictly; enforce with **ruff** (`ruff check` + `ruff format`).
- Always follow the repository's existing `ruff` config — do not override rules project-wide.
- snake_case for functions/variables, PascalCase for classes, UPPER_SNAKE_CASE for constants.
- Use **type hints** for all function signatures and variable declarations (PHP-style: think typed properties).
- Use f-strings: `f"Hello, {name}"` (like Ruby's `"Hello, #{name}"`).
- `from __future__ import annotations` for forward references (Python < 3.10).

## Lightweight Design Patterns

- Keep design patterns lightweight; favor **small functions** over large classes.
- Reuse **predicates** (simple functions/lambdas) when applicable.
- Apply KISS & DRY, but prioritize consistency with existing code over strict adherence.
- Use `dataclasses` (or Pydantic models) for data-holding classes instead of verbose `__init__` boilerplate.
- Use **Dependency Injection** via constructor parameters (like Java Spring, but simpler).
- Use **context managers** (`with`) for resource management — equivalent to Ruby's `ensure` blocks.
- Use `Protocol` for structural subtyping (duck typing, like Ruby modules/mixins).

## Packages & Modules

- Follow standard Python packaging conventions: include `__init__.py` in every package directory.
- One concern per module; keep modules small.
- Use `pathlib.Path` instead of `os.path`.

## Error Handling

- Never use bare `except:` — always catch specific exception types (like Java's typed catch).
- Create custom exception classes for domain errors.
- Log exceptions with full tracebacks: `logger.exception(...)`.
- Use `contextlib.suppress` only when intentionally ignoring a specific, known exception.

## Async

- Use `asyncio` with `async/await` for I/O-bound work.
- Never put blocking calls inside async functions; use `asyncio.to_thread()` instead.

## Testing

- Use **pytest**; write tests for every change. Target **≥95% coverage**.
- Use `@pytest.fixture` for setup/teardown (like RSpec's `let` / `before`).
- Expectations must compare to **literal values**, not method calls:
  ```python
  # GOOD
  assert result.status_code == 200

  # BAD
  assert result.status_code == expected.code
  ```
- Use `pytest-mock` (`mocker`) for mocking external dependencies.
- Use `hypothesis` for property-based testing of complex logic.

## Security

- Validate all external input (use Pydantic or similar).
- Never `eval()` or `exec()` user input.
- Use `secrets` module for cryptographic randomness.
- Avoid `pickle` for untrusted data.
- Keep dependencies updated; audit with `pip-audit`.

## Tooling

- Use `uv` (preferred) or `poetry` for dependency management.
- Lint and format with **ruff** (replaces flake8 + isort + pyupgrade + Black).
- Type-check with **mypy** or **pyright** in strict mode.
- Use `pre-commit` hooks to enforce quality gates.

## FastAPI + SQLAlchemy (Quick Reference)

See the `fastapi`, `sqlalchemy`, and `pydantic` skills for full details. Short reminders:
- Provide short explanations when using these frameworks — relate to known PHP/Java/Ruby patterns.
- If models/schemas exist, **reuse them** — never create duplicates.
- Always read existing DB schema / migrations / models before writing new ones to avoid mismatches.
