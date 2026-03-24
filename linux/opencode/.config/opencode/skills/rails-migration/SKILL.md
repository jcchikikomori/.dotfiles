# Rails Migration & Cascade Skill

**Use Case:** Creating new database fields via migrations and correctly cascading those changes across the full MVC stack in Ruby on Rails.

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