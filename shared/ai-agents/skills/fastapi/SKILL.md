---
name: fastapi
description: FastAPI framework patterns, dependency injection, routing, and integration with SQLAlchemy and Pydantic.
---

# FastAPI Skill

> Relate concepts to PHP (Laravel routes/controllers), Java (Spring Boot), or Ruby on Rails where helpful.

## Project Structure

```
app/
├── main.py              # App factory, router includes
├── api/
│   └── v1/
│       ├── routes/      # One file per resource (like Rails controllers)
│       └── deps.py      # Shared dependencies (DB session, current user)
├── models/              # SQLAlchemy ORM models (like ActiveRecord models)
├── schemas/             # Pydantic schemas (like Rails Strong Parameters + serializers)
├── services/            # Business logic (like Rails service objects)
└── core/
    ├── config.py        # Settings via pydantic-settings
    └── security.py      # Auth helpers
```

## Routing

- Define routers per resource: `router = APIRouter(prefix="/users", tags=["users"])`.
- Include routers in `main.py` with `app.include_router(...)`.
- Use path parameters: `@router.get("/{id}")`, query params: `def get(q: str | None = None)`.
- Group related endpoints with `APIRouter`; keep `main.py` thin (like Rails `routes.rb`).

## Request / Response Schemas (Pydantic)

- Use **separate schemas** for create, update, and response — never expose the ORM model directly.
- Name schemas clearly: `UserCreate`, `UserUpdate`, `UserResponse`.
- Use `response_model=UserResponse` on endpoints to filter output automatically.
- If schemas exist, **reuse them** — never invent new ones when they already exist.

## Dependency Injection

- Use `Depends()` for shared logic: DB sessions, auth, pagination.
- Define a `get_db()` generator that yields a SQLAlchemy session and closes it after the request.
  ```python
  def get_db() -> Generator:
      db = SessionLocal()
      try:
          yield db
      finally:
          db.close()
  ```
- Use `Security(get_current_user, scopes=["admin"])` for scoped auth.

## Authentication

- Use **OAuth2PasswordBearer** + JWT for token-based auth.
- Hash passwords with `passlib` (bcrypt).
- Never store plain-text passwords or tokens.
- Validate tokens and raise `HTTPException(status_code=401)` on failure.

## Error Handling

- Raise `HTTPException` with specific status codes and detail messages.
- Register global exception handlers with `@app.exception_handler(ExceptionType)`.
- Return minimal info to API consumers; log full details server-side.

## Async

- Use `async def` for endpoints that do I/O (DB, HTTP calls).
- Use `asyncio.to_thread()` for blocking operations inside async endpoints.
- Use async SQLAlchemy (`AsyncSession`) for non-blocking DB access.

## Testing

- Use **pytest** + `httpx.AsyncClient` (or `TestClient` for sync) to test endpoints.
- Use `pytest-asyncio` for async test functions.
- Override dependencies in tests via `app.dependency_overrides`.
- Use a separate test database; roll back transactions between tests.
- Target **≥95% coverage**; test all status codes (200, 400, 401, 403, 404, 422).

## Security (OWASP)

- Validate all input via Pydantic schemas — never trust raw request data.
- Use parameterized queries via SQLAlchemy ORM — never interpolate user input into SQL.
- Apply rate limiting (e.g., `slowapi`).
- Set CORS with `CORSMiddleware`; whitelist origins explicitly.
- Use HTTPS in production; set `secure` cookies.

## Tooling

- Run with **uvicorn** (dev: `--reload`; prod: multiple workers via **gunicorn**).
- Use **alembic** for DB migrations.
- Lint/format with **ruff**; type-check with **mypy** strict mode.
