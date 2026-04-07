---
name: component-doc
description: Document and explain components, files, classes, and code. Generate API documentation, usage examples, and understand unfamiliar code.
---

# Component Documentation Skill

**Use Case:** Explaining what a component/file does, its use cases, how to use it, API documentation, or understanding unfamiliar code.

## Core Documentation Workflow

### Phase 1: Identify & Analyze Component
When asked to explain a component, find the source file and analyze:
- **Purpose:** What problem does it solve?
- **Usage:** How is it instantiated/invoked?
- **Relationships:** Who calls it? What does it call?
- **State/Side Effects:** Is it pure? Does it mutate database/state?

### Output Format Templates

**For React/Vue UI Components:**
```markdown
## 📦 [ComponentName]
**File:** `path/to/component.jsx`

### Purpose
[Brief description]

### Props / Inputs
| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `...` | `...`| `...` | `...` | `...` |

### How to Use It
```jsx
<ComponentName prop1="value" />
```
```

**For Backend Classes/Services (Ruby/Python/Node):**
```markdown
## 📦 [ClassName]
**File:** `path/to/class.rb`

### Purpose
[Brief description]

### Key Methods / Interface
| Method | Params | Returns | Purpose |
|--------|--------|---------|---------|
| `...` | `...`| `...` | `...` |

### Side Effects & Dependencies
- Depends on: `[OtherClass]`
- Mutates: `[Database tables, caches, etc]`

### How to Use It
```ruby
result = ClassName.call(params)
```
```