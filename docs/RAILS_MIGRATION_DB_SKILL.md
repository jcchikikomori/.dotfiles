# Rails Migration DB Skill Detection

This document describes how the OpenCode agent (Obama Orchestrator) resolves which database skill to load when working on Rails migrations. It is **normative** — the logic in `AGENTS.md` and `rails-migration/SKILL.md` implements exactly this behavior.

## Why This Exists

Without explicit DB detection, the agent could incorrectly default to `oracle-sql` for any Rails migration task, even in projects using MySQL or PostgreSQL. This causes wrong guidance (Oracle PL/SQL patterns, Oracle index syntax, etc.) to be applied to non-Oracle databases.

## Detection Priority (Strict Order)

### Context Gate — Rails Migration Detected?

Before any DB adapter detection runs, check:
- `db/migrate/*.rb` files exist in the project
- File content contains `ActiveRecord::Migration`

If **neither** condition is met, this detection logic does **not** apply (not a Rails migration task).

---

### Step 1 — Gemfile/Gemfile.lock Gem Evidence (PRIMARY)

Scan both `Gemfile` and `Gemfile.lock` for database adapter gems.

| Gem | Maps to |
|---|---|
| `mysql2` | `mysql-mariadb` skill |
| `trilogy` | `mysql-mariadb` skill |
| `pg` | `postgresql` skill |
| `activerecord-oracle_enhanced-adapter` | `oracle-sql` skill |
| `ruby-oci8` | `oracle-sql` skill |
| `sqlite3` | Generic SQL guidance *(no dedicated SQLite skill)* |

**If a clear match is found here — STOP. Do not proceed to Step 2.**

---

### Step 2 — `config/database.yml` Adapter Field (FALLBACK)

Only used when Step 1 produces no result (Gemfile absent or no recognized adapter gem).

Read `config/database.yml`. Check the `adapter:` field, preferring `production` environment over `development`.

| `adapter:` value | Maps to |
|---|---|
| `mysql2` or `trilogy` | `mysql-mariadb` skill |
| `postgresql` or `postgis` | `postgresql` skill |
| `oracle_enhanced` | `oracle-sql` skill |
| `sqlite3` | Generic SQL guidance |

---

## Anti-Default Rule

**`oracle-sql` is NEVER loaded by default for a Rails migration.**

Oracle skill loads only when explicitly confirmed by:
1. `Gemfile`/`Gemfile.lock` containing `activerecord-oracle_enhanced-adapter` or `ruby-oci8`
2. OR `config/database.yml` with `adapter: oracle_enhanced`

If neither condition is met, Oracle is **not** the adapter. Do not guess.

---

## Skill Availability Limitations

| DB Adapter | Local Skill Available |
|---|---|
| MySQL / MariaDB | ✅ `mysql-mariadb` |
| Oracle | ✅ `oracle-sql` |
| PostgreSQL | ✅ `postgresql` |
| SQLite | ❌ No dedicated skill — apply standard Rails/ActiveRecord guidance |

---

## Verification Commands

Run these manually (or the agent can run them) to validate adapter detection in any Rails project:

```sh
# Step 1: Gemfile/Gemfile.lock gem evidence
grep -E 'mysql2|trilogy|pg[^_]|oracle_enhanced|ruby-oci8|sqlite3' Gemfile Gemfile.lock 2>/dev/null

# Step 2: database.yml adapter (fallback)
grep 'adapter:' config/database.yml 2>/dev/null
```

### Expected Results

| Command Output | Conclusion |
|---|---|
| `mysql2` or `trilogy` in Gemfile | → Load `mysql-mariadb` skill |
| `pg` in Gemfile | → Load `postgresql` skill |
| `activerecord-oracle_enhanced-adapter` or `ruby-oci8` in Gemfile | → Load `oracle-sql` skill |
| No DB gem in Gemfile → `adapter: mysql2` in database.yml | → Load `mysql-mariadb` skill |
| No DB gem in Gemfile → `adapter: oracle_enhanced` in database.yml | → Load `oracle-sql` skill |
| No DB gem, no database.yml → ambiguous | → Ask user to confirm DB; default to generic SQL |

---

## Test Scenarios

These are concrete cases to mentally verify the logic:

### Scenario A — MySQL project (should NOT load oracle-sql)
```
Gemfile contains: gem 'mysql2'
```
→ Step 1 matches `mysql2` → Load `mysql-mariadb` → Done. Oracle never loaded.

### Scenario B — PostgreSQL project
```
Gemfile contains: gem 'pg', '~> 1.5'
```
→ Step 1 matches `pg` → Load `postgresql` skill → Done.

### Scenario C — Oracle project (only case where oracle-sql loads)
```
Gemfile contains: gem 'activerecord-oracle_enhanced-adapter'
```
→ Step 1 matches oracle gem → Load `oracle-sql` → Done.

### Scenario D — database.yml fallback (no Gemfile match)
```
Gemfile: no DB adapter gem listed (e.g., sqlite3 only for test env)
config/database.yml production: adapter: mysql2
```
→ Step 1 finds `sqlite3` in Gemfile for test, but production config says `mysql2`
→ Step 2 maps `mysql2` → Load `mysql-mariadb`.

### Scenario E — Ambiguous (neither step resolves)
```
Gemfile: no recognized adapter gem
config/database.yml: absent or no adapter key
```
→ Agent asks user: "I cannot determine the DB adapter. Are you using MySQL, PostgreSQL, Oracle, or SQLite?"

---

## Files Implementing This Logic

| File | Role |
|---|---|
| `linux/opencode/.config/opencode/AGENTS.md` | Global orchestrator rules — Detection Priority table + Rails Migration DB Adapter Detection section |
| `darwin/opencode/.config/opencode/AGENTS.md` | Mirror of above for macOS |
| `linux/opencode/.config/opencode/skills/rails-migration/SKILL.md` | Skill-level enforcement — DB Adapter Detection section at top |
| `darwin/opencode/.config/opencode/skills/rails-migration/SKILL.md` | Mirror of above for macOS |

## Last Updated

- Date: 2026-03-25
- Change: Add `postgresql` skill integration — `pg` gem and `adapter: postgresql`/`postgis` now map to `postgresql` skill; removed stale "no local skill" notes
