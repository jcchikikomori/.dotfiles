---
name: shared-templates
description: Shared output format templates and reference sections for development agents to ensure consistent documentation and responses.
---

# Agent Shared Templates & References

This document consolidates duplicated sections across agents to reduce maintenance burden and ensure consistency.

---

## Shared Output Format Templates

### Standard Output Format (For All Development Agents)

Use this structure when starting a new task:

```
## [Icon] [Task Type]: [Feature/Component Name]

### Task Summary
[User request - 1-2 sentences]

### Context
- Framework/Stack: [Framework(s)]
- Database/API: [Database/API type if relevant]
- Frontend: [Frontend tech if relevant]

### Planning Phase
1. [ ] Requirements clarified
2. [ ] Architecture/design reviewed
3. [ ] Impact assessment done
4. [ ] Dependencies identified

### Implementation Plan
1. [ ] Phase 1: [Task-specific phase]
2. [ ] Phase 2: [Task-specific phase]
3. [ ] Phase 3: [Task-specific phase]
4. [ ] Phase 4: Testing
5. [ ] Phase 5: Security audit
6. [ ] Phase 6: Learning suggestion

### Current Status: Phase 1 - Planning
[Proceeding with task...]
```

### Task Icons by Type
- 🎨 Frontend: UI components, styling, responsive design
- ⚙️ Backend: APIs, databases, business logic
- 🚀 Full Stack: End-to-end features, refactoring
- 📦 Component: Understanding/documenting code
- 🔍 Debug: Production issues, troubleshooting
- 🚀 Setup: Project onboarding, architecture
- 🛡️ Security: Audits, vulnerability fixes

---

## Shared Tools Reference by Framework

### Rails Tools
| Task | Command |
|------|---------|
| Start server | `rails server` |
| Console | `rails console` |
| Migrations | `rails db:migrate` / `rails db:rollback` |
| Generate | `rails generate migration/model/controller [name]` |
| Tests | `bundle exec rspec` |
| Linting | `bundle exec rubocop` |
| Audit | `bundle audit` |

### Node.js Tools
| Task | Command |
|------|---------|
| Install deps | `npm install` / `yarn install` |
| Dev server | `npm run dev` |
| Build | `npm run build` |
| Tests | `npm test` |
| Lint | `npm run lint` |
| Audit | `npm audit` |

### Python Tools
| Task | Command |
|------|---------|
| Virtual env | `python -m venv venv` |
| Install deps | `pip install -r requirements.txt` |
| Tests | `pytest` |
| Type check | `mypy` |
| Lint | `ruff check` |
| Security | `safety check` |

### Database Tools
| Task | Command |
|------|---------|
| MySQL | `mysql -u user -p database` |
| PostgreSQL | `psql database_name` |
| Query analyze | `EXPLAIN ANALYZE [query]` |
| Backup | `mysqldump` / `pg_dump` |

---

## Shared Learning Resources

### By Roadmap Category

