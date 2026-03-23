# OpenCode Agents

System-wide orchestrator and specialized agents for all opencode sessions on this machine.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER REQUEST                           │
└─────────────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                     OBAMA (Orchestrator)                        │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ 1. Detect project type (files, git, imports)             │  │
│  │ 2. Load relevant skill(s)                                 │  │
│  │ 3. Route to specialized agent OR answer directly          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                                  │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
        ▼                         ▼                         ▼
┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│ SKILLS        │     │ AGENTS        │     │ DIRECT ANSWER │
│ (16 skills)   │     │ (6 agents)    │     │ (simple info) │
└───────────────┘     └───────────────┘     └───────────────┘
```

## Available Agents

### Primary Agents

| Agent | Mode | Purpose |
|-------|------|---------|
| **obama** | primary | System-wide orchestrator - routes all requests |

### Specialized Subagents

| Agent | When to Use | Description |
|-------|-------------|-------------|
| **rails-migration-agent** | Rails migrations | Create migrations, cascade changes to model/spec/controller/routes/views |
| **web-audit-agent** | HTML/CSS/JS | Browser compatibility (caniuse), OWASP security audit |
| **debug-agent** | Production issues | Reproduce bugs, root cause analysis, test case creation |
| **component-doc-agent** | Understanding code | Explain component purpose, usage, API documentation |
| **project-onboarding-agent** | Project setup | Structure, setup instructions, architecture overview |
| **ruby-cocoder** | Complex Ruby tasks | Deep Ruby implementation, refactoring, patterns |

### Project-Specific Agents

| Agent | Purpose |
|-------|---------|
| **dotfiles-maintainer** | Cross-platform dotfiles maintenance (in dotfiles repo only) |

## Skill Routing

When the orchestrator detects project type, it auto-loads relevant skills:

| Project Type | Skills Loaded |
|--------------|---------------|
| Ruby on Rails | `ruby`, `ruby-on-rails` |
| Node.js (React) | `nodejs`, `reactjs` |
| Node.js (Vue) | `nodejs`, `vuejs` |
| Python (FastAPI) | `python`, `fastapi` |
| Python (Django) | `python` |
| PHP (Laravel) | `php` |
| Java | `java` |
| Kotlin/Android | `android-kotlin` |
| Any + Security | `owasp` (always first) |
| Any + Database | relevant SQL skill (always first) |

## Task-to-Agent Routing

Use this table to know which agent handles your task:

| Your Request | Delegate To |
|--------------|-------------|
| "Add phone_number field to users" | `rails-migration-agent` |
| "Create new migration for orders table" | `rails-migration-agent` |
| "Check if CSS :has() selector works" | `web-audit-agent` |
| "Audit this JavaScript for security issues" | `web-audit-agent` |
| "Check caniuse for backdrop-filter" | `web-audit-agent` |
| "Debug the 500 error on production" | `debug-agent` |
| "Fix the login bug - steps to reproduce..." | `debug-agent` |
| "Create test cases from ticket" | `debug-agent` |
| "What does OrderService do?" | `component-doc-agent` |
| "How do I use the UserCard component?" | `component-doc-agent` |
| "Explain this model's enums" | `component-doc-agent` |
| "How do I set up this project?" | `project-onboarding-agent` |
| "What is the project structure?" | `project-onboarding-agent` |
| "What does this codebase do?" | `project-onboarding-agent` |
| "Add stow package for zsh" | `dotfiles-maintainer` |
| "Propagate changes to all distros" | `dotfiles-maintainer` |
| "Check for stow conflicts" | `dotfiles-maintainer` |

## Example Conversations

### Example 1: Rails Migration

```
You: "Add a status field to the orders table with enum values"

Obama:
┌─────────────────────────────────────────────────────────────┐
│ Routing to: rails-migration-agent                          │
│ Detected: Ruby on Rails project                            │
│ Loading skills: ruby, ruby-on-rails                       │
└─────────────────────────────────────────────────────────────┘

