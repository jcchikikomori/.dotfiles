# Agent Notes: devtools-bin

Developer tooling scripts, separate from the `org.jcchikikomori.dotfiles` setup utilities next door. Naming convention: `devtools-{purpose}`. All POSIX `#!/bin/sh` unless noted.

## Scripts

### `bin/devtools-opencode`

Unified OpenCode setup and management. The most load-bearing script here — invoked by `stowme.sh` (omo restore) and CI (`install`, MCP binary verification).

```text
install / update     Install or update opencode and MCP dependencies
sync                 Sync shared AI agent configs (shared/ai-agents/) to OpenCode
mcp [install|list|status]                      Manage MCP dependencies (pipx/npx binaries)
vscode [generate|apply|list|project|install]   VSCode MCP integration
omo [backup|restore]                           oh-my-opencode preferences
```

### `bin/devtools-clean-branch`

Rebuild a polluted PR branch by cherry-picking selected commits onto a clean base.

```text
devtools-clean-branch [OPTIONS] TARGET_BRANCH WORK_BRANCH
  -r REMOTE     Remote name (default: origin)
  -c COMMITS    Comma/space-separated hashes or HASH1..HASH2 ranges (skips interactive selection)
```

Companion doc: `docs/CleanBranch.md` in the repo.

### `bin/devtools-llm`

Local LLM (Ollama) setup and management. `install [container|native]` auto-detects platform; also `uninstall`, `start`, `stop`, `status`.

### `bin/devtools-rspec-tester`

RSpec helper with SonarQube integration: `{test|coverage|sonar|full|setup-sonar} [path]`. Configured via environment variables from shell config.

## Notes for agents

- **Never rename these script files** — `devtools-opencode` is referenced by name in `stowme.sh` and `.github/workflows/ci-unit-test.yml`.
- New scripts follow the same rules as the `dotfiles-*` directory: POSIX sh, idempotent steps, non-interactive escape hatches for CI.
- MCP server definitions consumed by `devtools-opencode` live in `shared/ai-agents/mcps.json`.
