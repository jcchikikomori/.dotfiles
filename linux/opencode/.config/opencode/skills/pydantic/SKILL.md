---
name: pydantic
description: Pydantic v2 usage for data validation, settings management, and schema design in Python projects.
---

# Pydantic Skill

> Think of Pydantic models as PHP type-hinted DTOs, Java POJOs with validation, or Rails Strong Parameters + serializers — but with automatic type coercion and validation built in.

## Core Concepts

- `BaseModel` is the foundation — define fields as class attributes with type hints.
- Pydantic validates and coerces data at instantiation time; invalid data raises `ValidationError`.
- **v2 is the current standard** — avoid v1 patterns (`validator`, `orm_mode`) in new code.

## Defining Models

```python
from pydantic import BaseModel, Field
from datetime import datetime

class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: str  # Pydantic validates email format if you use EmailStr
    age: int = Field(..., ge=0, lt=150)

class UserResponse(BaseModel):
    id: int
    name: str
    created_at: datetime

    model_config = {"from_attributes": True}  # Replaces orm_mode = True (v1)
```

## Key Rules

- Use **separate schemas** for create, update, and response — never reuse a single model for all operations.
- Fields with `Optional[X]` or `X | None` must have a default of `None`: `field: str | None = None`.
- Use `Field(...)` for required fields with validation constraints.
- Use `model_config = {"from_attributes": True}` when reading from ORM objects (replaces `orm_mode`).
- If models/schemas already exist, **reuse them** — never create duplicates.

## Validators (v2 Style)

```python
from pydantic import field_validator, model_validator

class UserCreate(BaseModel):
    name: str

    @field_validator("name")
    @classmethod
    def name_must_not_be_blank(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Name must not be blank")
        return v.strip()
```

- Use `@field_validator` for single-field validation (replaces v1 `@validator`).
- Use `@model_validator(mode="after")` for cross-field validation.

## Settings Management

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str
    debug: bool = False

    model_config = {"env_file": ".env"}

settings = Settings()
```

- Use `pydantic-settings` (`BaseSettings`) for app configuration — reads from env vars and `.env` files automatically.
- Never hardcode secrets; always use `Settings` with env vars.

## Serialization

```python
user = UserResponse.model_validate(orm_user)   # From ORM object (replaces from_orm)
data = user.model_dump()                        # To dict (replaces .dict())
json_str = user.model_dump_json()               # To JSON string (replaces .json())
```

## Common Patterns

- Use `Annotated[str, Field(...)]` for reusable constrained types.
- Use `model_rebuild()` for forward references in recursive models.
- Use `RootModel` for models that wrap a single value (like a list or dict).

## Testing

- Test validation errors explicitly:
  ```python
  from pydantic import ValidationError

  def test_invalid_email():
      with pytest.raises(ValidationError):
          UserCreate(name="Alice", email="not-an-email", age=25)
  ```
- Test that serialization produces the correct literal values (not method calls).
- Target **≥95% coverage** on schema-related logic.
