# MCP-First GitHub Operations Policy

This document describes the GitHub operations policy for all OpenCode sessions in this repository.

## Policy Summary

**All GitHub interactions default to `github-mcp_*` tools.** The `gh` CLI is a fallback and should only be used when:

1. The user explicitly requests it (e.g., "use gh CLI"), or
2. The relevant MCP tool is unavailable or broken.

This policy applies to all agents operating in this repository: the global Obama orchestrator, `dotfiles-orchestrator`, and `dotfiles-maintainer`.

## Tool Decision Table

| Action | Default MCP tool | gh CLI fallback |
|---|---|---|
| List issues | `github-mcp_list_issues` | `gh issue list` |
| Read issue detail | `github-mcp_issue_read` (method: `get`) | `gh issue view <n>` |
| List PRs | `github-mcp_list_pull_requests` | `gh pr list` |
| View PR / diff / files | `github-mcp_pull_request_read` | `gh pr view <n>` |
| Create issue | `github-mcp_issue_write` (method: `create`) | `gh issue create` |
| Update issue | `github-mcp_issue_write` (method: `update`) | `gh issue edit` |
| Add comment | `github-mcp_add_issue_comment` | `gh issue comment` |
| Create PR | `github-mcp_create_pull_request` | `gh pr create` |
| Merge PR | `github-mcp_merge_pull_request` | `gh pr merge` |
| Search code | `github-mcp_search_code` | `gh search code` |
| Search repos | `github-mcp_search_repositories` | `gh search repos` |
| Get file contents | `github-mcp_get_file_contents` | `gh api` |
| Authenticated identity | `github-mcp_get_me` | `gh api user` |

## Identity Sanity Check

**Before any write GitHub operation**, call `github-mcp_get_me` first to confirm the authenticated identity. The agent must log the returned `login` value to the user so they can verify the correct account is in use before proceeding.

**Write operations that trigger this check:**

- Creating an issue or PR
- Updating/editing an issue or PR
- Posting a comment
- Merging a PR
- Pushing files or creating/updating file contents

## gh CLI Usage Rules

- **Never default** to `gh` CLI for GitHub operations.
- Only use `gh` when user explicitly says so, or when an MCP tool returns an error.
- `gh` write commands (`gh issue comment`, `gh issue edit`, `gh pr create`, `gh pr merge`) still require explicit user confirmation per the standard permission model.
- Never run `gh auth login` or alter `gh` token configuration — token management is the user's responsibility.

## Minimal Token Permissions

The `GITHUB_PERSONAL_ACCESS_TOKEN` supplied via environment variable to `github-mcp` should have the **minimum required scopes**:

| Scope | Required for |
|---|---|
| `repo` | Read/write issues, PRs, code (private repos) |
| `public_repo` | Read/write issues, PRs, code (public repos only) |
| `read:user` | Identity check via `github-mcp_get_me` |

**Do not request or suggest broader scopes** such as `admin:org`, `delete_repo`, `workflow`, or `write:packages` unless the specific task explicitly requires them.

## Configuration Reference

GitHub MCP is configured in `.opencode/opencode.jsonc` under the `mcp.github-mcp` key.

Current project configuration:

```jsonc
"github-mcp": {
  "enabled": true
}
```

Authentication uses environment variables (autoloaded `.env` when configured by your OpenCode runtime).
Use `github-mcp_get_me` to verify the active identity before write operations.

## Skill Reference

The `mcp` skill (`~/.config/opencode/skills/mcp/SKILL.md`) contains the authoritative tool decision table for all sessions. It is auto-loaded whenever GitHub tasks are detected, per the `.opencode/SKILLS` core skill declaration.

## Related Files

| File | Purpose |
|---|---|
| `~/.config/opencode/AGENTS.md` | Global agent instructions — MCP-first GitHub policy section |
| `~/.config/opencode/skills/mcp/SKILL.md` | MCP skill with tool decision table |
| `.opencode/SKILLS` | Project-level skill declarations (mcp as core skill) |
| `.opencode/agents/dotfiles-maintainer.md` | Maintainer GitHub operations section |
| `.opencode/opencode.jsonc` | github-mcp server configuration |
