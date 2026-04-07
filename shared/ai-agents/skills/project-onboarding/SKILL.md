---
name: project-onboarding
description: Help developers understand new projects including tech stack detection, setup instructions, architecture overview, and getting started guides.
---

# Project Onboarding Skill

**Use Case:** Helping a developer understand a new project's structure, setup instructions, architecture, or how to get started.

## Core Onboarding Workflow

### 1. Project Type Detection
Identify the stack immediately by checking root files:
- `Gemfile` / `config/application.rb` → Rails
- `package.json` → Node / React / Vue
- `requirements.txt` / `pyproject.toml` → Python
- `pom.xml` / `build.gradle` → Java

### 2. Documentation Discovery
Prioritize reading:
1. `README.md` (Main entry point)
2. `SETUP.md` or `INSTALL.md`
3. `docker-compose.yml` (To understand required services like Redis/Postgres)
4. `.env.example` (To understand required configuration)

### Output Format
Structure your onboarding report like this:

```markdown
## 🚀 Project Onboarding: [Project Name]

### Tech Stack Overview
- **Language:** [e.g. Ruby 3.2]
- **Framework:** [e.g. Rails 7]
- **Database:** [e.g. PostgreSQL]

### 5-Minute Setup Guide
Provide the exact bash commands to get the project running locally.
```bash
# Example:
cp .env.example .env
bundle install
rails db:prepare
rails server
```

### Architecture & Key Directories
- `app/models/` - Domain logic
- `app/controllers/` - Request handlers
- `[Other notable directories]`

### Notable Third-Party Services
List any external dependencies found in `docker-compose.yml` or `Gemfile`/`package.json` (e.g., Redis, Sidekiq, Stripe, AWS S3).
```