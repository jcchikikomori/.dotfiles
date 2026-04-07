---
name: ruby
description: Ruby coding standards following RuboCop, guard clauses, TDD with RSpec, and OWASP security principles.
---

# Ruby Skill

## Style & Conventions

- Follow the **RuboCop Ruby Style Guide**: https://github.com/rubocop/ruby-style-guide
- Always follow the repository's existing **RuboCop config** — run `bundle exec rubocop` before finalizing changes.
- 2-space indentation.
- Single quotes for strings; double quotes only when interpolation or special chars are needed.
- Lambda syntax: `->` (stabby lambda).
- Add `# frozen_string_literal: true` at the top of every Ruby file **except** migrations, patches, and specs.
- **Avoid Feature Envy** — methods should use their own object's data, not excessively reach into other objects:

  ```ruby
  # Bad - Feature Envy
  def calculate_total
    order.items.sum { |item| item.price * item.quantity * item.discount }
  end

  # Good - move logic to where the data lives
  # In Order model:
  def calculate_total
    items.sum(&:line_total)
  end

  # In Item model:
  def line_total
    price * quantity * discount
  end
  ```

## Guard Clauses

Prefer guard clauses for early returns over nested conditionals:

```ruby
# Bad
def process(user)
  if user.active?
    if user.admin?
      # do thing
    end
  end
end

# Good
def process(user)
  return unless user.active?
  return unless user.admin?
  # do thing
end
```

## Design Patterns

- Apply SOLID principles; keep classes small and single-purpose.
- Use **service objects** in `app/services/` for complex business logic.
- Use **concerns** in `app/models/concerns/` and `app/controllers/concerns/` for shared behaviour.
- Use **value objects** for domain concepts with behaviour (e.g., Money, Address).
- Prefer composition over inheritance.

## Testing (RSpec + TDD)

- Prioritize **TDD**: write tests first. If not feasible, add tests immediately after.
- Follow RSpec best practices: http://www.betterspecs.org/
- All specs require `rails_helper` (or `spec_helper` for pure Ruby).
- Use `let` for test data instead of instance variables.
- Use `is_expected` over `should`.
- Use `ActiveSupport::TimeHelpers` for time stubbing (in `around` blocks).
- Expectations compared to **literal values**, not method calls:

  ```ruby
  # GOOD
  expect(foo.bar).to eq(1)

  # BAD
  expect(foo.bar).to eq(baz.spam)
  ```

- Every model and service class must have unit tests.
- Test unauthorized access paths (logged out, no permissions).
- Target **≥95% code coverage**.
- RSpec pattern:

  ```ruby
  # frozen_string_literal: true

  require 'rails_helper'

  RSpec.describe ModelName, type: :model do
    subject { build(:model_name) }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:attribute) }
    end

    describe '#method_name' do
      let(:instance) { create(:model_name) }

      it 'does something' do
        expect(instance.method_name).to eq(expected_value)
      end
    end
  end
  ```

- When `docker-compose.yml` or `compose.yml` exists, run tests and lint in Docker by default:

  ```bash
  docker compose run --rm -e RUBYOPT='-W0' <service> bundle exec rubocop <file>
  docker compose run --rm -e RUBYOPT='-W0' <service> bundle exec rspec <spec_path>
  ```

## Security (OWASP Top 10)

- Validate all user input; use Strong Parameters.
- Use parameterized queries — never interpolate user input into SQL strings.
- Use `SecureRandom` for tokens.
- Strip sensitive fields (passwords, tokens, PII) before logging.
- Apply OWASP thinking: secure weakest link, defence in depth, fail securely, least privilege, keep it simple.

## Database

- Avoid **N+1 queries** — use eager loading (`includes`, `preload`, `eager_load`).
- Add **indexes** for all columns referenced in queries.
- Use **soft delete** for deletions (never hard-delete user-facing records).
- Schema changes require team lead approval.

## Code Quality

- Run RuboCop in Docker by default when Compose is available:

  ```bash
  docker compose run --rm -e RUBYOPT='-W0' <service> bundle exec rubocop <file> --autocorrect
  ```
- Watch for common code smells: Long Method (>20 lines), Feature Envy, Primitive Obsession, `case` without `else`.
- `case` statements must have an `else` clause with an explicit error or default handler.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.
- Build must be green before merging.
