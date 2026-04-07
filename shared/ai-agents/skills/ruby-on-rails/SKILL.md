---
name: ruby-on-rails
description: Ruby on Rails development for both legacy (4.x-6.x) and modern (7.x-8.x) apps, including Docker, RSpec, migrations, and security.
---

# Ruby on Rails Skill

## Context Detection

**Existing (legacy) projects:**
- Detect Rails/Ruby version from `Gemfile`, `Gemfile.lock`, or `.ruby-version`.
- Follow existing patterns and conventions in the codebase.
- Never suggest upgrading unless explicitly asked.
- Respect deprecated APIs that still work in the target version.

**New projects:**
- Use latest stable Ruby (3.3.x) and Rails (7.2.x or 8.x if stable).
- Default scaffold command:
  ```bash
  rails new <app_name> --database=<db_engine> \
    --skip-action-mailbox --skip-action-text --skip-active-storage \
    --skip-action-cable --skip-test --skip-system-test
  ```
- Add RSpec separately: `rails generate rspec:install`.
- Ask for requirements before deviating from the default command.

## Docker Commands (Default Dev Environment)

When `docker-compose.yml` or `compose.yml` exists, Docker is the default runtime for linting, tests, and Rails commands.

```bash
# Run any command
docker compose run --rm -e RUBYOPT='-W0' <container_name> <command>

# Common commands
docker compose run --rm -e RUBYOPT='-W0' <container_name> rails c
docker compose run --rm -e RUBYOPT='-W0' <container_name> rails db:migrate
docker compose run --rm -e RUBYOPT='-W0' <container_name> rspec <spec_path>
docker compose run --rm -e RUBYOPT='-W0' <container_name> rails g <generator> <args>
docker compose run --rm -e RUBYOPT='-W0' <container_name> bundle exec rubocop <file> --autocorrect
```

## Code Style

- 2-space indentation; single quotes unless interpolation needed.
- `# frozen_string_literal: true` at top of all Ruby files (except migrations, patches, specs).
- Guard clauses for early returns — avoid nested conditionals.
- Stabby lambda syntax (`->`).
- Avoid **Feature Envy** — methods use their own object's data.
- `case` statements must have an `else` clause.

## Architecture

- Keep controllers thin: delegate business logic to service objects.
- Service objects in `app/services/`; concerns in `app/models/concerns/` and `app/controllers/concerns/`.
- When creating a new component, use existing components as reference — never invent new structures when they exist.

## Legacy Rails Patterns

### Rails 5.x
- `ApplicationRecord` base class for models.
- `belongs_to` required by default (use `optional: true` if needed).
- Strong parameters in controllers.

### Rails 4.x
- No `ApplicationRecord` — use `ActiveRecord::Base` directly.
- `attr_accessible` for mass assignment protection.
- `before_filter` instead of `before_action`.

## Testing (RSpec)

### RSpec Execution Mode (Docker)

Choose sync vs. async based on test scope when running inside Docker:

| Scope | Mode | Example |
|---|---|---|
| Full app or broad suite (`spec/`, `spec/models/`, `spec/controllers/`, etc.) | **Background / async** | `docker compose run --rm -e RUBYOPT='-W0' <service> bundle exec rspec spec/` |
| Single file or focused component | **Synchronous** | `docker compose run --rm -e RUBYOPT='-W0' <service> bundle exec rspec spec/models/user_spec.rb` |

**Decision rule:** No path or multi-directory path → background/async. Single file or single tightly-scoped directory → synchronous.

- Prioritize TDD; if not feasible, add tests immediately after implementation.
- All specs require `rails_helper`.
- Use `let` instead of instance variables; use `is_expected` over `should`.
- Expectations compared to **literal values**, not method calls.
- Controller specs must include `render_views`.
- Test every controller action including unauthenticated and unauthorized paths.
- Use `ActiveSupport::TimeHelpers` for time stubbing (in `around` blocks).
- Target **≥95% code coverage**.

### RSpec Patterns

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

### Controller JSON Testing (Rails 5.x)