rails-migration-agent:
┌─────────────────────────────────────────────────────────────┐
│ ## New Field: status                                        │
│                                                              │
│ Enum values: pending, processing, shipped, delivered, cancelled │
│                                                              │
│ Files to cascade:                                           │
│ □ app/models/order.rb (enum + scopes)                       │
│ □ spec/models/order_spec.rb (factory + tests)               │
│ □ app/controllers/orders_controller.rb (strong params)      │
│ □ config/routes.rb (review if nested)                      │
│                                                              │
│ Ready to generate?                                          │
│ [1] Generate migration only                                  │
│ [2] Generate + cascade to model + spec                     │
│ [3] Generate + cascade to all applicable files              │
└─────────────────────────────────────────────────────────────┘
```

### Example 2: Web Security Audit

```
You: "Check this React component for security issues"

Obama:
┌─────────────────────────────────────────────────────────────┐
│ Routing to: web-audit-agent                                │
│ Detected: Node.js + React project                          │
│ Loading skills: nodejs, reactjs, owasp                     │
└─────────────────────────────────────────────────────────────┘

web-audit-agent:
┌─────────────────────────────────────────────────────────────┐
│ ## Security Audit: UserForm.jsx                            │
│                                                              │
│ 🔴 XSS Vulnerability (Line 52)                              │
│    User input directly inserted via innerHTML              │
│    Fix: Use textContent or sanitize with DOMPurify          │
│                                                              │
│ 🟡 Missing CSRF Token (Line 45)                            │
│    Form submits without authenticity token                 │
│    Fix: Add <input type="hidden" name="authenticity_token" │
│                                                              │
│ ✅ CSP Header Recommendation                                │
│    Add Content-Security-Policy to prevent inline scripts  │
│                                                              │
│ Compatibility: ✅ All features are 97%+ supported           │
└─────────────────────────────────────────────────────────────┘
```

### Example 3: Debug Production Issue

```
You: "Users are getting 500 when exporting CSV. Here's the ticket with steps to reproduce"

Obama:
┌─────────────────────────────────────────────────────────────┐
│ Routing to: debug-agent                                    │
│ Loading skills: ruby, ruby-on-rails                        │
└─────────────────────────────────────────────────────────────┘

debug-agent:
┌─────────────────────────────────────────────────────────────┐
│ ## 🔍 Debug Session: CSV Export 500 Error                  │
│                                                              │
│ Severity: 🟡 Medium                                        │
│ Reproducibility: 🟢 Always                                  │
│                                                              │
│ Investigation Plan:                                         │
│ [✓] Check logs (found: undefined method `export_format`)   │
│ [✓] Identify code path (OrdersController#export)           │
│ [ ] Reproduce in test environment                          │
│ [ ] Design test cases from replication steps                │
│ [ ] Root cause analysis (5 Whys)                           │
│ [ ] Implement fix                                          │
│ [ ] Add regression tests                                    │
│                                                              │
│ Root Cause: Method `export_format` removed in PR #123       │
│ but not updated in controller                               │
│                                                              │
│ Fix: Add back method or update controller                   │
└─────────────────────────────────────────────────────────────┘
```

## Adding New Agents

1. Create agent file: `agents/<name>.md`
2. Add YAML frontmatter with mode and permissions:

```yaml
---
description: "When to use this agent"
mode: subagent  # or primary
permission:
  edit: ask
  bash:
    "*": allow
    "git commit*": ask
  webfetch: allow
---
```

3. Add agent to routing table in `obama.md`
4. Update this README

## Files

```
agents/
├── README.md                    # This file
├── obama.md                     # Primary orchestrator
├── rails-migration-agent.md     # Rails migration cascade
├── web-audit-agent.md          # Web compatibility + security
├── debug-agent.md              # Production debugging
├── component-doc-agent.md      # Component documentation
├── project-onboarding-agent.md # Project setup guide
├── ruby-cocoder.md             # Ruby specialist (in parent dir)
└── dotfiles-maintainer.md      # Dotfiles maintenance (dotfiles repo)
```
