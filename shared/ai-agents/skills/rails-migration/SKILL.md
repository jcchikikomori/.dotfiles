---
name: rails-migration
description: Create Ruby on Rails database migrations and cascade changes across the full MVC stack including models, controllers, views, and tests.
---

# Rails Migration & Cascade Skill

**Use Case:** Creating new database fields via migrations and correctly cascading those changes across the full MVC stack in Ruby on Rails.

## DB Adapter Detection (MANDATORY — resolve before applying DB-specific guidance)

When this skill is loaded, **immediately determine the database adapter** using the following steps in order:

### Step 1 — Gemfile/Gemfile.lock (HIGHEST PRIORITY)

Scan `Gemfile` and `Gemfile.lock` for DB adapter gems:

| Gem found | DB Skill / guidance |
|---|---|
| `mysql2` | Load `mysql-mariadb` skill |
| `trilogy` | Load `mysql-mariadb` skill |
| `pg` | Load `postgresql` skill |
| `activerecord-oracle_enhanced-adapter` | Load `oracle-sql` skill |
| `ruby-oci8` | Load `oracle-sql` skill |
| `sqlite3` | No dedicated skill — use standard ActiveRecord/SQLite guidance |

### Step 2 — `config/database.yml` adapter field (FALLBACK — only if Step 1 is ambiguous or Gemfile absent)

Read `config/database.yml` and check the `adapter:` field for each environment:

| `adapter:` value | DB Skill / guidance |
|---|---|
| `mysql2` or `trilogy` | Load `mysql-mariadb` skill |
| `postgresql` or `postgis` | Load `postgresql` skill |
| `oracle_enhanced` | Load `oracle-sql` skill |
| `sqlite3` | No dedicated skill — use standard guidance |

### Anti-Default Rule

**Do NOT load `oracle-sql` by default** when a Rails migration context is detected. Oracle guidance is **only** appropriate when:
- Gemfile/Gemfile.lock contains `activerecord-oracle_enhanced-adapter` or `ruby-oci8`, **OR**
- `config/database.yml` explicitly uses `adapter: oracle_enhanced`

Any other detected adapter must map to its correct skill (or generic SQL) — never silently fall through to Oracle.

### Verification Commands

Run these to confirm adapter detection when working on an unfamiliar project:

```sh
# Step 1: Gemfile gem evidence
grep -E 'mysql2|trilogy|pg[^_]|oracle_enhanced|ruby-oci8|sqlite3' Gemfile Gemfile.lock 2>/dev/null

# Step 2: database.yml adapter field (fallback)
grep 'adapter:' config/database.yml 2>/dev/null
```

Expected outcomes:
- `mysql2` or `trilogy` found → `mysql-mariadb` skill
- `pg` found → `postgresql` skill
- `oracle_enhanced`/`ruby-oci8` found → `oracle-sql` skill
- Nothing found in Gemfile → proceed to Step 2

---

## Core Migration Workflow

### 1. Planning & Generation
Before writing code, verify:
- Field type (string, integer, boolean, JSONB)
- Database constraints (null: false, defaults, indexing)
- Use the generator: `rails generate migration Add[Field]To[Table] [field]:[type]`

### 2. Component Cascade Checklist
Every time a database column is added, you MUST cascade the change to these files:

- **1. Database (`db/migrate/...`)**
  - Verify constraints (e.g. `null: false`, `add_index`).
- **2. Model (`app/models/[model].rb`)**
  - Add validations (`presence`, `uniqueness`).
  - Add `enum` definitions if applicable.
- **3. Strong Params (`app/controllers/[model]_controller.rb`)**
  - Update `params.require(...).permit(:new_field)` so it can be saved!
- **4. Views/Serializers**
  - Add to `_form.html.erb`.
  - Add to JSON serializers if operating an API.
- **5. Specs (`spec/models/[model]_spec.rb`)**
  - Update Factories (`FactoryBot.define`).
  - Write test proving validation works.

### Output Format
When handling a migration, structure your response as follows:

```markdown
## 🗄️ Migration Plan

### 1. Database Layer
`rails generate migration [Command]`

### 2. MVC Cascade
- **Model:** [List validations to add]
- **Controller:** [List strong params to update]
- **Views:** [List forms to update]

### Action Plan
1. [ ] Generate and run migration
2. [ ] Update model & validations
3. [ ] Update strong parameters
4. [ ] Update UI / Serializers
5. [ ] Run tests to verify
```