```ruby
describe '#action' do
  it 'returns expected JSON' do
    get :action, params: { id: record.id }, format: :json

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json['key']).to eq(expected_value)
  end
end
```

### FactoryBot

```ruby
# frozen_string_literal: true

FactoryBot.define do
  factory :model_name do
    attribute { Faker::Lorem.word }
    association :related_model
  end
end
```

## Migrations

**Priority:** `change` > `up/down` > never `self.up/self.down`.

```ruby
# Preferred
def change
  add_column :table_name, :column_name, :string, null: false, default: ''
end

# Non-reversible
def up
  change_column :table_name, :column_name, :text
end

def down
  change_column :table_name, :column_name, :string
end
```

- Schema changes require team lead approval.
- Add indexes on all columns referenced in queries.
- Use soft delete (`deleted_at`) — never hard-delete user-facing records.

## Data Patches

```ruby
class PatchName < Patch
  def run
    start
    perform
    stop
  end

  private

  def perform
    # Data manipulation logic
  end
end
```

## Security (OWASP Top 10)

- Use **Strong Parameters** to whitelist attributes.
- Use **Devise** for authentication; **cancancan** for RBAC (deny by default).
- Cookies: encrypted, signed, secure, http-only. Sessions timeout after short period.
- Never disable `protect_from_forgery`.
- Use Rails' default HTML escaping; never use `html_safe` unless absolutely necessary.
- Enable HSTS: `config.force_ssl = true` in production.
- Use `attr_encrypted` for field-level encryption (e.g., bank account numbers).
- Strip sensitive fields (passwords, tokens, PII) before logging.
- Use `SecureRandom` for tokens.

## Database

- Avoid **N+1 queries** (`includes`, `preload`, `eager_load`).
- Add **indexes** for all query-referenced columns.
- Use **soft delete** for all user-facing deletions.

## View Patterns

- No inline JavaScript in views — use external JS files in `app/assets/javascripts`.
- No business logic in views — move to helpers, decorators, or presenters.
- Use helpers to keep views clean and declarative.

## JavaScript (Legacy Apps)

- Assume plain JS with jQuery unless Webpacker/modern setup is confirmed.
- `$(document).on('ready', function() { ... })` for DOM ready.
- Prefer `const` for constants, `let` for locals; avoid `var`.
- Minimum ES6 compatibility unless newer syntax is already used in the codebase.

## PR Standards

- PR size ≤ **200 lines** unless no reasonable simplification is possible.
- Limited scope: only changes for the ticket/story.
- Link to ticket in PR description.
- Schema changes and patches: approved by team lead.
- Build must be green before merging.

## Debugging Workflow

1. Check logs: `docker compose logs -f <container_name>`
2. Rails console: test queries interactively.
3. Insert `byebug` or `binding.pry` for breakpoints.
4. Write a failing RSpec test, then fix.
5. Test raw SQL via `ActiveRecord::Base.connection.execute` if needed.

## Manual Browser Testing (Test Data Scripts)

For complex UI flows, create **test data scripts** in `.local/`, `tmp/scripts/`, or another ignored path:

```ruby
# frozen_string_literal: true

# DO NOT MERGE THIS FILE
# Purpose: Manual browser testing for [Feature Name]
# Run: docker compose run --rm -e RUBYOPT='-W0' app rails runner .local/script_name.rb

# CLEANUP
puts '=== Cleaning up existing test data ==='
ChildModel.where(parent_id: parent_ids).destroy_all
ParentModel.where(code: test_codes).destroy_all

# CREATE
puts '=== Creating test data ==='
items.each_with_index do |item, index|
  unique_id = 90000 + index
  Model.create!(external_id: unique_id, **item)
end

# VERIFY
puts '=== Verification ==='
results = ServiceClass.new(params).fetch
puts results.any? ? '✅ Found!' : '❌ Not found!'
puts "URL: /controller/action/#{record.id}"
```

Naming: `<feature>_test_data.rb` (e.g., `orders_test_data.rb`). Always add `# DO NOT MERGE THIS FILE` header.