**Frontend Development**
- Roadmap: [roadmap.sh/frontend](https://roadmap.sh/frontend)
- GitHub: [kamranahmedse/developer-roadmap](https://github.com/kamranahmedse/developer-roadmap/tree/master/src/data/roadmaps/frontend)
- React Docs: [react.dev](https://react.dev)
- Vue Docs: [vuejs.org](https://vuejs.org)
- CSS/Styling: [tailwindcss.com](https://tailwindcss.com), [getbootstrap.com](https://getbootstrap.com)
- Accessibility: [w3.org/WAI](https://www.w3.org/WAI/), [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- Performance: [web.dev](https://web.dev), [web.dev/vitals](https://web.dev/vitals/)

**Backend Development**
- Roadmap: [roadmap.sh/backend](https://roadmap.sh/backend)
- GitHub: [kamranahmedse/developer-roadmap](https://github.com/kamranahmedse/developer-roadmap/tree/master/src/data/roadmaps/backend)
- REST API Design: [restfulapi.net](https://restfulapi.net/)
- GraphQL: [graphql.org](https://graphql.org/), [GraphQL Ruby](https://graphql-ruby.org/getting_started)
- Authentication: [jwt.io](https://jwt.io/), [OAuth 2.0](https://oauth.net/2/)
- Databases: [PostgreSQL Docs](https://www.postgresql.org/docs/), [MySQL Docs](https://dev.mysql.com/doc/), [Oracle Docs](https://docs.oracle.com/)
- Security: [OWASP Top 10](https://owasp.org/www-project-top-ten/)

**Full Stack Development**
- Roadmap: [roadmap.sh/full-stack](https://roadmap.sh/full-stack)
- GitHub: [kamranahmedse/developer-roadmap](https://github.com/kamranahmedse/developer-roadmap/tree/master/src/data/roadmaps/full-stack)
- Rails Guides: [guides.rubyonrails.org](https://guides.rubyonrails.org/)
- Rails Upgrade Path: [Rails 7 Guide](https://guides.rubyonrails.org/7_0_release_notes.html), [Rails 8 Guide](https://guides.rubyonrails.org/8_0_release_notes.html)
- Hotwire: [hotwired.dev](https://hotwired.dev/)
- Next.js: [nextjs.org](https://nextjs.org/)
- Docker: [docker.com/resources](https://www.docker.com/resources/)

---

## Shared Security Checklist (OWASP)

**Note**: For detailed security audits, load the `owasp` skill. This is a quick reference.

```
┌─────────────────────────────────────────────────────────────┐
│ QUICK OWASP SECURITY CHECK                                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ INPUT VALIDATION                                             │
│ □ User inputs validated on server-side                      │
│ □ SQL injection prevented (parameterized queries)           │
│ □ No eval() with user data                                  │
│                                                             │
│ OUTPUT ENCODING                                              │
│ □ HTML entities escaped                                     │
│ □ No dangerouslySetInnerHTML with user data                 │
│ □ JSON responses properly formatted                         │
│                                                             │
│ AUTHENTICATION                                               │
│ □ Passwords hashed (bcrypt, Argon2, not MD5)                │
│ □ Sessions/tokens have expiration                           │
│ □ HTTPS enforced                                            │
│                                                             │
│ AUTHORIZATION                                                │
│ □ Users access only own data                                │
│ □ Admin endpoints protected                                 │
│ □ CSRF tokens on state-changing requests                    │
│                                                             │
│ DATA PROTECTION                                              │
│ □ PII not logged or exposed in errors                       │
│ □ Sensitive data encrypted at rest                          │
│ □ No secrets in code or environment files                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Shared Accessibility Checklist (WCAG 2.1 Level AA)

**Note**: For detailed accessibility audits, reference `web-audit-agent.md` or load `owasp` skill.

```
┌─────────────────────────────────────────────────────────────┐
│ WCAG 2.1 LEVEL AA QUICK CHECK                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ KEYBOARD NAVIGATION                                         │
│ □ All interactive elements keyboard accessible              │
│ □ Tab order follows visual flow                             │
│ □ Focus visible (outline/highlight)                         │
│                                                             │
│ SCREEN READER SUPPORT                                       │
│ □ Semantic HTML (<button>, <nav>, <article>, etc.)          │
│ □ ARIA labels on icon-only buttons                          │
│ □ Form labels associated with inputs                        │
│                                                             │
│ VISUAL                                                       │
│ □ Color contrast >= 4.5:1 for text                          │
│ □ Don't rely on color alone                                 │
│ □ Text resizable to 200%                                    │
│                                                             │
│ IMAGES & MEDIA                                              │
│ □ Images have descriptive alt text                          │
│ □ Decorative images: alt=""                                 │
│ □ Videos have captions                                      │
│                                                             │
│ FORMS                                                        │
│ □ Error messages clear and linked to fields                 │
│ □ Form instructions before inputs                           │
│ □ Required fields marked                                    │
│                                                             │
│ TOOLS TO VERIFY                                              │
│ □ [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
│ □ [WAVE Extension](https://wave.webaim.org/extension/)      │
│ □ Chrome DevTools Lighthouse → Accessibility                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Shared Testing Patterns

### Unit Testing

**Rails/RSpec Pattern**
```ruby
RSpec.describe Model do
  describe '#method_name' do
    context 'when condition is true' do
      it 'returns expected result' do
        expect(model.method).to eq(expected)
      end
    end
  end
end
```

**Node/Jest Pattern**
```javascript
describe('function name', () => {
  it('returns expected value', () => {
    expect(fn()).toBe(expected);
  });
});
```

**Python/Pytest Pattern**
```python
def test_function():
    result = function()
    assert result == expected
```

### Integration Testing

**Rails Request Spec Pattern**
```ruby
RSpec.describe 'POST /api/v1/users', type: :request do
  it 'creates user' do
    post '/api/v1/users', params: { user: { name: 'John' } }
    expect(response).to have_http_status(:created)
  end
end
```

### E2E Testing Reference
- **Cypress**: [cypress.io](https://www.cypress.io/)
- **Playwright**: [playwright.dev](https://playwright.dev/)
- **WebDriver**: [w3c.github.io/webdriver/](https://w3c.github.io/webdriver/)

---

## Phase Workflow (Common Structure)

All development agents follow this general workflow:

1. **Task Analysis & Planning** - Clarify requirements, identify scope
2. **Architecture/Design** - Plan structure, data models, API design
3. **Core Implementation** - Write code, create files, handle business logic
4. **Testing & Validation** - Unit tests, integration tests, manual testing
5. **Security & Performance** - Audit security, optimize performance
6. **Learning Opportunity** - Suggest growth areas, reference resources

**Note**: Each agent customizes these phases for its specific domain.

---

## How to Use These Templates

1. **For agents creating new tasks**: Reference Output Format template above
2. **For security concerns**: Use "Quick OWASP Check" then load `owasp` skill for details
3. **For accessibility**: Use "WCAG 2.1 Quick Check" then reference `web-audit-agent.md`
4. **For learning paths**: Use "Shared Learning Resources" section
5. **For command references**: Use "Tools Reference by Framework" section

---

## Consolidation Status

### ✅ Consolidated (Removed from agents, reference here)
- Output Format templates
- Tools Reference tables
- Learning Resources links
- OWASP Quick Check

### ⚠️ Still in Agents (Framework-specific, keep separate)
- Code examples (Rails vs Node vs Python differ)
- Framework-specific patterns
- Legacy context (Rails 5.0 notes)

### 🔄 Reference Links (Agents should link here)
- Tests patterns
- Database tools
- Accessibility checklist
